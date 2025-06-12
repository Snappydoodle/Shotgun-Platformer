extends Node2D

@onready var player = get_parent().get_parent().get_parent()

const TILESET_LIB = preload("res://scripts/Libraries/TilesetLib.gd")

var magnitude : float = 10

@export var greenSpeed : float = 20
@export var yellowSpeed : float = 40
@export var redSpeed : float = 60

var color : int = 0
var dirVec : Vector2 = Vector2(0,0)

var isInConveyor : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	isInConveyor = false
	player.enableGroundResistance = true
	for i in player.get_node("InteractableDetection").get_overlapping_areas():
		
		if i.name == "ConveyorHitbox":
			isInConveyor = true
			player.enableGroundResistance = false
	
	if isInConveyor:
		player.extraVelocity.x += magnitude * dirVec.x
		player.extraVelocity.y += magnitude * dirVec.y
	#print(player.shootBullets(1,1))
	pass
	
func playerCollided(varsDict: Dictionary):
	
	dirVec = varsDict["dirVec"]
	
	if varsDict["extraData"].has("Magnitude"):
		magnitude = varsDict["extraData"]["Magnitude"]
	else:
		if varsDict["extraData"].has("Color"):
			color = varsDict["extraData"]["Color"]
		
		if color == 1:
			magnitude = yellowSpeed
		elif color == 2:
			magnitude = redSpeed
		else:
			magnitude = greenSpeed
	
	isInConveyor = true
	player.enableGroundResistance = false
	

	
func playerExited(varsDict: Dictionary):
	#print(player.get_node("InteractableDetection").get_overlapping_areas())
	
			
	#
	#var tileMapLayer : TileMapLayer = varsDict["body"]
	#var tileData = TILESET_LIB.getTileData(tileMapLayer, tileMapLayer.local_to_map(player.position))
	#
	#if tileData == null or tileData.get_custom_data_by_layer_id(0) != "Conveyor":
		#isInConveyor = false
		#player.disableGroundResistance = false
		
	pass
