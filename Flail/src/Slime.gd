extends KinematicBody2D

const SPEED = 200

var player = null
onready var anim_sprite = $AnimatedSprite
#onready var death_ani = $DeathAni
var dead = false

func _ready():
	$Puddle.visible = false
	player = get_tree().get_nodes_in_group("player")[0]


func _physics_process(delta):
	if dead:
		return
	if player == null:
		return
	var move_dir = (player.global_position - global_position).normalized()
	
	anim_sprite.flip_h = move_dir.x > 0

	move_and_slide(SPEED*move_dir)


func _on_KillBox_body_entered(body):
	body.kill(self)

func kill():
#	queue_free()
	if dead:
		return
	dead = true
	anim_sprite.animation = "death"
	$CollisionShape2D.queue_free()
	$KillBox.queue_free()
	$Puddle.visible = true
	$Puddle.rotate(0.2-0.4*randf())
	$Puddle.flip_h = randf() < 0.5
	#$PuddleMaker.play("make_puddle")
	#anim_sprite.queue_free()
	
	$DeathSound.pitch_scale = 0.8 + 0.4*randf()
	$DeathSound.play()
#
#
#func _on_DeathAni_animation_finished(anim_name):
#	if anim_name == "death":
#		queue_free()


#func _on_DeathSound_finished():
#	queue_free()


func _on_AnimatedSprite_animation_finished():
	if anim_sprite.animation == "death":
		anim_sprite.queue_free()
