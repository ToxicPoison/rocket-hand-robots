extends CharacterBody3D

var interface : XRInterface

@onready var l_cont := $XROrigin3D/LeftHand
@onready var r_cont := $XROrigin3D/RightHand

@onready var l_stick := Vector2.ZERO
@onready var r_stick := Vector2.ZERO
@onready var l_trigger := 0.0
var l_trig_interp := 0.0

var ground_speed := 240.0
var air_speed := 0.0
var ground_friction := 0.5
var air_friction := 0.0
var rot_sensitivity := 4.0
var jump_height := 2.5

var gravity = 9.81

var thrust := 0.0 # CURRENT thrust
var max_accel := 600.0
var energy := 0.0 # CURRENT energy
var energy_max := 1.0 # How much energy we can use
var energy_loss_speed := 1.0
var firing := false
var charged := true

@onready var speed : float = ground_speed
@onready var friction : float = ground_friction

const THRUST_NODE = preload("res://player/thrust_node.tscn")
var thruster_launch_speed := 20.0
var current_thruster

func _ready() -> void:
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.is_initialized():
		print("VR on!")
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialised, please check if your headset is connected")
		
	l_cont.button_pressed.connect(l_button_pressed)
	r_cont.button_pressed.connect(r_button_pressed)


func l_button_pressed(input : String):
	pass


func r_button_pressed(input : String):
	# JUMP
	if input == "ax_button" and is_on_floor():
		velocity += Vector3(0.0, jump_height, 0.0)
	if input == "by_button":
		if !current_thruster:
			current_thruster = THRUST_NODE.instantiate()
			get_tree().root.add_child(current_thruster)
			current_thruster.player_controller = r_cont
			current_thruster.global_position = r_cont.global_position
			current_thruster.apply_impulse( -r_cont.get_global_transform().basis.z * thruster_launch_speed)
		else:
			current_thruster.destroy()


func get_input(delta) -> void:
	# WALK
	l_stick = l_cont.get_vector2("primary")
	var dir = (
		Vector3(-l_stick.y, 0.0, -l_stick.y) * l_cont.get_global_transform().basis.z
		 + Vector3(l_stick.x, 0.0, l_stick.x) * l_cont.get_global_transform().basis.x
	)
	velocity += dir * speed * delta
	velocity += Vector3(0.0, -gravity * delta * 0.5, 0.0)
	velocity *= Vector3(1.0 - (friction*delta*120.0), 1.0, 1.0 - (friction*delta*120.0))
	
	# ROTATION
	r_stick = r_cont.get_vector2("primary")
	rotate(Vector3(0.0, 1.0, 0.0), -r_stick.x * rot_sensitivity * delta)
	
	# THRUST
	l_trigger = l_cont.get_float("trigger")
	l_trig_interp = lerpf(l_trig_interp, l_trigger, 0.1)
	if l_trig_interp > 0.1 and energy < energy_max:
		
#		energy += l_trig_interp * energy_loss_speed * delta
		
		if energy >= energy_max:
			# Play end sound
			thrust = 0.0
			firing = false
			return
			
		if not firing:
			# Start particles, sound, etc.
			firing = true
			
		thrust = max_accel * l_trig_interp * delta
		velocity = -l_cont.get_global_transform().basis.z * thrust
	
	
func charge_thruster():
	energy = 0.0


func _physics_process(delta):
	if is_on_floor():
		speed = ground_speed
		friction = ground_friction
	else:
		speed = air_speed
		friction = air_friction
	get_input(delta)
	move_and_slide()
