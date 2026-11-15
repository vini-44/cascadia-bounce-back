extends CanvasLayer

@onready var money_label: Label = $MoneyPanel/Padding/VBoxContainer/MoneyLabel
@onready var support_bar: ProgressBar = $SupportPanel/Padding/Stats/SupportBar
@onready var support_value: Label = $SupportPanel/Padding/Stats/SupportValue
@onready var objective: Label = $BuildPanel/Padding/Details/Objective
@onready var progress: Label = $BuildPanel/Padding/Details/WaterProgress
@onready var progress2: Label = $BuildPanel/Padding/Details/PowerProgress
@onready var build_button: Button = $BuildPanel/Padding/Details/BuildWell
@onready var preview_details: VBoxContainer = $BuildPanel/Padding/Details/PreviewDetails
@onready var preview_count: Label = $BuildPanel/Padding/Details/PreviewDetails/PreviewCount
@onready var preview_hint: Label = $BuildPanel/Padding/Details/PreviewDetails/PreviewHint
@onready var result_screen: CenterContainer = $ResultScreen
@onready var result_message: Label = $ResultScreen/ResultPanel/Padding/Result/ResultMessage
@onready var retry_button: Button = $ResultScreen/ResultPanel/Padding/Result/Retry

func _ready() -> void:
	support_bar.value_changed.connect(_update_support_value)
	_refresh_stats()
	_update_support_value(support_bar.value)

func _process(_delta: float) -> void:
	_refresh_stats()

func _refresh_stats() -> void:
	var money_text := "Money: %s" % _format_money(owner.get_meta("money"))
	if money_label.text != money_text:
		money_label.text = money_text
	support_bar.value = owner.get_meta("support")

func _update_support_value(value: float) -> void:
	support_value.text = "%d%%" % ceili(value)

func _format_money(amount: float) -> String:
	return "$%d" % amount if is_equal_approx(amount, floorf(amount)) else "$%.2f" % amount

func setup_round(cost: int, goal: int) -> void:
	build_button.text = "Place a well, $%d" % cost
	show_progress(0, goal,%WaterProgress)
	show_progress(0, goal,%PowerProgress)

func show_progress(connected: int, goal: int, target: Label) -> void:
	if target == progress:
		target.text = "New homes with water: %d / %d" % [mini(connected, goal), goal]
	if target == progress2:
		target.text = "New homes with power: %d / %d" % [mini(connected, goal), goal]

func show_preview(homes: int, shortfall: float) -> void:
	preview_details.show()
	preview_count.text = "1 new home would be connected" if homes == 1 else "%d new homes would be connected" % homes
	if shortfall > 0:
		preview_hint.text = "You need %s more to build this" % _format_money(shortfall)
	elif homes == 0:
		preview_hint.text = "Move the the building to the housess"
	else:
		preview_hint.text = "Click to build"
	preview_hint.text += " · Esc to cancel"

func hide_preview() -> void:
	preview_details.hide()

func show_result(won: bool, connected: int, goal: int) -> void:
	build_button.disabled = true
	if won:
		result_message.text = "%d more homes have water." % goal
		retry_button.text = "Play again"
	else:
		result_message.text = "Support ran out, you connected %d of %d homes." % [connected, goal]
		retry_button.text = "Try again"
	result_screen.show()
	retry_button.grab_focus()
