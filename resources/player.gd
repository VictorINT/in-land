extends KinematicBody2D

#constante
const FRICTION = 500
const ACCELERATION = 500
const MAX_SPEED = 80

#variabile
onready var simultaneous_scene = load("res://casa_inside.tscn")
var selectedItem
var item
var velocity = Vector2.ZERO
var attackState = null

#functii
func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = move_and_slide(velocity)
	if velocity.x < 0:
		$Sprite.flip_h = true
		if selectedItem != null:
			selectedItem.get_node("Sprite").flip_h = true
	elif velocity.x > 0:
		$Sprite.flip_h = false
		if selectedItem != null:
			selectedItem.get_node("Sprite").flip_h = false
		
	if Input.is_action_just_pressed("pick") and item != null:
		selectedItem = item
		$Position2D/RemoteTransform2D.remote_path = selectedItem.get_path()
		
	if Input.is_action_just_pressed("drop") and selectedItem != null:
		$Position2D/RemoteTransform2D.remote_path = ""
		selectedItem = null
	
	if Input.is_action_just_pressed("interact"):
		_add_a_scene_manually()

func _on_Area2D_body_entered(body):
	item = body

func _on_Area2D_body_exited(body):
	item = null
	
func _add_a_scene_manually():
	get_tree().change_scene_to(simultaneous_scene)
