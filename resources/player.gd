extends KinematicBody2D

#constante
const FRICTION = 500
const ACCELERATION = 500
const MAX_SPEED = 80

#Location System
enum Location{
	OUTSIDE,
	INSIDE_HOUSE
}
export(Location) var whereTheFuckIAm = Location.OUTSIDE #Variabila care retine unde sunt

#variabile
onready var inside_house = load("res://casa_inside.tscn")		#variabila cu scena casei interioare
onready var main_scene = load("res://world.tscn")		#variabila cu scena lumii main
#sistem pentru pick up items
var onEntered = false
var selectedItem
var item
#vector de miscare
var velocity = Vector2.ZERO

#functii

func _ready():
	if PlayerSkeleton.playerLocation == null:
		PlayerSkeleton.playerLocation = whereTheFuckIAm;
	else:
		whereTheFuckIAm = PlayerSkeleton.playerLocation;
		
	if whereTheFuckIAm == Location.OUTSIDE and PlayerSkeleton.comingFromInside:
		global_position = Vector2(85, 60)
	PlayerSkeleton.comingFromInside = false

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
		
	if Input.is_action_just_pressed("UiAcces"):
		toggle_inventory() 
		
	#CODUL LUI RARES :))
	if Input.is_action_just_pressed("interact") and $houseDetector.get_overlapping_areas().size()>0:
		if whereTheFuckIAm == Location.INSIDE_HOUSE:
# warning-ignore:return_value_discarded
			get_tree().change_scene_to(main_scene)
			whereTheFuckIAm = Location.OUTSIDE
			PlayerSkeleton.playerLocation = Location.OUTSIDE
			PlayerSkeleton.comingFromInside = true
		elif whereTheFuckIAm == Location.OUTSIDE:
# warning-ignore:return_value_discarded
			get_tree().change_scene_to(inside_house)
			whereTheFuckIAm = Location.INSIDE_HOUSE
			PlayerSkeleton.playerLocation = Location.INSIDE_HOUSE


#functie semnal care se aplica atunci cand raza din jurul player ului intra in contact cu un collision shape pentru interactiune
func _on_Area2D_body_entered(body):
	item = body
	
#functie semnal ca mai sus, dar pentru iesire
func _on_Area2D_body_exited(_body):
	item = null

func toggle_inventory():
	$InventoryUI/Inventory.visible = !$InventoryUI/Inventory.visible
	return $InventoryUI/Inventory.visible
