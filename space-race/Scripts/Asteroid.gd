extends SpaceObject

class_name Asteroid
var rotational_velocity: float = 0.0
var velocity: Vector2 = Vector2.ZERO

# Constructor
func _init(name: String, pos: Vector2, radius: float, texture: Texture, 
			velocity : Vector2, initial_rotation : float, rotational_velocity : float) -> void:
	super(name, pos, radius, false, texture)
	self.rotation = initial_rotation
	self.rotational_velocity = rotational_velocity
	self.velocity = velocity

# Asteroids don't need rotation, just positioning and texture
func _process(delta: float) -> void:
	self.position += self.velocity*delta
	self.rotate(self.rotational_velocity*delta)
