extends Camera2D

var shakeStrength : float = 0.0
var shakeFade : float = 0.0

var rng = RandomNumberGenerator.new()

func applyShake(shakeStrenghtInit : float, shakeFadeInit : float):
	#note: a higher shakeFadeInit means the shake fades faster
	
	shakeStrength = shakeStrenghtInit
	shakeFade = shakeFadeInit
	pass

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shakeStrength > 0:
		shakeStrength = lerpf(shakeStrength, 0, shakeFade * delta)
		offset = randomOffset()
	pass
