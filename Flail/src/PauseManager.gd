extends Node

var started = false
func _physics_process(delta):
	if !started and Input.is_action_pressed("grab_ball"):
		get_tree().paused = false
		started = true
		get_parent().remove_fade()
		get_parent().get_node("BackgroundMusic").play()
	if Input.is_action_pressed("escape"):
		get_tree().quit()
