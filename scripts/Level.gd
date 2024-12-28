extends Node2D

var bulletsFired : int = 0
var timeElapsed : float = 0.0
var startTimer : bool = false

@onready var tileMap = $Level/TileMap
@onready var tileMapBackground = $Level/TileMap/Background
@onready var tileMapInterractable = $Level/TileMap/Interractable

var SPRING = preload("res://scripts/Spring.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	evaluateTileMap()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$GUI/timeElapsed.text = "Time Elapsed: " + str(snapped(timeElapsed, 0.01))
	pass
	
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
		
		#creates a spring object facing correct direction for all tiles with "spring" in their name
		if interactableType.substr(0, 6) == "Spring":
			
			#creates spring object and parents it to Level node
			var spring = SPRING.instantiate()
			$Level.add_child(spring)
			
			#sets postition of spring
			spring.position.x = targetedTile.x * tileMapInterractable.tile_set.tile_size.x + (tileMapInterractable.tile_set.tile_size.x / 2)
			spring.position.y = targetedTile.y * tileMapInterractable.tile_set.tile_size.y + (tileMapInterractable.tile_set.tile_size.y / 2)
			
			#sets rotation of spring (default rotation is up)
			match interactableType:
				"SpringRight":
					spring.rotation = PI / 2
				"SpringDown":
					spring.rotation = PI
				"SpringLeft":
					spring.rotation = - PI / 2
		pass

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
