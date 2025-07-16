extends Area2D

@export var bounce_force := 50.0           # 弹力大小
@export var bounce_direction := Vector2.DOWN  # 弹力方向

@onready var down: RayCast2D = $down

var fx = 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("apply_bounce"):
			if down.is_colliding():
				fx = 3
			#print(fx)
			body.apply_bounce(bounce_direction.normalized() * bounce_force)
