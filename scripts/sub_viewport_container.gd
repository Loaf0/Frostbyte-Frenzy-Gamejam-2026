extends Node

@export var your_subviewport: SubViewport

func _unhandled_input(event):
	your_subviewport.push_input(event)
