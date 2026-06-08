extends Label

@onready var inventory_node = $"../../Inventory"
var objectives = ["Go to the reception table", "Put the VHS tape inside computer."]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_update_objective()
	
func _process(delta: float) -> void:
	if inventory_node.inventory_is_opened:
		visible = false
	else:
		visible = true

func _update_objective():
	text = """Objective:
		%s""" % objectives[0]
