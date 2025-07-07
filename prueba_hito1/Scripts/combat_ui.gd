extends Node2D
class_name CombatUI

@onready var key_image: TextureRect = $KeyImage

var tween: Tween = null

# Diccionario que asocia la tecla con la textura PNG
var key_textures := {
	"1": preload("res://Assets/Keyboard/Keyboard/Keyboard Press/Number/N. Key 14.png"),
	"2": preload("res://Assets/Keyboard/Keyboard/Keyboard Press/Number/N. Key 15.png"),
	"3": preload("res://Assets/Keyboard/Keyboard/Keyboard Press/Number/N. Key 16.png"),
	"4": preload("res://Assets/Keyboard/Keyboard/Keyboard Press/Number/N. Key 17.png"),
	# Agrega todas las que necesites
}

func show_prompt(key: String):
	if not key_textures.has(key):
		print("No se encontró textura para la tecla: ", key)
		return

	# Mostrar la textura correspondiente
	key_image.texture = key_textures[key]
	key_image.visible = true
	key_image.modulate.a = 2  # Reiniciar opacidad

	# Eliminar tween anterior si existe
	if tween and tween.is_running():
		tween.kill()
		tween = null

	# Crear nuevo tween para desvanecer la imagen
	tween = create_tween()
	tween.tween_property(key_image, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "_on_prompt_faded"))

func _on_prompt_faded():
	key_image.visible = false

func hide_prompt():
	if tween and tween.is_running():
		tween.kill()
		tween = null
	key_image.visible = false
