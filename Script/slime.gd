extends Node2D

const SPEED = 60
var direction = 1
var hp = 3  # 敌人生命值
var kill_delay = 3
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var hurtbox = $HurtBox
@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = kill_delay
	timer.one_shot = true

func _process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	if hp > 0:
		position.x += direction * SPEED * delta

func _on_HurtBox_area_entered(area):#检测
	if area.name == "Player" and area.wudi():
		print(area.wudi())
		take_damage(area.attack_power)
func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()

func die():
	animated_sprite.play("hit")
	Engine.time_scale = 1
	await animated_sprite.animation_finished
	queue_free()
	Engine.time_scale = 1


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
