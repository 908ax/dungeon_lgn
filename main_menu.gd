extends Node2D

# Estado
var indice_seleccion := 0

# Escena del juego para seleccionar desde el Inspector
@export var escena_juego: PackedScene

# Referencias desde Inspector
@export var opcion_hboxes: Array[HBoxContainer] = []

# Visual
@export var selector_char := ">"
@export var normal_color := Color.WHITE
@export var selected_color := Color.YELLOW


func _ready():
	# Asegura que haya opciones
	if opcion_hboxes.size() == 0:
		push_error("No se asignaron HBoxContainers en 'opcion_hboxes'.")
		return

	# Asegura que cada HBox tenga selector y label
	for h in opcion_hboxes:
		if h.get_child_count() < 2:
			push_error("Un HBox no tiene 2 Labels (selector + texto).")
	
	actualizar_menu()


func _input(event):
	if opcion_hboxes.size() == 0:
		return

	if event.is_action_pressed("ui_down"):
		indice_seleccion += 1
		if indice_seleccion >= opcion_hboxes.size():
			indice_seleccion = 0
		actualizar_menu()

	elif event.is_action_pressed("ui_up"):
		indice_seleccion -= 1
		if indice_seleccion < 0:
			indice_seleccion = opcion_hboxes.size() - 1
		actualizar_menu()

	elif event.is_action_pressed("ui_accept"):
		confirmar_opcion()


func actualizar_menu():
	for i in range(opcion_hboxes.size()):
		var hbox = opcion_hboxes[i]

		var selector_label = hbox.get_child(0) as Label
		var texto_label = hbox.get_child(1) as Label

		if i == indice_seleccion:
			selector_label.text = selector_char
			texto_label.modulate = selected_color
		else:
			selector_label.text = ""
			texto_label.modulate = normal_color


func confirmar_opcion():
	var hbox = opcion_hboxes[indice_seleccion]
	var texto = (hbox.get_child(1) as Label).text.strip_edges().to_lower()

	if texto == "iniciar partida":
		if escena_juego:
			get_tree().change_scene_to_packed(escena_juego)
		else:
			push_error("No asignaste 'escena_juego' en el Inspector.")

	elif texto == "configuración":
		print("Config")

	elif texto == "información":
		print("Info")

	elif texto == "salir":
		get_tree().quit()

	else:
		print("Opción desconocida:", texto)
