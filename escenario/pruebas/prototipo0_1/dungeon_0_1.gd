# dungeon_0_1.gd
extends Node2D

# --- Escena del enemigo ---
@export var metal_scene: PackedScene

# --- Ajustes de generación ---
@export var min_metales: int = 1
@export var max_metales: int = 4

@export var spawn_min_x: int = -500
@export var spawn_max_x: int = 420
@export var spawn_min_y: int = 120
@export var spawn_max_y: int = 590

# --- Referencia al jugador ---
@onready var sonic: Node2D = $sonic

func _ready():
	# Verificar asignaciones
	if not metal_scene:
		push_error("Dungeon: no has asignado 'metal_scene' en el Inspector.")
		return
	if not sonic:
		push_error("Dungeon: no se encontró el nodo 'sonic' como hijo directo. Ajusta la ruta.")
	
	# Generar enemigos
	generar_metal()


func generar_metal():
	# Cantidad de Metal aleatoria
	var cantidad = randi_range(min_metales, max_metales)
	for i in range(cantidad):
		var metal = metal_scene.instantiate()
		
		# Posición aleatoria dentro del rectángulo definido
		metal.position = Vector2(
			randi_range(spawn_min_x, spawn_max_x),
			randi_range(spawn_min_y, spawn_max_y)
		)
		
		# Añadir al nodo dungeon
		add_child(metal)
