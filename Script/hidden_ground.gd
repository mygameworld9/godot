extends TileMapLayer

var player_in_secret := false
var layer_alpha := 1.0
@onready var hidden_ground: TileMapLayer = $"."

func _ready() -> void:
	set_process(true)
#func _process(delta: float) -> void:
	#pass
func _use_tile_data_runtime_update(_coords: Vector2i) -> bool:
	return true
var Flag = 0

#func _tile_data_runtime_update(_coords: Vector2i, tile_data: TileData) -> void:
	#pass
	#tile_data.set_collision_polygons_count(0, 0)


func _on_secret_Hidden2_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		#print(233)
		return
	#print(123)
	player_in_secret = true
	set_process(true)
	for node in get_tree().get_nodes_in_group("Coin"):
			if node is CanvasItem and Flag == 0:
				Flag += 1
				var collision_shape_node = node.get_node("CollisionShape2D")
				#collision_shape_node.disabled = false
				collision_shape_node.set_deferred("disabled", false)
				node.visible = true 
				node.pop_up() #弹金币
				hidden_ground.visible = false
func _on_secret_Hidden2_body_exited(body: Node2D) -> void:
	if body is not CharacterBody2D:
		return

	#player_in_secret = false
	#set_process(true)
	#for node in get_tree().get_nodes_in_group("Coin"):
		#if node is CanvasItem and not node.is_queued_for_deletion():
			#node.visible = false # 隐藏节点
