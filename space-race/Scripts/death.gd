extends Area2D

var GameOverScreen = preload("res://Scenes/GameOver.tscn")
@onready var particleDeath: CPUParticles2D = $"../ParticleDeath"
@onready var player: RigidBody2D = $".."
@onready var music = $"../BackroundMusic"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	particleDeath.emitting = false

func _process(delta: float) -> void:
	pass
	
func _on_area_entered(area: Area2D) -> void:
	#particleDeath.emitting = true
	#explode.play()
	music.stop()
	player.dead = true
	await get_tree().create_timer(2.0).timeout
	show_game_over()

func show_game_over():
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
