extends Area2D

@export var bounce_force := 100.0           # 弹力大小
@export var bounce_direction := Vector2.UP  # 弹力方向
@export var bounce_direction1 := Vector2.LEFT  # 弹力方向
@export var bounce_direction2 := Vector2.RIGHT # 弹力方向

@onready var up: RayCast2D = $up

var fx = 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		if up.is_colliding():#向下
			print(1)
			body.apply_bounce(bounce_direction.normalized() * bounce_force)
