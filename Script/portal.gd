# Portal.gd
extends Area2D

@export var target_portal_path: NodePath # 目标传送门的NodePath
@export var is_one_way: bool = false 
@export var target_scene_path: String = ""
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $"../ScreenFade/AnimationPlayer"

var player_in_range = false
var player_node: CharacterBody2D = null # 存储进入范围的玩家节点

func _ready():
	pass
func _process(delta):
	if player_in_range and Input.is_action_just_pressed("use"):
		if player_node and player_node.is_on_floor():
			initiate_teleport(player_node)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
			player_in_range = true
			player_node = body as CharacterBody2D

			 # 显示提示

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"): 
		player_in_range = false
		player_node = null
		if has_node("InteractionPrompt"):
			$InteractionPrompt.hide() # 隐藏提示

func initiate_teleport(body_to_teleport: CharacterBody2D):
	print("Initiating teleport (One-Way)...")

	# 如果设置了目标场景路径，优先进行跨场景传送
	if not target_scene_path.is_empty():
		# 可以在这里添加一些过渡效果（例如渐隐）
		animated_sprite_2d.play("open")
		animation_player.play("fade_to_black")
		await get_tree().create_timer(0.5).timeout
		#print("Changing scene to: ", target_scene_path)
		get_tree().change_scene_to_file(target_scene_path)
		#await get_tree().create_timer(1).timeout
		animation_player.play("fade_from_black")

		return # 跨场景传送后就结束函数

	# 如果没有设置目标场景路径，则进行同场景内的传送
	if target_portal_path:
		var target_portal = get_node(target_portal_path)
		#print(123)
		if target_portal and target_portal is Area2D:
			# 传送到目标传送门的位置
			animated_sprite_2d.play("open")
			animation_player.play("fade_to_black")
			await get_tree().create_timer(0.5).timeout
			body_to_teleport.global_position = target_portal.global_position
			#print("tp ", body_to_teleport.name, " to ", target_portal.name)
			#await get_tree().create_timer(1.0).timeout
			animation_player.play("fade_from_black")
			#animated_sprite_2d.play("open")
			
