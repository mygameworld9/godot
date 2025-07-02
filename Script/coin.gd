extends Area2D

@onready var gamemanage: CanvasLayer = $"../GameManage"
const POP_UP_HEIGHT = 5
const POP_UP_SPEED = 300.0
func _on_body_entered(_body) :
	gamemanage.add_point()
	queue_free()
func pop_up() -> void:
# 使金币向上弹起一小段距离，然后下落
	var tween = create_tween()
	
	tween.tween_property(self, "position", position - Vector2(0, POP_UP_HEIGHT), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	# 稍作停留，然后落下（通常在 Coin.gd 内部处理）
	# tween.tween_property(self, "position", position + Vector2(0, POP_UP_HEIGHT * 2), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	# 播放金币弹出音效（假设您有一个 AudioStreamPlayer2D 节点）
	# $AudioStreamPlayer2D.play()
	# 金币弹出后，让它在短时间后自动销毁 (如果不是立即拾取)
	await tween.finished
	await get_tree().create_timer(5).timeout # 等待一段时间，让金币自然下落或消失
	queue_free() # 销毁金币
