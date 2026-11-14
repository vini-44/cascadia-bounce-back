extends CanvasLayer

const Player = preload("res://scripts/player.gd")

@export var player: Player


@onready var money_label: Label = %MoneyLabel
@onready var support_bar: ProgressBar = %SupportBar
@onready var support_value: Label = %SupportValue

func _ready() -> void:
	support_bar.value_changed.connect(_update_support_value)
	_refresh_stats()
	_update_support_value(support_bar.value)

func _process(_delta: float) -> void:
	_refresh_stats()

func _refresh_stats() -> void:
	var money_text := "Money: $%d" % owner.get_meta("money")
	if money_label.text != money_text:
		money_label.text = money_text
	support_bar.value = owner.get_meta("support")

func _update_support_value(value: float) -> void:
	support_value.text = "%d%%" % value
