extends Resource

static func percentageOf(a: float, b: float) -> float:
	if a == 0 and b == 0:
		return 0
	else:
		return a / (a + b)
		
static func roundDecimal(num: float, dec_places: float = .01) -> float:
	var output = roundf(num * (1 / dec_places)) * dec_places
	if abs(output) <= (dec_places * 2): # x2 is to remove floating point errors
		return 0
	else:
		return output 

static func roundVector(vec: Vector2, dec_places: float = .01) -> Vector2:
	return Vector2(roundDecimal(vec.x, dec_places), roundDecimal(vec.y, dec_places))
