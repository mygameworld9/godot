extends Node2D

const SPEED = 60

var direction = 1

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_down: RayCast2D = $RayCastdown

func _process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
		
	#if  ray_cast_down.is_colliding():
		#direction *= -1
		#print(233)
		#if animated_sprite.flip_h == true:
			#animated_sprite.flip_h = false
		#else:
			#animated_sprite.flip_h = true
	position.x += direction * SPEED * delta
