extends RigidBody3D

var grabber : Object
var grabbed : bool = false
var initial_offset : Vector3 = Vector3.ZERO

func _integrate_forces(state):
	if grabbed:
		state.set
		print("we're moving it RIGHT NOW!")
		
