extends CanvasLayer

@onready var money_label: Label = %MoneyLabel
@onready var support_bar: ProgressBar = %SupportBar
@onready var support_value: Label = %SupportValue
@onready var objective: Label = %WaterObjective
@onready var progress: Label = %WaterProgress
@onready var build_button: Button = %BuildWell
@onready var preview_details: VBoxContainer = %PreviewDetails
@onready var preview_count: Label = %PreviewCount
@onready var preview_hint: Label = %PreviewHint
@onready var result_screen: CenterContainer = %ResultScreen
@onready var result_message: Label = %ResultMessage
@onready var retry_button: Button = %Retry

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
	objective.text = "Connect %d more homes to water" % goal
	build_button.text = "Place a well, $%d" % cost
	show_progress(0, goal)

func show_progress(connected: int, goal: int) -> void:
	progress.text = "New homes with water: %d / %d" % [mini(connected, goal), goal]

func show_preview(homes: int, shortfall: float) -> void:
	preview_details.show()
	preview_count.text = "1 new home would get water" if homes == 1 else "%d new homes would get water" % homes
	if shortfall > 0:
		preview_hint.text = "You need %s more to build a well" % _format_money(shortfall)
	elif homes == 0:
		preview_hint.text = "Move the well to reach homes without water"
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
