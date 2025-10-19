extends Node2D

const MAX_DISPLAY_DISTANCE = 2000.0  # pixels between furthest points
const ASTEROID_MAX_VELOCITY = 40.0
const ASTEROID_MAX_ROTATIONAL_VELOCITY = 2

var space_object_arr = []
var asteroid_textures = {}
var NUM_ASTEROIDS = 50

@onready var player: RigidBody2D = $RigidBody2D
const g = 0.20
const MIN_PLAYER_DISTANCE = 300.0  # Prevents spawning too close to player
const MIN_PLANET_SPACING = 150.0   # Prevents overlapping between planets
const MAX_ATTEMPTS = 100            # Prevent infinite loops when placing

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
		for i in space_objects["planets"][planet]["num_spawns"]:
			
			var placed = false
			var attempts = 0
			
			while not placed and attempts < MAX_ATTEMPTS:
				attempts += 1

				var pos = Vector2(
					randf_range(-MAX_DISPLAY_DISTANCE, MAX_DISPLAY_DISTANCE),
					randf_range(-MAX_DISPLAY_DISTANCE, MAX_DISPLAY_DISTANCE)
				)

				var radius = space_objects["planets"][planet]["radius"]
				var mass = space_objects["planets"][planet]["mass"]
				var texture_filepath = "res://Assets/" + space_objects["planets"][planet]["filename"]
				var texture = load(texture_filepath)
				if texture == null:
					print("Failed to load texture for:", texture_filepath)
					break

				# Check distance from player
				if pos.distance_to(Vector2.ZERO) < MIN_PLAYER_DISTANCE + radius:
					continue

				# Check distance from other planets
				var too_close = false
				for other in space_object_arr:
					if other.exerts_gravity:
						var min_distance = radius + other.radius + MIN_PLANET_SPACING
						if pos.distance_to(other.global_position) < min_distance:
							too_close = true
							break
				
				if too_close:
					continue

				# Passed all checks, place the planet
				if planet == "Dynamo":
					radius *= .3
					
				var planet_obj = Planet.new(planet, pos, radius, true, texture, mass)
				add_child(planet_obj)
				space_object_arr.append(planet_obj)
				placed = true

			if not placed:
				print("Failed to place planet:", planet, "after", MAX_ATTEMPTS, "attempts")
	
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
	if not player:
		return
	
	for obj in space_object_arr:
		if obj == null or not is_instance_valid(obj):
			continue
		if obj.exerts_gravity:
			var direction = obj.global_position - player.global_position
			var distance_squared = max(direction.length_squared(), 4.0)  # prevent divide-by-zero
			var force_magnitude = g * obj.mass * player.mass / distance_squared
			var force = direction.normalized() * force_magnitude
			player.apply_central_force(force)
