extends RigidBody2D

@export var thrust_force: float = 80.0     # How strong the forward thrust is
@export var rotation_speed: float = 8.0    # How fast the ship rotates (radians/sec)
#@export var max_speed: float = 200.0        # Optional speed cap

@onready var particleMain = $ParticlesMain/CPUParticles2D
@onready var particleLeft = $ParticlesLeft/CPUParticles2D
@onready var particleRight = $ParticlesRight/CPUParticles2D
@onready var jets = $Jets

@onready var Sprite = $Sprite2D
@onready var cam = $Camera2D
var active = false
var dead = false

var zoom = Vector2(3, 3)
# In your player script
const PlanetGen = preload("res://Scripts/planet_body_gen.gd")

@export var world_bounds = Rect2(
	Vector2(-PlanetGen.MAX_DISPLAY_DISTANCE, -PlanetGen.MAX_DISPLAY_DISTANCE),
	Vector2(PlanetGen.MAX_DISPLAY_DISTANCE*2, PlanetGen.MAX_DISPLAY_DISTANCE*2)
)

var joy_id := -1
var use_joypad := false
const deadzone := 0.1

func _ready() -> void:
	var joypads = Input.get_connected_joypads()
	if len(joypads) == 0:
		print("No Gamepad Connected")
	else:
		joy_id = joypads[0]
		use_joypad = true
		print("Joypad Connected")
	
func get_joy_input(joy_axis : int) -> float:
	var thrust = (-1*Input.get_joy_axis(joy_id, joy_axis)+1)/2 # Normalize the input to 0-1
	if thrust < deadzone:
		thrust = 0
	return thrust
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	
	if dead:
		cam.zoom = cam.zoom.lerp(zoom, 0.015)
		linear_velocity = Vector2.ZERO
		angular_velocity = 0
		particleMain.emitting = false
		particleLeft.emitting = false
		particleRight.emitting = false
		if jets.playing:
			jets.stop()
		return
	
	var torque := 0.0
	var thrust := Vector2.ZERO
	particleMain.emitting = false
	particleLeft.emitting = false
	particleRight.emitting = false
	active = false

	if not use_joypad:
		# Rotate left/right
		if Input.is_key_pressed(KEY_A):
			torque -= rotation_speed
			particleRight.emitting = true
			active = true

		if Input.is_key_pressed(KEY_D):
			torque += rotation_speed
			particleLeft.emitting = true
			active = true

		# Apply rotation torque
		apply_torque_impulse(torque)

		# Forward thrust
		if Input.is_key_pressed(KEY_W):
			var forward_dir := Vector2.RIGHT.rotated(rotation)
			thrust = forward_dir * thrust_force * state.step
			apply_central_impulse(thrust)
			particleMain.emitting = true
			active = true
	
	else:
		var left_thrust = get_joy_input(0)
		var middle_thrust = get_joy_input(1)
		var right_thrust = get_joy_input(2)
		if left_thrust > 0:
			torque -= rotation_speed*left_thrust
			particleRight.emitting = true
			active = true
		if right_thrust > 0:
			torque += rotation_speed
			particleLeft.emitting = true
			active = true
		
		apply_torque_impulse(torque)

		if middle_thrust > 0:
			var forward_dir := Vector2.RIGHT.rotated(rotation)
			thrust = forward_dir * thrust_force * state.step * middle_thrust
			apply_central_impulse(thrust)
			particleMain.emitting = true
			active = true
		
		
	if active and not jets.playing:
		jets.play()
	elif not active and jets.playing:
		jets.stop()
		
	# Clamp player within the world bounds
	var pos = state.transform.origin
	pos.x = clamp(pos.x, world_bounds.position.x, world_bounds.position.x + world_bounds.size.x)
	pos.y = clamp(pos.y, world_bounds.position.y, world_bounds.position.y + world_bounds.size.y)
	state.transform.origin = pos

	
	# Optional speed limit (prevents infinite acceleration)
	#if linear_velocity.length() > max_speed:
		#linear_velocity = linear_velocity.normalized() * max_speed
