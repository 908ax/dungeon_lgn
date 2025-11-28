extends Area2D

@onready var sprite = $AnimatedSprite2D

func _ready():
	# Reproducir animación inicial
	sprite.play("default")
	# Conectar señal de colisión con Sonic
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("caballero"):
		# Actualizar contadores de Sonic
		if body.has_method("set_count_ring"):
			body.set_count_ring(body.coin_counter + 1)
		if body.has_method("set_count_puntuacion"):
			body.set_count_puntuacion(body.puntuacion_counter + 50)
		# Destruir ring al ser recogida
		queue_free()
