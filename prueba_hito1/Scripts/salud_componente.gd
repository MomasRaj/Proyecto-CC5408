extends Node

@export var salud_actual := 100.0
@export var salud_maxima := 100.0

@export var barra_salud : BarraSalud

func recibir_damage(cantidad : float):
	salud_actual -= cantidad

	actualizar_salud()

	if salud_actual <= 0:
		print("EL PERSONAJE NO TIENE SALUD")

func actualizar_salud():
	if barra_salud:
		barra_salud.actualizar_barra(salud_maxima, salud_actual)
