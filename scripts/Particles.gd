extends GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	one_shot = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	queue_free()
