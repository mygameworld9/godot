extends Node

var score = 0
@onready var game_manage: CanvasLayer = $"."
@onready var score_label: Label = $ScoreLabel
@onready var die: Label = $Die



func spawn_coin(pos: Vector2):
	var coin = preload("res://background/Coin.tscn").instantiate()
	get_tree().current_scene.add_child(coin)
	coin.global_position = pos
func point():#计分
	score_label.text = "当前分数：" + str(score) 
func add_point(value):
	score += value#添加分数
	score_label.text = "当前分数：" + str(score) 
func player_die():
	die.text = "YOU ARE DIE！"#死亡信息
