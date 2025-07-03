extends Area2D

@onready var timer: Timer = $Timer
#@onready var game_manage: CanvasLayer = %GameManage

@onready var death_wait_time = 0.25 # 等待时间
@onready var gamemanage: CanvasLayer = get_node("/root/Game/GameManage")
func _ready():
	timer.wait_time = death_wait_time # 在 _ready() 中设置 Timer 的等待时间
	timer.one_shot = true # 确保只触发一次

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# 禁用玩家的物理处理、输入处理和视觉
		body.set_physics_process(false)
		body.set_process(false)
		body.set_process_input(false)
		body.visible = false
		# 2改变玩家的碰撞层和掩码
		# 假设你的玩家的碰撞层通常在第1层，敌人检测第1层。
		body.set_collision_mask(0)  # 让玩家不检测任何层
		# 死亡处理
		gamemanage.player_die()

		# 减慢时间
		Engine.time_scale = 0.2
		# 重新加载场景
		timer.start()


func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
