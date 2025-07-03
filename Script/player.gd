extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -150.0
const MAX_JUMP_HOLD_TIME = 0.2
const EXTRA_JUMP_FORCE = -1000.0
const MAX_JUMP = 2

@export var ROLL_SPEED_MULTIPLIER = 2.0
@export var ROLL_DURATION = 0.8
@export var ROLL_COLLISION_HEIGHT_MULTIPLIER = 0.5

@export var poppable_tilemap_layer_index: int = 0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var roll_timer: Timer = $Timer
@onready var head_hitbox: Area2D = $HeadHitbox
@onready var head_ray: RayCast2D = $HeadRay
@onready var game: Node2D = $".."
@onready var mainground: TileMapLayer = $"../MainGround"
@onready var gamemanage: CanvasLayer = $"../GameManage"

var is_rolling = false
var is_invulnerable = false
var is_jumping = false
var jump_time = 0.0
var jumps = MAX_JUMP
var coin_spawned_tiles = {}

var original_collision_shape_extents: Vector2
var original_collision_shape_position: Vector2

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	roll_timer.timeout.connect(_on_roll_timer_timeout)
	animated_sprite.animation_finished.connect(_on_animation_finished)

	if collision_shape and collision_shape.shape is RectangleShape2D:
		original_collision_shape_extents = collision_shape.shape.extents
		original_collision_shape_position = collision_shape.position
	else:
		push_warning("Main collision_shape is not RectangleShape2D or missing!")

func _physics_process(delta):
	if is_rolling:
		var target_speed = (-1 if animated_sprite.flip_h else 1) * SPEED * ROLL_SPEED_MULTIPLIER
		velocity.x = move_toward(velocity.x, target_speed,delta)  # 改这里，越小加速越慢		if not is_on_floor():
		velocity.y += gravity * delta
		move_and_slide()
		return
	
	if is_on_floor():
		is_jumping = false
		jumps = MAX_JUMP
		jump_time = 0.0

	gamemanage.point()

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("roll") and is_on_floor() and not is_rolling:
		print("Roll triggered")
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
	print("播放动画：", animated_sprite.animation)

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# --- ROLLING ---
func start_roll():
	print("Start roll triggered")
	#print("start_roll() called!")
	is_rolling = true
	is_invulnerable = true
	animated_sprite.play("roll")

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

func _on_animation_finished(anim_name: String):
	if anim_name == "roll":
		if is_rolling and roll_timer.is_stopped():
			end_roll()
