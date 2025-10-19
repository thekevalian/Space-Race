extends Node2D

const MAX_DISPLAY_DISTANCE = 5000.0  # pixels between furthest points

var planetary_metdata = {}
var positions = {}
var normalized_positions = {}

func _ready():
	load_barycenters()

func load_barycenters():
	var file = FileAccess.open('res://Metadata/2d_coords_relative_to_sun.json', FileAccess.READ)
	var content = file.get_as_text()
	
	var json = JSON.new()
	planetary_metdata = json.parse_string(content)
	print(planetary_metdata)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
