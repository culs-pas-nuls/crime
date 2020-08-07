extends Control

func _process(_delta):
	var _countdown = ceil(GM.get_node("ThePoliceTimer").time_left)
	$CanvasLayer/PCLabel.text = str(_countdown)
