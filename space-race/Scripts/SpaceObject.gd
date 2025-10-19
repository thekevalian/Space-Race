extends Area2D
class_name SpaceObject

var radius: float
var exerts_gravity: bool = false
var sprite: Sprite2D

func _init(name: String, pos: Vector2, radius: float, exerts_gravity: bool, texture: Texture) -> void:
	self.name = name
	self.position = pos
	self.radius = radius
	self.exerts_gravity = exerts_gravity
	
	# Sprite
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.position = Vector2.ZERO
	var texture_size = texture.get_size()
	var diameter_in_pixels = radius * 2.0
	sprite.scale = Vector2(
		diameter_in_pixels / texture_size.x,
		diameter_in_pixels / texture_size.y
	)
	add_child(sprite)

	# Collision
	var collision_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = radius
	collision_shape.shape = circle
	collision_shape.position = Vector2.ZERO
	
	self.set_collision_layer_value(1, true)  # Put object on layer 1
	self.set_collision_mask_value(1, true)   # Detect objects on layer 1
	monitoring = true
	monitorable = true

	add_child(collision_shape)

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	if self is Planet and area is Asteroid:
		print("Destroyed an Asteroid")
		area.queue_free()
	
