extends RigidBody3D

const POINT_VISUAL = preload("res://levels/test/point_visual.tscn")

var force = 15.0
var player_controller
var affector
var attached := false
@onready var thrust_visual := $Thrust


func _ready():
	self.body_entered.connect(_on_body_entered)
	
	await get_tree().create_timer(2.0).timeout
	if not attached:
		queue_free()

func destroy():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("movable"):
		$CollisionShape3D.set_deferred("disabled", true)
		call_deferred("reparent", body)
#		reparent(body, true)
		freeze = true
		attached = true
		affector = body

func _physics_process(delta):
	if player_controller and attached:
		thrust_visual.global_rotation = player_controller.global_rotation
		var thrust : float = player_controller.get_float("trigger")
		if thrust > 0.1:
#			affector.apply_force(-player_controller.get_global_transform().basis.z * force, position)
			affector.apply_central_force(-player_controller.get_global_transform().basis.z * force)
