extends Control

@onready var texture_rect = $TextureRect

func setup(item: Dictionary):
	var tex = load(item["icon"])
	print("texture loaded: ", tex)
	texture_rect.texture = tex
