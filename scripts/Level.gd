extends Node2D

var bulletsFired : int = 0
var timeElapsed : float = 0.0
var startTimer : bool = false

var specialTilesDict : Dictionary

@onready var tileMap = $Level/TileMap
@onready var tileMapBackground = $Level/TileMap/Background
@onready var tileMapInterractable = $Level/TileMap/Interractable

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
	$GUI/timeElapsed.text = "Time Elapsed: " + str(snapped(timeElapsed, 0.01))
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
	for i in range(tileMapLayerList.size() - 1):
		
		#gets the selected tile data
		var targetedTile = tileMapLayerList[i]
		var tileData = tileMapInterractable.get_cell_tile_data(targetedTile)
		
		var interactableType = tileData.get_custom_data_by_layer_id(0)
		var hideTile = tileData.get_custom_data("hideTile")
		var dirVec = TILESET_LIB.get_direction_vector(tileMapInterractable,targetedTile) #gets direction vector
		var tileRot = TILESET_LIB.direction_vec_to_rotation(dirVec) #gets rotation of tile
		
		if hideTile:
			tileData.modulate.a = 0
		
		#creates a spring object facing correct direction for all tiles with "spring" in their name
		
		if interactableType != "":
			createSpring(targetedTile, tileRot)
		#if interactableType.substr(0, 6) == "Spring":
			#createSpring(targetedTile, tileRot)
			
		pass
		
func createSpring(targetedTile: Vector2i, tileRot: float):
	#creates spring object and parents it to Level node
	var spring = SPRING.instantiate()
	$Level.add_child(spring)
			
	#sets postition of spring
	spring.position.x = targetedTile.x * tileMapInterractable.tile_set.tile_size.x + (tileMapInterractable.tile_set.tile_size.x / 2)
	spring.position.y = targetedTile.y * tileMapInterractable.tile_set.tile_size.y + (tileMapInterractable.tile_set.tile_size.y / 2)
			
	#sets rotation of spring 
	spring.rotation = tileRot
	

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
