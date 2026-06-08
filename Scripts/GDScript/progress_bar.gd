extends ProgressBar

@onready var inventory_node = $"../../Inventory"

func _process(delta: float) -> void:
	if inventory_node.inventory_is_opened:
		visible = false
	else:
		visible = true
