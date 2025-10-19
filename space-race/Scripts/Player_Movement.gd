extends RigidBody2D

@export var thrust_force: float = 60.0     # How strong the forward thrust is
@export var rotation_speed: float = 7.5     # How fast the ship rotates (radians/sec)
@export var max_speed: float = 150.0        # Optional speed cap

@onready var particleMain: CPUParticles2D = $ParticlesMain/CPUParticles2D
@onready var particleLeft: CPUParticles2D = $ParticlesLeft/CPUParticles2D
@onready var particleRight: CPUParticles2D = $ParticlesRight/CPUParticles2D

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var torque := 0.0
	var thrust := Vector2.ZERO
	particleMain.emitting = false
	particleLeft.emitting = false
	particleRight.emitting = false

	# Rotate left/right
	if Input.is_key_pressed(KEY_A):
		torque -= rotation_speed
		particleRight.emitting = true

	if Input.is_key_pressed(KEY_D):
		torque += rotation_speed
		particleLeft.emitting = true

	# Apply rotation torque
	apply_torque_impulse(torque)

	# Forward thrust
	if Input.is_key_pressed(KEY_W):
		var forward_dir := Vector2.RIGHT.rotated(rotation)
		thrust = forward_dir * thrust_force * state.step
		apply_central_impulse(thrust)
		particleMain.emitting = true
	
	# Optional speed limit (prevents infinite acceleration)
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
