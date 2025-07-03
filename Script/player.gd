extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -150.0   # 初始起跳速度，稍微调低点
const MAX_JUMP_HOLD_TIME = 0.2 # 最大跳跃维持时间（单位：秒）
const EXTRA_JUMP_FORCE = -1000.0 # 持续按住跳跃键时的额外向上力
const MAX_JUMP = 2

@onready var head_hitbox: Area2D = $HeadHitbox
@onready var head_ray: RayCast2D = $HeadRay
@onready var game: Node2D = $".."
@onready var mainground: TileMapLayer = $"../MainGround"
@onready var animated_sprite = $AnimatedSprite2D
@onready var gamemanage: CanvasLayer = $"../GameManage"
@export var poppable_tilemap_layer_index: int = 0 

var coin_spawned_tiles = {}
var is_jumping = false          # 是否正在跳跃
var jump_time = 0.0             # 持续按住跳跃键的时间
var jumps = MAX_JUMP
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# 如果在地面，重置跳跃状态
	if is_on_floor():
		is_jumping = false
		jumps = 2
		jump_time = 0.0
	gamemanage.point()
	# 添加重力
	if not is_on_floor():
		velocity.y += gravity * delta

	# 按下跳跃键（刚开始跳）
	if Input.is_action_just_pressed("jump") and jumps > 0:
		velocity.y = JUMP_VELOCITY
		jumps -= 1
		is_jumping = true
		jump_time = 0.0

	# 如果正在跳跃，并且继续按住跳跃键，并且没超过允许跳跃时间
	if is_jumping and Input.is_action_pressed("jump") and jump_time < MAX_JUMP_HOLD_TIME:
		velocity.y += EXTRA_JUMP_FORCE * delta
		jump_time += delta
	else:
		is_jumping = false

	# 获取左右移动方向（-1/0/1）
	var direction = Input.get_axis("left", "right")

	# 翻转精灵朝向
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# 播放动画
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle") 
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# 设置水平速度
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	#if head_ray.is_colliding and head_ray.get_collider() is TileMapLayer:
		#spawn_coin()
	move_and_slide()
#func spawn_coin():
	#var tilemap = head_ray.get_collider()
	##print(2333)
	#var hit_pos = head_ray.get_collision_point()
	##print(hit_pos)
	#var cell = tilemap.local_to_map(hit_pos)
	#print(cell)
	#var tile_data = tilemap.get_cell_tile_data(cell)
	#var tile_center_local_pos = tilemap.map_to_local(cell) + tilemap.tile_set.tile_size / 2.0
	#var coin = load("res://background/Coin.tscn")
	#var coin_instance = coin.instantiate() 
	#
	#game.add_child(coin_instance) 
	#coin_instance.global_position = tile_center_local_pos + Vector2(-8,-33)
	##coin_instance.position = tilemap.to_local(tile_center_local_pos)
	## 触发金币的弹出动画/行为 (假设 Coin.gdd  脚本中有 pop_up() 方法)
	#if coin_spawned_tiles.has(cell):
		#if coin_instance.has_method("pop_up"):
			#coin_instance.pop_up()
	#tilemap.set_cell(3, cell, 2)

	#var mouse_position = get_global_mouse_position()
	#var	 tile_coordinate = mainground.local_to_map(mouse_position)
	#var clicked_cell = mainground.local_to_map(mainground.get_local_mouse_position())
	#var data = mainground.get_cell_tile_data(clicked_cell)
	#if data:
		 #if data.get_custom_data("coin"):	# 应用移动
