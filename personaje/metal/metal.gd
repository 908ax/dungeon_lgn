# metal.gd
extends CharacterBody2D

# --- Configuración ---
@export var speed: float = 100.0
@export var shoot_interval: float = 2.0
@export var pokeball_scene: PackedScene
@export var launch_offset_x: float = 16.0

@export var max_health: int = 20
@export var ring_scene: PackedScene      # Arrastra Ring.tscn desde el Inspector
@export var rings_to_drop: int = 5
@export var score_value: int = 200       # Puntos que suma al jugador al morir

# --- Variables internas ---
var sonic: CharacterBody2D = null
var shoot_timer: float = 0.0
var health: int

# --- Nodos ---
@onready var launch_point: Node2D = $launch_point
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	health = max_health
	# Intentamos encontrar al jugador como hermano (nivel/sonic)
	# Ajusta la ruta si tu jugador está en otra parte.
	if has_node("../sonic"):
		sonic = get_node("../sonic")
	elif get_tree().current_scene and get_tree().current_scene.has_node("sonic"):
		sonic = get_tree().current_scene.get_node("sonic")
	else:
		# si el nombre del nodo es distinto (p.ej. "caballero"), cámbialo aquí:
		if has_node("../caballero"):
			sonic = get_node("../caballero")

	add_to_group("enemigos")

func _physics_process(delta: float) -> void:
	if health <= 0:
		return

	if not is_instance_valid(sonic) or sonic == null:
		# intenta buscar dinámicamente si no lo encontró en ready
		if get_tree().current_scene and get_tree().current_scene.has_node("sonic"):
			sonic = get_tree().current_scene.get_node("sonic")
		else:
			return

	# Movimiento hacia el jugador
	var dir = (sonic.global_position - global_position)
	if dir.length() > 0:
		dir = dir.normalized()
	velocity.x = dir.x * speed
	velocity.y = dir.y * speed
	move_and_slide()

	# Animación básica
	if velocity.length() > 0:
		if sprite.animation != "correr":
			sprite.play("correr")
		sprite.flip_h = velocity.x < 0
	else:
		if sprite.animation != "metal":
			sprite.play("metal")

	# Ajustar launch_point delante de Metal según dirección horizontal
	if launch_point:
		launch_point.position.x = launch_offset_x * (1 if velocity.x >= 0 else -1)

	# Disparo
	shoot_timer += delta
	if shoot_timer >= shoot_interval:
		shoot_timer = 0.0
		lanzar_pokeball()

func lanzar_pokeball():
	if not pokeball_scene:
		return
	
	var pokeball = pokeball_scene.instantiate()
	
	# Posición de spawn
	var spawn_pos = launch_point.global_position if launch_point else global_position
	pokeball.global_position = spawn_pos
	
	# Asignar objetivo directamente
	pokeball.target = sonic
	
	# Añadir al árbol de la escena para que exista independientemente del enemigo
	if get_tree().current_scene:
		get_tree().current_scene.add_child(pokeball)
	else:
		get_parent().add_child(pokeball)


# --- Recibir daño desde el jugador (por ejemplo desde ataque) ---
# player puede ser el nodo jugador para incrementar la puntuación
func take_damage(amount: int, player: Node) -> void:
	if health <= 0:
		return

	health -= amount

	if health <= 0:
		# Generar rings alrededor del enemigo
		for i in range(rings_to_drop):
			if not ring_scene:
				continue
			var angle = randf() * TAU
			var distance = randf_range(40, 80)
			var offset = Vector2(cos(angle), sin(angle)) * distance
			var spawn_pos = global_position + offset
			spawn_ring_safe(spawn_pos)


		# Aumentar puntuación del jugador si tiene método
		if player and player.has_method("set_count_puntuacion"):
			player.set_count_puntuacion(player.puntuacion_counter + score_value)

		queue_free()
		
func spawn_ring_safe(area_pos: Vector2) -> void:
	var max_intentos := 10

	for i in range(max_intentos):
		var angle = randf() * TAU
		var distance = randf_range(40, 80)
		var offset = Vector2(cos(angle), sin(angle)) * distance
		var spawn_pos = area_pos + offset

		# --- Raycast hacia abajo ---
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.new()
		query.from = spawn_pos
		query.to = spawn_pos + Vector2(0, 200)  # 200 px hacia abajo
		query.collide_with_areas = false
		query.collide_with_bodies = true
		query.collision_mask = 1 << 1  # ← aquí pones LA LAYER DE TU SUELO

		var result = space_state.intersect_ray(query)

		if result:
			# Toca suelo, generar ring ahí
			var ring = ring_scene.instantiate()
			ring.global_position = result.position
			get_tree().current_scene.add_child(ring)
			return

	print("No encontré lugar seguro para ring")
