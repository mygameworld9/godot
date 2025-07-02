extends Area2D

@onready var timer: Timer = $Timer
#@onready var game_manage: CanvasLayer = %GameManage

@onready var death_wait_time = 0.25 # 定义一个变量来方便修改等待时间
@onready var gamemanage: CanvasLayer = get_node("/root/Game/GameManage")
func _ready():
	timer.wait_time = death_wait_time # 在 _ready() 中设置 Timer 的等待时间
	timer.one_shot = true # 确保只触发一次

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# 1. 禁用玩家的物理处理、输入处理和视觉
		body.set_physics_process(false)
		body.set_process(false)
		body.set_process_input(false)
		body.visible = false
		# 2. 改变玩家的碰撞层和掩码
		# 假设你的玩家的碰撞层通常在第1层，敌人检测第1层。
		# 我们可以将玩家的第1层禁用，或者将它的掩码设置为不检测任何层。
		# 你需要在项目设置 -> 2D Physics -> Layer Names 中查看你的层定义。
		#body.set_collision_layer(0) # 将玩家从所有层中移除（设为0表示不在任何层）
		#animated_sprite_2d.play("die")
		body.set_collision_mask(0)  # 让玩家不检测任何层
		# 或者更精确地，只移除或禁用与敌人相关的层：
		# body.set_collision_layer_value(your_player_layer_index, false) # 禁用玩家所在的某个特定层
		# body.set_collision_mask_value(your_enemy_layer_index, false)  # 让玩家不再检测敌人所在的层
		# 3. 调用 CanvasLayer 的死亡处理
		gamemanage.player_die()

		# 4. 减慢时间
		Engine.time_scale = 0.2
		# 5. 启动计时器，在一段时间后重新加载场景
		timer.start()


func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
