# 例如，这是一个名为 game.gd 的主场景脚本
extends Node2D # 或者你的主场景根节点的类型
@onready var mainground: TileMapLayer = $MainGround

var mouse_hide_timer: Timer
var mouse_hidden = false
var mouse_inactive_timeout = 2.0 # 鼠标不活动多久后隐藏 (秒)

func _ready():
	# 创建一个计时器
	mouse_hide_timer = Timer.new()
	add_child(mouse_hide_timer)
	mouse_hide_timer.wait_time = mouse_inactive_timeout
	mouse_hide_timer.one_shot = true # 只计时一次
	mouse_hide_timer.autostart = false
	mouse_hide_timer.connect("timeout", _on_mouse_hide_timeout)

	# 初始状态显示鼠标
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	# 监听鼠标移动
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tile_map_data()
	if event is InputEventMouseMotion:
		# 鼠标移动了，如果之前隐藏了，就显示
		if mouse_hidden:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_hidden = false
		# 重置计时器
		mouse_hide_timer.stop()
		mouse_hide_timer.start()
func get_tile_map_data():
	var mouse_position = get_global_mouse_position()
	var	tile_coordinate = mainground.local_to_map(mouse_position)
	var clicked_cell = mainground.local_to_map(mainground.get_local_mouse_position())
	var data = mainground.get_cell_tile_data(clicked_cell)
	if data:
		if data.get_custom_data("coin"):
			print(233)
		else:
			print(123)
	pass
func _on_mouse_hide_timeout():
	# 计时器超时，表示鼠标长时间不活动，隐藏鼠标
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	mouse_hidden = true
