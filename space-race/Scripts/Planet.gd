extends SpaceObject

class_name Planet

var gravity_constant: float = 6.67430e-11  # Gravitational constant

# Constructor
func _init(name: String, pos: Vector2, radius: float, texture: Texture, mass : float) -> void:
	super(name, pos, radius, true, texture)
	mass = mass

# Gravity calculation (this is just a placeholder for the formula)
func calculate_gravity(other_object: SpaceObject) -> float:
	if exerts_gravity:
		var distance = position.distance_to(other_object.position)
		return gravity_constant * (radius * other_object.radius) / (distance * distance)
	return 0.0

# Rotation logic (for rotating planets)
func _process(delta: float) -> void:
	# Rotate the planet by a certain amount each frame
	pass
	
