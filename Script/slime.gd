extends Node2D

const SPEED = 60
var direction = 1
var hp = 1  # 敌人生命值
var value = hp
@onready var gamemanage: CanvasLayer = $"../GameManage"
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var hurtbox = $HurtBox
@onready var timer: Timer = $Timer
var can_be_damaged = true 
var is_being_hit = false
var hit = false
func _ready():
	timer.timeout.connect(func(): can_be_damaged = true)
func _process(delta):
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
	if area.name == "Player" and area.wudi() and can_be_damaged:
		hit = true
		#print(area.wudi())
		timer.start()
		take_damage(area.attack_power)
func take_damage(amount):
	hp -= amount
	is_being_hit = true
	$AudioStreamPlayer2D.play()
	animated_sprite.play("hit")
	await animated_sprite.animation_finished
	is_being_hit = false
	hit = false
	#animated_sprite.play("default")	
	if hp <= 0:
		gamemanage.add_point(1)
		set_process(false)
		queue_free()	


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
