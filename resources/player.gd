extends KinematicBody2D

#constante
const FRICTION = 500
const ACCELERATION = 500
const MAX_SPEED = 80

#variabile
export var inHouse = false		#sa tin minte daca sunt in casa sau sunt afara pe parcursul scenelor
onready var simultaneous_scene = load("res://casa_inside.tscn")		#variabila cu scena casei interioare
onready var main_scene = load("res://world.tscn")		#variabila cu scena lumii main
#sistem pentru pick up items
var onEntered = false
var selectedItem
var item
#vector de miscare
var velocity = Vector2.ZERO

#functii
#functie de miscare si de input uri de la tastatura
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
			selectedItem.inverted = true
	elif velocity.x > 0:
		$Sprite.flip_h = false
		if selectedItem != null:
			selectedItem.inverted = false
		
	if Input.is_action_just_pressed("pick") and item != null:
		selectedItem = item
		$Position2D/RemoteTransform2D.remote_path = selectedItem.get_path()
		
	if Input.is_action_just_pressed("drop") and selectedItem != null:
		$Position2D/RemoteTransform2D.remote_path = ""
		selectedItem = null
	
	if Input.is_action_just_pressed("interact") and onEntered == true:
		_add_a_scene_manually()

#functie semnal care se aplica atunci cand raza din jurul player ului intra in contact cu un collision shape pentru interactiune
func _on_Area2D_body_entered(body):
	item = body
	onEntered = true
	
#functie semnal ca mai sus, dar pentru iesire
func _on_Area2D_body_exited(_body):
	item = null
	onEntered = false
	
#functie care schimba scena
func _add_a_scene_manually():
	if inHouse == false:
		inHouse = true
# warning-ignore:return_value_discarded
		get_tree().change_scene_to(simultaneous_scene)
	elif inHouse == true:
		inHouse = false
# warning-ignore:return_value_discarded
		get_tree().change_scene_to(main_scene)
