extends ProgressBar

@onready var inventory_node = $"../../Inventory"

func is_inventory_open() -> bool:
	return inventory_node.inventory_is_opened
