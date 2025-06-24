extends Node3D

var bulletsFired : int = 0
var timeElapsed : float = 0.0
var startTimer : bool = false

var specialTilesDict : Dictionary

@onready var tileMap = $MainSubviewport/CanvasLayer/Main/TileMap
@onready var tileMapBackground = tileMap.get_node("Background")
@onready var tileMapInterractable = tileMap.get_node("Interractable")
@onready var player = $MainSubviewport/CanvasLayer/Player
@onready var viewportCenter : Vector2 = get_viewport().get_visible_rect().size / 2

const SPRING = preload("res://scripts/SpecialObjects/Spring/Spring.tscn")
const TILESET_LIB = preload("res://scripts/Libraries/TilesetLib.gd")

@export var specialTilesPath = "res://scripts/SpecialObjects/"

# Called when the node enters the scene tree for the first time.
func _ready():
	preloadSpecialTiles()
	evaluateTileMap()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$GUI/timeElapsed.text = "Time Elapsed: " + str(snapped(timeElapsed, 0.01))
	var mousePosition = get_viewport().get_mouse_position()
	player.mousePlayerAngle = mousePosition.angle_to_point(viewportCenter)
	pass

func preloadSpecialTiles():
	var dir = DirAccess.open(specialTilesPath)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
				var scenePath = str(specialTilesPath, file_name, "/", file_name, ".tscn")
				specialTilesDict[file_name] = load(scenePath)
				
				
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	print(specialTilesDict)
func evaluateTileMap():
	#evaluates all tiles in the Interractable TileMapLayer. Used to place animated tiles where needed
	
	#gets list of all tiles
	var tileMapLayerList = tileMapInterractable.get_used_cells()
	
	#repeats for every tile
	for i in range(tileMapLayerList.size()):
		
		#gets the selected tile data
		var targetedTile = tileMapLayerList[i]
		var tileData = tileMapInterractable.get_cell_tile_data(targetedTile)
		
		var interactableType = tileData.get_custom_data_by_layer_id(0)
		var hideTile = tileData.get_custom_data("hideTile")
		var extraData = tileData.get_custom_data("ExtraData")
		var dirVec = TILESET_LIB.get_direction_vector(tileMapInterractable,targetedTile) #gets direction vector
		var tileRot = TILESET_LIB.direction_vec_to_rotation(dirVec) #gets rotation of tile
		
		var varsDict : Dictionary
		varsDict["dirVec"] = dirVec
		varsDict["extraData"] = extraData
		
		if hideTile:
			tileData.modulate.a = 0
		
		#creates a spring object facing correct direction for all tiles with "spring" in their name
		
		if specialTilesDict.has(interactableType):
			if interactableType != "":
				createSpecialTile(interactableType, targetedTile, tileRot, varsDict)
			pass
		#if interactableType.substr(0, 6) == "Spring":
			#createSpring(targetedTile, tileRot)
			
		pass
		
func createSpecialTile(interactableType: String, targetedTile: Vector2i, tileRot: float, varsDict : Dictionary):
	#creates special tile and parents it to Level node
	var tileType = specialTilesDict[interactableType]
	var tile = tileType.instantiate()
	tileMap.add_child(tile)
			
	#sets postition of tile
	tile.position.x = targetedTile.x * tileMapInterractable.tile_set.tile_size.x + (tileMapInterractable.tile_set.tile_size.x / 2)
	tile.position.y = targetedTile.y * tileMapInterractable.tile_set.tile_size.y + (tileMapInterractable.tile_set.tile_size.y / 2)
			
	#sets rotation of tile 
	tile.rotation = tileRot
	
	tile.varsDict = varsDict
	tile.onCreated()

func _on_player_goal_touched():
	showGoalScreen()
	print("GOAALL")

func showGoalScreen():
	get_tree().paused = true
	$GUI/GoalScreen/TimeElapsed.text = "Time: " + str(snapped(timeElapsed, 0.01))
	$GUI/GoalScreen/BulletsFired.text = "Bullets Fired: " + str(bulletsFired)
	$GUI/GoalScreen.visible = true
	pass

func _on_gui_level_select():
	print("sdfdsf")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Levels/levelSelect.tscn")
	pass # Replace with function body.
