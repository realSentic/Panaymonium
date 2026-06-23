extends ColorRect

@onready var person1msg = $Person1/Person1MSG
@onready var person2msg = $Person2/Person2MSG
@onready var person3msg = $Person3/Person3MSG
@onready var person4msg = $Person4/Person4MSG

func _on_person_1_pressed() -> void:
	person1msg.visible = true
	
	person2msg.visible = false
	person3msg.visible = false
	person4msg.visible = false


func _on_person_2_pressed() -> void:
	person2msg.visible = true
	
	person1msg.visible = false
	person3msg.visible = false
	person4msg.visible = false


func _on_person_3_pressed() -> void:
	person3msg.visible = true
	
	person2msg.visible = false
	person1msg.visible = false
	person4msg.visible = false


func _on_person_4_pressed() -> void:
	person4msg.visible = true
	
	person2msg.visible = false
	person3msg.visible = false
	person1msg.visible = false
