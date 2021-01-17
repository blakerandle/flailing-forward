extends KinematicBody2D

signal died

const MAX_SPEED = 700
const ACCEL = 3000

const FRICTION_MULT = 1.5

const GRAB_RANGE = 224 #was 200

const DELTA_POINTS = 10
const ENEMY_POINTS = 100

var points = 0

var velocity = Vector2.ZERO

var ball = null
var grabbing_ball = false

onready var anim_sprite = $AnimatedSprite
onready var circle_indicator = $GrabPoint/CircleIndicator
onready var points_label = $Label
onready var sound_footstep = $Footstep
onready var grab_point = $GrabPoint
onready var grab_timer = $GrabTimer
onready var sweat_particles = $Sweat

func _ready():
	ball = get_tree().get_nodes_in_group("ball")[0]
	circle_indicator.scale = Vector2((GRAB_RANGE-24)/203.0,(GRAB_RANGE-24)/203.0)
	sweat_particles.emitting = false

func _physics_process(delta):
	points += delta*DELTA_POINTS
	
	#circle_indicator.modulate.a = 20000/((ball.global_position-grab_point.global_position).length_squared())
	circle_indicator.modulate.a = 100/((ball.global_position-grab_point.global_position).length())
	
	if Input.is_action_pressed("grab_ball"):
		if !grabbing_ball and $RechargeTimer.time_left == 0:
			attempt_ball_grab()
	elif grabbing_ball:
		release_ball()
	
	if grabbing_ball:
		velocity = Vector2.ZERO
	else:
		var move_dir = Vector2.ZERO
		if Input.is_action_pressed("move_up"):
			move_dir.y-=1
		if Input.is_action_pressed("move_down"):
			move_dir.y+=1
		if Input.is_action_pressed("move_left"):
			move_dir.x-=1
		if Input.is_action_pressed("move_right"):
			move_dir.x+=1
		move_dir = move_dir.normalized()
		
		if move_dir == Vector2.ZERO:
			apply_friction(ACCEL * FRICTION_MULT * delta)
		else:
			apply_movement(move_dir * ACCEL * delta)
		
		velocity = move_and_slide(velocity)
		
	update_animation()
	
	if grab_timer.time_left <= 1 and grabbing_ball:
		sweat_particles.emitting = true
	else:
		sweat_particles.emitting = false
	
func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= amount*velocity.normalized()
	else:
		velocity = Vector2.ZERO

func apply_movement(accel):
	velocity += accel
	velocity = velocity.clamped(MAX_SPEED)
	
func attempt_ball_grab():
	if ball == null:
		return
	if grab_point.global_position.distance_to(ball.global_position) <= GRAB_RANGE:
		$GrabTimer.start()
		grabbing_ball = true
		ball.start_grab(self)
		
		
#func update_camera():
#	camera.offset = 0.1*(ball.global_position - global_position)

func kill(what_killed):
	#get_tree().reload_current_scene()
	#TODO Add animation
	emit_signal("died",what_killed)

func release_ball():
	ball.release()
	grabbing_ball = false
	$RechargeTimer.start()

func _on_GrabTimer_timeout():
	if grabbing_ball:
		$ChainBreak.play()
		release_ball()

func update_animation():
	if velocity.length() > 1:
		anim_sprite.animation = "walk"
		anim_sprite.flip_h = velocity.x < 0
	elif anim_sprite.animation != "blink":
		if grabbing_ball:
			anim_sprite.animation = "grabbing"
		else:
			anim_sprite.animation = "idle"
		

func _on_BlinkTimer_timeout():
	if anim_sprite.animation == "idle":
		anim_sprite.animation = "blink"

func get_grab_position():
	return grab_point.global_position

func _on_AnimatedSprite_animation_finished():
	if anim_sprite.animation == "blink":
		anim_sprite.animation = "idle"

func _on_SpikeBall_killed_enemy():
	points += ENEMY_POINTS


func _on_AnimatedSprite_frame_changed():
	if anim_sprite.animation == "walk" and (anim_sprite.frame == 3 or anim_sprite.frame == 7):
		if !sound_footstep.is_playing():
			sound_footstep.pitch_scale = 0.9+0.2*randf()
			sound_footstep.play()
