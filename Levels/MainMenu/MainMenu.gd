extends Node


func _ready() -> void:
	var animationPlayer = get_node("character/AnimationPlayer")
	animationPlayer.get_animation("idle").loop = true
	animationPlayer.play("idle", -1, 1)

func _on_PlayButton_pressed() -> void:
	get_tree().change_scene("res://Levels/House/House.tscn")
