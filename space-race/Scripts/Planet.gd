extends SpaceObject

class_name Planet

var gravity_constant: float = 6.67430e-11  # Gravitational constant

var mass: float = 0.0

# Constructor
func _init(name: String, pos: Vector2, radius: float, exerts_gravity: bool, texture: Texture, mass_value : float) -> void:
	super(name, pos, radius, true, texture)
	mass = mass_value

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
	
