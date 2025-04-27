extends Node2D
class_name CombatUI

@onready var label: Label = $PromptLabel

func show_prompt(key: String):
	label.text = key
	label.visible = true

func hide_prompt():
	label.visible = false
