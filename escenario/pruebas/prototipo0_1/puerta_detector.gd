extends Area2D

signal puerta_activada(direccion)

@export var direccion := "arriba"  # Puede ser "arriba", "abajo", "izquierda", "derecha"

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "caballero":  # Solo reacciona al jugador
		print("Jugador entró por dirección:", direccion)
		emit_signal("puerta_activada", direccion)
