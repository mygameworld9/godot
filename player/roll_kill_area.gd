extends Area2D

@onready var kill_delay = 1
@onready var gamemanage: CanvasLayer = get_node("/root/Game/GameManage")
@onready var player = get_parent()


#func _on_body_entered(body: Node2D):
	#print(player.wudi())
	#if player.wudi():
		## 击杀敌人
		#
		#if body.has_method("take_damage"):
			#body.take_damage(3)
		#print(2333)
		#
