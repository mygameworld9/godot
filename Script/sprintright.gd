extends Area2D

@export var bounce_force := 100.0           # 弹力大小
@export var bounce_direction := Vector2.UP  # 弹力方向
@export var bounce_direction1 := Vector2.LEFT  # 弹力方向
@export var bounce_direction2 := Vector2.RIGHT # 弹力方向
@onready var right: RayCast2D = $right

var fx = 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("apply_bounce"):
			if right.is_colliding():
				print(3)
				body.apply_bounce(bounce_direction2.normalized() * bounce_force*3)
