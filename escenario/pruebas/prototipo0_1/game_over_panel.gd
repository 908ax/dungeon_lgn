extends Node2D

# --- Configuración (Inspector) ---
@export var dungeon_scene: PackedScene
@export var main_menu_scene: PackedScene
@export var opcion_hboxes: Array[HBoxContainer] = []

@export var selector_char := ">"
@export var normal_color := Color.WHITE
@export var selected_color := Color.BLUE

var indice_seleccion := 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

	if opcion_hboxes.size() == 0:
		push_error("No se asignaron HBoxContainers en 'opcion_hboxes'.")
	else:
		for i in range(opcion_hboxes.size()):
			var h = opcion_hboxes[i]
			if not h:
				push_error("opcion_hboxes[" + str(i) + "] es NIL.")
			elif h.get_child_count() < 2:
				push_error("Cada HBox debe tener 2 Labels.")

	actualizar_menu()

# -------- CENTRADO EN CÁMARA (Node2D) --------
func center_on_camera(vbox_control: Control) -> void:
	if not vbox_control:
		return

	var cam := get_viewport().get_camera_2d()
	if not cam:
		# fallback sin cámara
		var screen := get_viewport().get_visible_rect()
		global_position = screen.size * 0.5
		return

	var ctrl_size := vbox_control.size
	if ctrl_size == Vector2.ZERO:
		ctrl_size = vbox_control.get_combined_minimum_size()

	# centra el Node2D para que el Control quede en el centro de la cámara
	global_position = cam.global_position - ctrl_size * 0.5


# -------- Mostrar / Ocultar --------
func mostrar():
	show()
	get_tree().paused = true

	indice_seleccion = 0
	actualizar_menu()

	var vbox := opcion_hboxes[0].get_parent() as Control
	center_on_camera(vbox)

func ocultar():
	hide()
	get_tree().paused = false

# -------- Input --------
func _unhandled_input(event):
	if not is_visible_in_tree():
		return

	if event.is_action_pressed("ui_down"):
		indice_seleccion = (indice_seleccion + 1) % opcion_hboxes.size()
		actualizar_menu()

	elif event.is_action_pressed("ui_up"):
		indice_seleccion = (indice_seleccion - 1 + opcion_hboxes.size()) % opcion_hboxes.size()
		actualizar_menu()

	elif event.is_action_pressed("ui_accept"):
		confirmar_opcion()

# -------- Menu --------
func actualizar_menu():
	for i in range(opcion_hboxes.size()):
		var h := opcion_hboxes[i]

		var selector := h.get_child(0) as Label
		var texto := h.get_child(1) as Label

		if i == indice_seleccion:
			selector.text = selector_char
			texto.modulate = selected_color
		else:
			selector.text = ""
			texto.modulate = normal_color

func confirmar_opcion():
	var h := opcion_hboxes[indice_seleccion]
	var texto := (h.get_child(1) as Label).text.strip_edges().to_lower()

	if texto == "reiniciar":
		get_tree().paused = false
		get_tree().change_scene_to_packed(dungeon_scene)

	elif texto == "salir":
		get_tree().quit()

	else:
		print("Opción desconocida:", texto)
