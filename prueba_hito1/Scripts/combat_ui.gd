extends Node2D
class_name CombatUI

@onready var label: Label = $PromptLabel
@onready var rich_text_label: RichTextLabel = $RichTextLabel

#func show_prompt(key: String):
	#rich_text_label.text = key
	#rich_text_label.visible = true
#
#func hide_prompt():
	#rich_text_label.visible = false
	
	
var tween: Tween = null

func show_prompt(key: String):
	# Mostrar el texto
	rich_text_label.text = key
	rich_text_label.visible = true
	rich_text_label.modulate.a = 1.0  # Reiniciar opacidad

	# Eliminar tween anterior si existe
	if tween and tween.is_running():
		tween.kill()
		tween = null

	# Crear nuevo tween
	tween = create_tween()
	tween.tween_property(rich_text_label, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "_on_prompt_faded"))

func _on_prompt_faded():
	rich_text_label.visible = false

func hide_prompt():
	if tween and tween.is_running():
		tween.kill()
		tween = null
	rich_text_label.visible = false
