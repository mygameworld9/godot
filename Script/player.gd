extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -150.0
const MAX_JUMP_HOLD_TIME = 0.2
const EXTRA_JUMP_FORCE = -1000.0
const MAX_JUMP = 2
const BOUNCE_DURATION := 0.3                # 弹飞持续时长 (秒)
@export var bounce_force := 300.0           # 弹力大小

@export var ROLL_SPEED_MULTIPLIER = 1.2
@export var ROLL_DURATION = 0.8
@export var ROLL_COLLISION_HEIGHT_MULTIPLIER = 0.5
@export var poppable_tilemap_layer_index: int = 0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var roll_timer: Timer = $Timer
@onready var game: Node2D = $".."
@onready var mainground: TileMapLayer = $"../MainGround"
@onready var gamemanage: CanvasLayer = $"../GameManage"

@export var attack_power = 1  # 攻击力

# ---- 状态变量 ----
var is_bouncing = false
var bounce_timer = 0.0
var bounce_direction = Vector2.ZERO
var is_rolling = false
var is_invulnerable = false
var is_jumping = false
var jump_time = 0.0
var jumps = MAX_JUMP

var original_collision_shape_extents: Vector2
var original_collision_shape_position: Vector2
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	roll_timer.timeout.connect(_on_roll_timer_timeout)
	if collision_shape and collision_shape.shape is RectangleShape2D:
		original_collision_shape_extents = collision_shape.shape.extents
		original_collision_shape_position = collision_shape.position

func _physics_process(delta):
	# 滚动逻辑
	if is_rolling:
		_process_roll(delta)
		return

	# 普通物理前置：重力 + 落地重置
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false
		jumps = MAX_JUMP
		jump_time = 0.0

	gamemanage.point()

	# 反弹逻辑：只设置一次速度，不累加，且不受重力/跳跃干扰
	if is_bouncing:
		bounce_timer -= delta
		# 按方向分量分别设置
		velocity.x = bounce_direction.x * bounce_force
		velocity.y = bounce_direction.y * bounce_force
		if bounce_timer <= 0:
			is_bouncing = false
		move_and_slide()
		return

	# 普通输入逻辑：翻滚、跳跃、水平
	if Input.is_action_just_pressed("roll") and not is_rolling:
		start_roll()

	if Input.is_action_just_pressed("jump") and jumps > 0: # 移除 is_on_floor() 限制
		if is_on_floor(): # 第一次跳跃在地面上
			_start_jump()
		elif not is_on_floor() and jumps > 0: # 在空中且还有跳跃次数（二段跳）
			_start_jump()


	if is_jumping and Input.is_action_pressed("jump") and jump_time < MAX_JUMP_HOLD_TIME:
		velocity.y += EXTRA_JUMP_FORCE * delta
		jump_time += delta
	else:
		is_jumping = false

	var dir_x = Input.get_axis("left", "right")
	animated_sprite.flip_h = dir_x < 0

	if not is_rolling:
		if is_on_floor():
			if dir_x == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")

	# 水平移动
	if dir_x != 0:
		velocity.x = dir_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# --- 方法定义 ---
func apply_bounce(force: Vector2, fx):
	# 接收正确方向向量
	is_bouncing = true
	bounce_timer = BOUNCE_DURATION
	bounce_direction = force.normalized()
	# 取消跳跃状态
	is_jumping = false
	jump_time = MAX_JUMP_HOLD_TIME

func _start_jump():
	velocity.y = JUMP_VELOCITY
	jumps -= 1
	is_jumping = true
	jump_time = 0.0

func start_roll():
	is_rolling = true
	is_invulnerable = true
	animated_sprite.play("roll")
	$RollHitbox.set_deferred("Monitoring", true)
	var roll_dir = Input.get_axis("left", "right")
	animated_sprite.flip_h = roll_dir < 0
	roll_timer.start(ROLL_DURATION)
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var rect = collision_shape.shape
		rect.extents = Vector2(original_collision_shape_extents.x,
							   original_collision_shape_extents.y * ROLL_COLLISION_HEIGHT_MULTIPLIER)
		collision_shape.position = original_collision_shape_position + Vector2(0,
			original_collision_shape_extents.y * (1.0 - ROLL_COLLISION_HEIGHT_MULTIPLIER))

func _process_roll(delta):
	var roll_dir = Input.get_axis("left", "right")
	velocity.x = roll_dir * SPEED * ROLL_SPEED_MULTIPLIER
	animated_sprite.flip_h = roll_dir < 0
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and jumps > 0:
		_start_jump()
	if is_jumping and Input.is_action_pressed("jump") and jump_time < MAX_JUMP_HOLD_TIME:
		velocity.y += EXTRA_JUMP_FORCE * delta
		jump_time += delta
	else:
		is_jumping = false
	move_and_slide()

func wudi():
	return is_invulnerable

func end_roll():
	is_rolling = false
	is_invulnerable = false
	$RollHitbox.set_deferred("Monitoring", false)
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var rect = collision_shape.shape
		rect.extents = original_collision_shape_extents
		collision_shape.position = original_collision_shape_position
	velocity.x = 0
	if is_on_floor():
		if Input.get_axis("left", "right") == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
func _on_roll_timer_timeout():
	if is_rolling:
		end_roll()
