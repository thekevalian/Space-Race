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
		
	if active and not jets.playing:
		jets.play()
	elif not active and jets.playing:
		jets.stop()
	
	# Optional speed limit (prevents infinite acceleration)
	#if linear_velocity.length() > max_speed:
		#linear_velocity = linear_velocity.normalized() * max_speed
