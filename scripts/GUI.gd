extends CanvasLayer
signal levelSelect

# Called when the node enters the scene tree for the first time.
func _ready():
	
	preload("res://assets/GUI/Spining Small GEar-sheet.png")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_level_select_pressed():
	levelSelect.emit()
	pass # Replace with function body.
