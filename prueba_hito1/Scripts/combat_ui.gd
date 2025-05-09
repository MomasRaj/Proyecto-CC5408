extends Node2D
class_name CombatUI

@onready var label: Label = $PromptLabel
@onready var rich_text_label: RichTextLabel = $RichTextLabel

func show_prompt(key: String):
	rich_text_label.text = key
	rich_text_label.visible = true

func hide_prompt():
	rich_text_label.visible = false
