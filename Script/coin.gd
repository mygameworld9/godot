extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gamemanage: CanvasLayer = $"../GameManage"
@onready var gamemanage2: CanvasLayer = $"../../GameManage"
const POP_UP_HEIGHT = 8
const POP_UP_SPEED = 300
func _ready() -> void:
	for node in get_tree().get_nodes_in_group("Coin"):#开局隐藏
		var collision_shape_node = node.get_node("CollisionShape2D")
		#collision_shape_node.disabled = false
		collision_shape_node.set_deferred("disabled", true)

func _on_body_entered(_body) :
	if get_node("../GameManage"):
		#print(233)
		gamemanage.add_point(1)	
	elif get_node("../../GameManage"):
		gamemanage2.add_point(1)
		#print(456)
	animation_player.play("pickup")
	#queue_free() 
func pop_up() -> void:
# 使金币向上弹起一小段距离，然后下落
	var tween = create_tween()
	#print("233")
	tween.tween_property(self, "position", position - Vector2(0, POP_UP_HEIGHT), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	# 播放金币弹出音效
	$AudioStreamPlayer2D.play()
	# 自动销毁 
	await tween.finished
	await get_tree().create_timer(5).timeout # 等待一段时间，让金币自然下落或消失	
	queue_free() # 销毁金币
