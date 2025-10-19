extends Node2D

const MAX_DISPLAY_DISTANCE = 640.0  # pixels between furthest points
const ASTEROID_MAX_VELOCITY = 40.0
const ASTEROID_MAX_ROTATIONAL_VELOCITY = 2

var space_object_arr = []
var asteroid_textures = {}
var NUM_ASTEROIDS = 20

func _ready():
	load_barycenters()

func load_barycenters():
	# Load the space objects available
	var file = FileAccess.open('res://Metadata/space_objects.json', FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var space_objects = json.parse_string(content)
	
	# All planets can only be generated once
	randomize()
	for planet in space_objects["planets"].keys():
		var pos = Vector2(randf_range(-MAX_DISPLAY_DISTANCE, MAX_DISPLAY_DISTANCE), 
						  randf_range(-MAX_DISPLAY_DISTANCE, MAX_DISPLAY_DISTANCE))
		var radius = space_objects["planets"][planet]["radius"]
		var mass = space_objects["planets"][planet]["mass"]
		var texture_filepath = "res://Assets/" + space_objects["planets"][planet]["filename"]
		var texture = load(texture_filepath)
		if texture == null:
			print("Failed to load texture for:", texture_filepath)

		var planet_obj = Planet.new(name, pos, radius, texture, mass)
		add_child(planet_obj)
		space_object_arr.append(planet_obj)
	
	# Load Asteroid Textures
	for asteroid in space_objects["asteroids"].keys():
		var texture_filepath = "res://Assets/" + space_objects["asteroids"][asteroid]["filename"]
		asteroid_textures[asteroid] = load(texture_filepath)
		if asteroid_textures[asteroid] == null:
			print("Failed to load texture for:", texture_filepath)
	
	# Generate Asteroids
	for i in NUM_ASTEROIDS:
		var asteriod_idx = randi_range(0, 0)
		var name = "asteroid" + str(asteriod_idx)
		var pos = Vector2(randf_range(-MAX_DISPLAY_DISTANCE, MAX_DISPLAY_DISTANCE), 
						  randf_range(-MAX_DISPLAY_DISTANCE, MAX_DISPLAY_DISTANCE))
		var radius = space_objects["asteroids"][name]["radius"]
		var texture = asteroid_textures[name]
		var velocity = Vector2(ASTEROID_MAX_VELOCITY*randf_range(-1, 1), ASTEROID_MAX_VELOCITY*randf_range(-1, 1))
		var initial_rotation = randf_range(0, 2*PI)
		var rotational_velocity = randf_range(-2*PI/ASTEROID_MAX_ROTATIONAL_VELOCITY, 2*PI/ASTEROID_MAX_ROTATIONAL_VELOCITY)
		var asteroid = Asteroid.new(name, pos, radius, texture, velocity, initial_rotation, rotational_velocity)
		add_child(asteroid)
		space_object_arr.append(asteroid)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
