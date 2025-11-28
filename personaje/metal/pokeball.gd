extends Area2D

@export var speed: float = 170
@export var life_time: float = 3.0
@export var turn_rate: float = 2.0
@export var damage_rings_amount: int = 2

var target: Node2D
var velocity: Vector2 = Vector2.ZERO
var time_alive: float = 0.0

func _ready():
	$AnimatedSprite2D.play("poke")
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("area_entered", Callable(self, "_on_area_entered"))

func _physics_process(delta: float) -> void:
	if not target or not is_instance_valid(target):
		queue_free()
		return

	time_alive += delta
	if time_alive >= life_time:
		queue_free()
		return

	var desired_dir = (target.global_position - global_position).normalized()
	var angle_diff = velocity.angle_to(desired_dir)
	var max_turn = turn_rate * delta

	if abs(angle_diff) > max_turn:
		angle_diff = sign(angle_diff) * max_turn

	if velocity == Vector2.ZERO:
		velocity = desired_dir * speed
	else:
		velocity = velocity.rotated(angle_diff).normalized() * speed

	global_position += velocity * delta
	rotation = velocity.angle()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("caballero"):
		if body.has_method("coin_counter") and body.coin_counter <= 0:
			body.game_over = true
			if body.has_node("game_over_label"):
				body.get_node("game_over_label").visible = true
			if body.has_method("velocity"):
				body.velocity = Vector2.ZERO
		elif body.has_method("damage_rings"):
			body.damage_rings(damage_rings_amount)
		queue_free()

func _on_area_entered(area: Node) -> void:
	if area.is_in_group("caballero"):
		if area.has_method("coin_counter") and area.coin_counter <= 0:
			area.game_over = true
			if area.has_node("game_over_label"):
				area.get_node("game_over_label").visible = true
			if area.has_method("velocity"):
				area.velocity = Vector2.ZERO
		elif area.has_method("damage_rings"):
			area.damage_rings(damage_rings_amount)
		queue_free()
