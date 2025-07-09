extends Area2D

@export var bounce_force := 50.0           # 弹力大小
@export var bounce_direction := Vector2.UP  # 弹力方向
@onready var up: RayCast2D = $up

@onready var down: RayCast2D = $down
@onready var left: RayCast2D = $left
@onready var right: RayCast2D = $right

var fx = 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("apply_bounce"):
			if up.is_colliding():#向下
				fx = 0
			print(fx)
			body.apply_bounce(bounce_direction.normalized() * bounce_force,fx)
