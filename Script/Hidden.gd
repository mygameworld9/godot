extends TileMapLayer

var player_in_secret := false
var layer_alpha := 1.0


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if player_in_secret:
		if layer_alpha > 0.3:
			layer_alpha = move_toward(layer_alpha, 0.3, delta)
			self_modulate = Color(1, 1, 1, layer_alpha)
		else:
			set_process(false)
	else:
		if layer_alpha < 1.0:
			layer_alpha = move_toward(layer_alpha, 1.0, delta)
			self_modulate = Color(1, 1, 1, layer_alpha)
		else:
			set_process(false)


func _use_tile_data_runtime_update(_coords: Vector2i) -> bool:
	return true


func _tile_data_runtime_update(_coords: Vector2i, tile_data: TileData) -> void:

	tile_data.set_collision_polygons_count(0, 0)


func _on_secret_Hidden_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		return
	
	player_in_secret = true
	set_process(true)
	for node in get_tree().get_nodes_in_group("Surprise"):
			if node is CanvasItem:
				node.visible = true 

func _on_secret_Hidden_body_exited(body: Node2D) -> void:
	if body is not CharacterBody2D:
		return

	player_in_secret = false
	set_process(true)
	for node in get_tree().get_nodes_in_group("Surprise"):
		if node is CanvasItem and not node.is_queued_for_deletion():
			node.visible = false # 隐藏节点
