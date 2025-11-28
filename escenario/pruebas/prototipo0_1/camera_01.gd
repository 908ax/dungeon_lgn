extends Camera2D

@export var caballero: CharacterBody2D
@export var smoothing: float = 0.2  # Ajusta según prefieras

func _ready():
	if caballero:
		global_position = caballero.global_position

func _physics_process(_delta):
	if not caballero:
		return

	var target_pos = caballero.global_position
	# Suavizado con alineación a píxeles
	global_position = global_position.lerp(target_pos, smoothing).floor()
