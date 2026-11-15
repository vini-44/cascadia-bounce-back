extends Node2D

var overlapping_wells: Dictionary = {}

@onready var grass: Sprite2D = $grass

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("well"):
		overlapping_wells[area.get_instance_id()] = true
		_set_water(true)

func _on_area_exited(area: Area2D) -> void:
	if overlapping_wells.erase(area.get_instance_id()):
		_set_water(not overlapping_wells.is_empty())

func _set_water(has_water: bool) -> void:
	set_meta("has_water", has_water)
	grass.visible = has_water
