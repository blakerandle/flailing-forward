extends KinematicBody2D

signal killed_enemy

const INIT_SPEED = 500
const MAX_TAN_SPEED = 1200
const ACCEL = 600

var velocity = Vector2.ZERO

var angle = 0
var radius = 0
var tan_vel = 0
#var angular_vel = 0
var grabbed = false
var player = null

onready var bounce_sound = $BounceSound
onready var swish_sound = $SwishSound

#onready var sprite = $Sprite


func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	velocity = INIT_SPEED*Vector2(1,0)
	
func _physics_process(delta):
	if grabbed:
		if !swish_sound.playing and abs(tan_vel) > MAX_TAN_SPEED/2:
			swish_sound.pitch_scale = sqrt(abs(tan_vel)/MAX_TAN_SPEED)
			swish_sound.play()
		
		if tan_vel > 0:
			tan_vel += ACCEL*delta
		else:
			tan_vel -= ACCEL*delta
		tan_vel = clamp(tan_vel,-MAX_TAN_SPEED,MAX_TAN_SPEED)
		
		angle -= delta*tan_vel/radius

		velocity = Vector2(-tan_vel*cos(angle+PI/2),tan_vel*sin(angle+PI/2))

		var collision_object = move_and_collide(velocity * delta)
		
		$Chain.points[0] = (player.get_grab_position() - global_position)
		
		if collision_object:
			velocity = velocity.bounce(collision_object.normal)
			bounce_sound.play()
			release()
	else:
		var collision_object = move_and_collide(velocity * delta)
		if collision_object:
			velocity = velocity.bounce(collision_object.normal)
			bounce_sound.play()
			#sprite.rotation_degrees = rad2deg(collision_object.normal.angle())
func start_grab(p):
	grabbed = true
	
	#player = p
	
	radius = global_position.distance_to(player.get_grab_position())
	angle = atan2(player.get_grab_position().y-global_position.y,global_position.x-player.get_grab_position().x)
	
	tan_vel = velocity.length()*cos(angle + velocity.angle() - PI/2)
	
func release():
	grabbed = false
	$Chain.points[0] = Vector2.ZERO
	#velocity.x = -tan_vel*cos(angle+PI/2)
	#velocity.y = tan_vel*sin(angle+PI/2)


func _on_KillBox_body_entered(body):
	if !grabbed:
		velocity *= 0.8
	if body != player:
		emit_signal("killed_enemy")
		body.kill()
	else:
		body.kill(self)

#
#func _on_KillBox_area_entered(area):
#	area.get_parent().kill(self)
