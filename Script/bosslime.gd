extends Node2D
var tps: Array[Vector2] = []
const SPEED = 60
var direction = 1
var hp = 10  # 敌人生命值
var value = hp
@onready var gamemanage: CanvasLayer = $"../GameManage"
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var tptime: Timer = $Tptime
@export var teleport_cooldown_time = 4
@onready var hurtbox = $HurtBox
@onready var timer: Timer = $Timer
@onready var tp: AudioStreamPlayer = $Tp
@onready var collision_shape: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var hurt_box: Area2D = $HurtBox
@onready var portal: Area2D = $"../Portal"
var can_be_damaged = true 
var is_being_hit = false
var hit = false
var can_teleport = true
var is_active = false
func _ready():
	set_active(false)
	tptime.wait_time = teleport_cooldown_time
	tptime.one_shot = true 
	tptime.timeout.connect(func(): can_teleport = true)
	for chiled in get_children():
		#print(chiled)
		if "tp" in chiled.name :
			var Tposition = global_position + chiled.position
			tps.append(Tposition)
			#print(Tposition)
			#print(tps.size())
		#print(chiled)
	timer.wait_time = 1
	timer.one_shot = true
	timer.timeout.connect(func(): can_be_damaged = true)
func _process(delta):
	if can_teleport: 
		start_teleport()
	if is_being_hit:
		return
	if hp > 0:
		if ray_cast_right.is_colliding() and not hit:
			direction = -1
			animated_sprite.flip_h = true
		elif ray_cast_left.is_colliding() and not hit:
			direction = 1
			animated_sprite.flip_h = false
		position.x += direction * SPEED * delta
		if direction != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
func _on_HurtBox_area_entered(area):#检测
	if area.name == "Player":
		#修复无敌的时候卡在boss范围中间
		if area.wudi() and can_be_damaged:
		#print(area.wudi())
			timer.start()
			take_damage(area.attack_power)
func take_damage(amount):
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	hp -= amount
	is_being_hit = true
	$AudioStreamPlayer2D.play()
	animated_sprite.play("hit")
	await animated_sprite.animation_finished
	is_being_hit = false
	can_be_damaged = false
	#animated_sprite.play("default")	
	if hp <= 0:
		#if has_node("InteractionPrompt"):
		#GlobalGameManager.add_point(value)
		portal.visible = true
		gamemanage.add_point(value)
		set_process(false)
		queue_free()	


func _on_timer_timeout() -> void:

	can_be_damaged = true # 重置为可被伤害
	hurtbox.set_deferred("monitoring", true) 
	hurtbox.set_deferred("monitorable", true) 
	#print("怪物无敌时间结束。") #
func start_teleport():

	can_teleport = false
	tptime.start() # 启动瞬移冷却
	var target_point = tps[randi() % tps.size()]
	global_position = target_point
	tp.play()



func _on_tptime_timeout() -> void:
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	set_active(true)
	#pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	set_active(false)
func set_active(active_state: bool):
	is_active = active_state
	animated_sprite.visible = active_state 
	collision_shape.disabled = not active_state 
	hurt_box.monitoring = active_state 
	hurt_box.monitorable = active_state 

	set_physics_process(active_state) 
	set_process(active_state) 
	
	if active_state:
		can_teleport = false
		tptime.start()  # 延迟允许瞬移
