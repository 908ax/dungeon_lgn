extends CharacterBody2D

# --- Configuración ---
@export var speed: float = 280.0
@export var invul_duration: float = 1.3
@export var ring_scene: PackedScene
@export var rings_on_hit: int = 2
@export var attack_duration: float = 0.3
@export var attack_damage: int = 10

# --- Nodos de ataque ---
@export var attack_area: Area2D
@export var attack_visual: AnimatedSprite2D

# --- Variables internas ---
var coin_counter: int = 0
var puntuacion_counter: int = 0
var invulnerable: bool = false
var invul_timer: float = 0.0
@export var game_over_panel: Node2D

var attacking: bool = false
var attack_timer: float = 0.0
var last_input_dir: Vector2 = Vector2.RIGHT  # dirección por defecto

# --- Referencias de nodos ---
@export var ring_label: Label
@export var puntuacion_label: Label
@onready var sprite = $AnimatedSprite2D

func _ready():
	add_to_group("caballero")
	if attack_area:
		attack_area.monitoring = false  # usar monitoring en lugar de disabled
		attack_area.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))
	if attack_visual:
		attack_visual.visible = false

func _physics_process(delta):
	if game_over_panel and game_over_panel.visible:
		return

	# --- Movimiento ---
	var input_vector := Vector2.ZERO
	if Input.is_action_pressed("mover_arriba"):
		input_vector.y -= 1
	if Input.is_action_pressed("mover_abajo"):
		input_vector.y += 1
	if Input.is_action_pressed("mover_izquierda"):
		input_vector.x -= 1
	if Input.is_action_pressed("mover_derecha"):
		input_vector.x += 1

	if input_vector != Vector2.ZERO:
		last_input_dir = input_vector.normalized()

	input_vector = input_vector.normalized()
	velocity = input_vector * speed

	# --- Animaciones ---
	if attacking:
		if attack_visual:
			attack_visual.visible = true
			attack_visual.play("atacar")
			_update_attack_direction(last_input_dir)
	elif velocity.length() > 0:
		sprite.play("correr")
		sprite.flip_h = velocity.x < 0
	else:
		sprite.play("sonic")
	if not attacking and attack_visual:
		attack_visual.visible = false

	move_and_slide()

	# --- Invulnerabilidad ---
	if invulnerable:
		invul_timer -= delta
		sprite.visible = int(invul_timer * 5) % 2 == 0
		if invul_timer <= 0:
			invulnerable = false
			sprite.visible = true

	# --- Manejo del ataque ---
	if attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			attacking = false
			if attack_area:
				attack_area.monitoring = false  # desactivar detección al terminar

func _input(event):
	if event.is_action_pressed("atacar") and not attacking:
		activar_ataque()

func activar_ataque():
	attacking = true
	attack_timer = attack_duration
	if attack_area:
		attack_area.monitoring = true  # activar detección al atacar

# --- Cambiar posición y rotación del ataque según dirección ---
func _update_attack_direction(dir: Vector2):
	if not attack_area or not attack_visual:
		return
	var offset = Vector2.ZERO
	if dir.x > 0:
		offset = Vector2(32, 0)
		attack_visual.flip_h = false
	elif dir.x < 0:
		offset = Vector2(-32, 0)
		attack_visual.flip_h = true
	elif dir.y > 0:
		offset = Vector2(0, 32)
		attack_visual.flip_h = false
	elif dir.y < 0:
		offset = Vector2(0, -32)
		attack_visual.flip_h = false

	attack_area.position = offset
	attack_visual.position = offset

# --- Actualizar rings ---
func set_count_ring(new_coin_count: int) -> void:
	coin_counter = new_coin_count
	if ring_label:
		ring_label.text = "Rings: " + str(coin_counter)

func set_count_puntuacion(new_puntuacion_count: int) -> void:
	puntuacion_counter = new_puntuacion_count
	if puntuacion_label:
		puntuacion_label.text = "Puntuacion: " + str(puntuacion_counter)

# --- Recibir daño ---
func damage_rings(amount: int):
	if invulnerable or (game_over_panel and game_over_panel.visible):
		return


	if coin_counter <= 0:
		if game_over_panel:
			game_over_panel.show() 
			get_tree().paused = true
		velocity = Vector2.ZERO
		return

	var lost_rings = min(amount, coin_counter)
	coin_counter -= lost_rings
	set_count_ring(coin_counter)

	for i in range(lost_rings):
		if not ring_scene:
			continue
		var ring = ring_scene.instantiate()
		var angle = randf() * TAU
		var distance = randf_range(70, 100)
		var offset = Vector2(cos(angle), sin(angle)) * distance
		ring.global_position = global_position + offset
		get_parent().add_child(ring)

	invulnerable = true
	invul_timer = invul_duration


# --- Ataque destruye Pokeballs ---
func _on_area_2d_area_entered(body):
	if body.is_in_group("pokeball"):
		body.queue_free()
	elif body.is_in_group("enemigos"):
		# Llamar a take_damage en el enemigo
		if body.has_method("take_damage"):
			body.take_damage(attack_damage, self)
