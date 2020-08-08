extends Node

var highscore = 0
var popularity = 0
var police_called = false

export var police_countdown = 10
export(String, FILE) var gamer_over_ui_path = "res://UI/GameOver/GameOver.tscn"
export(String, FILE) var police_countdown_ui_path = "res://UI/PoliceCountdown/PoliceCountdown.tscn"

var _police_countdown_ui
var _gamer_over_ui

func call_the_police():
	if police_called:
		return
	_police_countdown_ui = load(police_countdown_ui_path).instance()
	get_tree().get_root().call_deferred("add_child",_police_countdown_ui)
	$ThePoliceTimer.start(police_countdown)
	police_called = true

func game_over():
	_gamer_over_ui = load(gamer_over_ui_path).instance()
	get_tree().get_root().add_child(_gamer_over_ui)

func _on_ThePoliceTimer_timeout():
	game_over()
	_police_countdown_ui.queue_free()
