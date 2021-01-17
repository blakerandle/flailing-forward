extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("escape"):
		get_tree().quit()
	elif Input.is_action_pressed("start"):
		_on_StartButton_pressed()


func _on_StartButton_pressed():
	$FadeTransition.play("fade")
	$Fade.visible = true


func _on_FadeTransition_animation_finished(anim_name):
	if anim_name == "fade":
		get_tree().change_scene("res://src/World.tscn")
