extends Node2D
const WIDTH = 1920
const HEIGHT = 1080

var slime_scene = load("res://src/Slime.tscn")
var death_scene = load("res://src/RetryScreen.tscn")
var rng = RandomNumberGenerator.new()

onready var slime_folder = $Slimes
onready var player = $Player
onready var points_label = $UI/Points

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	spawn_slime()
	get_tree().paused = true

func _on_EnemySpawn_timeout():
	$EnemySpawn.wait_time *= 0.95
	spawn_slime()
	
func _physics_process(delta):
	points_label.text = "Score: " + str(int(player.points))

func spawn_slime():
	var slime = slime_scene.instance()
	match rng.randi_range(0,3):
		0:
			slime.global_position.x = WIDTH/2
			slime.global_position.y = 0
		1:
			slime.global_position.x = WIDTH/2
			slime.global_position.y = HEIGHT
		2:
			slime.global_position.x = 0
			slime.global_position.y = HEIGHT/2
		3:
			slime.global_position.x = WIDTH
			slime.global_position.y = HEIGHT/2
	slime_folder.add_child(slime)


func _on_Player_died(killed_by):
	#get_tree().change_scene("res://src/RetryScreen.tscn")
	get_tree().paused = true
	$UI/ColorRect.color.a = 0.5
	
	var new_scene = death_scene.instance()
	new_scene.set_points(int($Player.points))
	
	if killed_by.is_in_group("ball"):
		new_scene.set_killed_by_sprite(load("res://assets/images/spike_ball.png"))
	
	$UI.add_child(new_scene)
	$UI/Points.queue_free()

func remove_fade():
	$UI/InitialFade.queue_free()
	$UI/HoldSpace.queue_free()
