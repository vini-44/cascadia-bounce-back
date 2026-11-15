extends HSlider

@export var bus_name := &"Master"

@onready var bus_index := AudioServer.get_bus_index(bus_name)

func _ready() -> void:
	if bus_index < 0:
		editable = false
		return
	var volume := 0.0 if AudioServer.is_bus_mute(bus_index) else AudioServer.get_bus_volume_linear(bus_index)
	set_value_no_signal(volume)
	value_changed.connect(_set_bus_volume)

func _set_bus_volume(volume: float) -> void:
	if volume > 0.0:
		AudioServer.set_bus_volume_linear(bus_index, volume)
	AudioServer.set_bus_mute(bus_index, volume == 0.0)
