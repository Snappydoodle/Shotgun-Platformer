extends Node2D

var bulletsFired : int = 0
var timeElapsed : float = 0.0
var startTimer : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	#print(get_node("."))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print($GUI/timeElapsed.visible)
	$GUI/timeElapsed.text = "Time Elapsed: " + str(snapped(timeElapsed, 0.01))
	
	#$GUI.position.x = $Level/Camera2D.position.x - 640
	#$GUI.position.y = $Level/Camera2D.position.y - 360
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
