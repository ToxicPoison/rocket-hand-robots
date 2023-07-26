extends XRController3D

@onready var raycast : Object = $RayCast3D
@onready var area : Object = $Area3D
var current_object : Object
var grabbed_object : Object

func _ready():
	self.button_pressed.connect(on_button_pressed)
	area.body_entered.connect(on_body_entered)
	area.body_exited.connect(on_body_exited)
	
func on_body_entered(body):
	if body.is_in_group("grabbable"):
		current_object = body
	
func on_body_exited(body):
	if body == current_object:
		current_object = null
	
func on_button_pressed(input : String):
	if input == "grip_click" and current_object:
		grabbed_object = current_object
		grabbed_object.grabber = self
		grabbed_object.grabbed = true
		print(grabbed_object.grabbed)
		
func on_button_released(input : String):
	if input == "grip_click" and grabbed_object:
		grabbed_object.grabbed = false
		grabbed_object.grabber = null
		grabbed_object = null

#func _physics_process(delta):
#	if is_button_pressed("grip_click") and raycast.get_collider():
#		var obj = raycast.get_collider()
#		if obj.is_in_group("grabbable"):
#			var direction : Vector3 = obj.global_position.direction_to(raycast.global_position)
#			var distance : float = obj.global_position.distance_to(raycast.global_position)
#			if distance > 0.0:
#				obj.apply_central_force(direction * (1.0 / sqrt(distance)) * 20.0)
			
