extends Node

var score = 0
@onready var score_label: Label = $"Score Label"
@onready var fuel_label: Label = $"Fuel Label"
@onready var player: CharacterBody2D = $"../../Player"
@onready var win: Label = $Win

func add_point():
	score += 1
	score_label.text = "Coins: " + str(score) + "/20"
	if score == 20:
		player.kill()
		win.visible = true

func change_fuel(value):
	fuel_label.text = "Fuel: " + str(int(value)) + " %"
