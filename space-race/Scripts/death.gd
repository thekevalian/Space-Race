extends Area2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
	pass
	
func _on_area_entered(area: Area2D) -> void:
	pass
	
	#if self is Planet and area is Asteroid:
		#area.queue_free()
	
