extends Node
@onready var gamemanage: CanvasLayer = $"."
@onready var score_label: Label = $scoreLabel
@onready var die: Label = $die
var score = 0



func spawn_coin(pos: Vector2):
	var coin = preload("res://background/Coin.tscn").instantiate()
	get_tree().current_scene.add_child(coin)
	coin.global_position = pos
func point():
	score_label.text = "当前分数：" + str(score) 
func add_point():
	score += 1
	score_label.text = "当前分数：" + str(score) 
func player_die():
	die.text = "YOU ARE DIE！"
