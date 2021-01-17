extends Control


const SCORE_PATH = "user://highscore.data"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("quit"):
		_on_QuitButton_pressed()
	
	if Input.is_action_pressed("restart"):
		_on_RetryButton_pressed()


func _on_RetryButton_pressed():
	get_tree().change_scene("res://src/World.tscn")
	

func _on_QuitButton_pressed():
	get_tree().quit()

func set_points(n):
	$Points.text = "Score: " + str(n)

func set_killed_by_sprite(tex):
	$Killer.texture = tex
