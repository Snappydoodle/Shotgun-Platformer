extends Node2D

var bulletsFired : int = 0
var timeElapsed : float = 0.0
var startTimer : bool = false

@onready var tileMap = $Level/TileMap

var SPRING = preload("res://scripts/Spring.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	print($Level/TileMap)
	evaluateTileMap()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print($GUI/timeElapsed.visible)
	$GUI/timeElapsed.text = "Time Elapsed: " + str(snapped(timeElapsed, 0.01))
	#print($Level/TileMap.local_to_map(Vector2(30, 50)))
	#$GUI.position.x = $Level/Camera2D.position.x - 640
	#$GUI.position.y = $Level/Camera2D.position.y - 360
	pass
	
func evaluateTileMap():
	#var springTileSetId = tileMap.get_cell_atlas_coords(0, Vector2(0, 12))
	#var tile_set: TileSet = tileMap.tile_set
	#tile_set.tile_set_modulate(springTileSetId, Color(100,100,100,0))
	#tileMap.set_layer_modulate(0, Color(0, 0, 0, 0))
	var tileMapList = tileMap.get_used_cells(0)
	for i in range(tileMapList.size() - 1):
		var targetedTile = tileMapList[i]
		var tileData = tileMap.get_cell_tile_data(0, targetedTile)
		var interactableType = tileData.get_custom_data_by_layer_id(0)
		print(interactableType)
		if interactableType.substr(0, 6) == "Spring":
			var spring = SPRING.instantiate()
			$Level.add_child(spring)
			spring.position.x = targetedTile.x * tileMap.tile_set.tile_size.x + (tileMap.tile_set.tile_size.x / 2)
			spring.position.y = targetedTile.y * tileMap.tile_set.tile_size.y + (tileMap.tile_set.tile_size.y / 2)
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

