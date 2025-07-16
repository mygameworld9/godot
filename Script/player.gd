extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -150.0
const MAX_JUMP_HOLD_TIME = 0.2
const EXTRA_JUMP_FORCE = -1000.0
const MAX_JUMP = 2
const FLY_DURATION := 0.3
var fly_timer = 0
@export var bounce_force := 200  
@export var ROLL_SPEED_MULTIPLIER = 1.2
@export var ROLL_DURATION = 0.8
@export var ROLL_COLLISION_HEIGHT_MULTIPLIER = 0.5
@export var poppable_tilemap_layer_index: int = 0
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var roll_timer: Timer = $Timer
#@onready var head_hitbox: Area2D = $HeadHitbox
#@onready var head_ray: RayCast2D = $HeadRay
@onready var game: Node2D = $".."
@onready var mainground: TileMapLayer = $"../MainGround"
@onready var gamemanage: CanvasLayer = $"../GameManage"
@export var attack_power = 1 #攻击力
var is_bouncing = false
var is_rolling = false
var is_invulnerable = false
var is_jumping = false
var jump_time = 0.0
var jumps = MAX_JUMP
var coin_spawned_tiles = {}
var direction = 0
var original_collision_shape_extents: Vector2
var original_collision_shape_position: Vector2
var bounce_timer = 1
var bounce_direction = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	roll_timer.timeout.connect(_on_roll_timer_timeout)
	#animated_sprite.animation_finished.connect(_on_animation_finished)

	if collision_shape and collision_shape.shape is RectangleShape2D:
		original_collision_shape_extents = collision_shape.shape.extents
		original_collision_shape_position = collision_shape.position
func _physics_process(delta):

	if is_rolling:
		# 🎮 允许方向键控制移动和转向
		var roll_direction = Input.get_axis("left", "right")
		if roll_direction != 0:
			animated_sprite.flip_h = (roll_direction < 0)
			velocity.x = roll_direction * SPEED * ROLL_SPEED_MULTIPLIER
		else:
			velocity.x = 0

		if Input.is_action_just_pressed("jump") and jumps > 0:
			velocity.y = JUMP_VELOCITY
			jumps -= 1
			is_jumping = true
			jump_time = 0.0

		if is_jumping and Input.is_action_pressed("jump") and jump_time < MAX_JUMP_HOLD_TIME:
			velocity.y += EXTRA_JUMP_FORCE * delta
			jump_time += delta
		else:
			is_jumping = false
		if not is_on_floor():
			velocity.y += gravity * delta
		
		#velocity.y += gravity * a
		#velocity = move_and_slide(velocity, Vector2.UP)
		move_and_slide()
		return

	if is_on_floor():
		is_jumping = false
		jumps = MAX_JUMP
		jump_time = 0.0

	gamemanage.point()



	if Input.is_action_just_pressed("roll") and not is_rolling:
		start_roll()

	if Input.is_action_just_pressed("jump") and jumps > 0:
		velocity.y = JUMP_VELOCITY
		jumps -= 1
		is_jumping = true
		jump_time = 0.0

	if is_jumping and Input.is_action_pressed("jump") and jump_time < MAX_JUMP_HOLD_TIME:
		velocity.y += EXTRA_JUMP_FORCE * delta
		jump_time += delta
	else:
		is_jumping = false

	var direction = Input.get_axis("left", "right")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	if not is_rolling:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
	#print("播放动画：", animated_sprite.animation)
	if is_bouncing:
		bounce_timer -= delta
		# 按方向分量分别设置
		velocity.x = bounce_direction.x * bounce_force
		velocity.y = bounce_direction.y * bounce_force
		if bounce_timer <= 0:
			is_bouncing = false
		move_and_slide()
		return
	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func apply_bounce(force: Vector2):
	# 接收正确方向向量
	is_bouncing = true
	bounce_direction = force.normalized()
	# 取消跳跃状态
	is_jumping = false
	jump_time = MAX_JUMP_HOLD_TIME
# --- ROLLING ---
func start_roll():
	is_rolling = true
	is_invulnerable = true
	animated_sprite.play("roll")
	$RollHitbox.set_deferred("Monitoring", true)
	var current_horizontal_input = Input.get_axis("left", "right")
	if current_horizontal_input != 0:
		animated_sprite.flip_h = (current_horizontal_input < 0)

	roll_timer.start(ROLL_DURATION)

	if collision_shape and collision_shape.shape is RectangleShape2D:
		var rect_shape = collision_shape.shape
		rect_shape.extents = Vector2(original_collision_shape_extents.x, original_collision_shape_extents.y * ROLL_COLLISION_HEIGHT_MULTIPLIER)
		collision_shape.position = Vector2(original_collision_shape_position.x, original_collision_shape_position.y + original_collision_shape_extents.y * (1.0 - ROLL_COLLISION_HEIGHT_MULTIPLIER))
func wudi():
	return is_invulnerable
func end_roll():
	is_rolling = false
	is_invulnerable = false
	$RollHitbox.set_deferred("Monitoring", false)
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var rect_shape = collision_shape.shape
		rect_shape.extents = original_collision_shape_extents
		collision_shape.position = original_collision_shape_position

	velocity.x = 0

	var current_direction = Input.get_axis("left", "right")
	if is_on_floor():
		if current_direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

func _on_roll_timer_timeout():
	if is_rolling:
		end_roll()

#func _on_animation_finished(anim_name: String):
	#if anim_name == "roll":
		#if is_rolling and roll_timer.is_stopped():
			#end_roll()
