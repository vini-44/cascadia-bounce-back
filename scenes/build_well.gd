extends Button

const WELL_TEMPLATE := preload("res://scenes/well_template.tscn")
const StatsHUD = preload("res://scripts/stats_hud.gd")
const WELL_COST := 100
@onready var WATER_GOAL = owner.house_list.size()

var connected_homes := 0
var placing_well := false
var preview_position := Vector2.ZERO
var preview_houses: Array[Node2D] = []
var dry_houses: Array[Node2D] = []

@onready var starting_well: Node2D = owner.get_node("well")
@onready var well_range: CollisionShape2D = starting_well.get_node("well_area/well_range")
@onready var hud: StatsHUD = owner.get_node("HUD")

@onready var target_canvas: Node2D = owner

func _ready():
	dry_houses.assign(owner.house_list)		
	target_canvas.draw.connect(_on_target_draw)

	#hud.setup_round(WELL_COST, WATER_GOAL)
	
func _process(delta: float) -> void:
	if placing_well:
		_update_preview()		
		target_canvas.queue_redraw()

	
	
		
func _unhandled_input(event: InputEvent) -> void:
	if owner.round_finished:
		return
	if event.is_action_pressed("place_well") and not event.is_echo():
		toggle_placement()
	elif placing_well and event.is_action_pressed("ui_cancel"):
		_cancel_placement()
	elif placing_well and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_position: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * event.position
		_try_build_well(click_position)
	else:
		return
	get_viewport().set_input_as_handled()

func toggle_placement() -> void:
	if owner.round_finished:
		return
	if placing_well:
		_cancel_placement()
	else:
		placing_well = true
		_update_preview()

func _update_preview() -> void:
	preview_position = owner.get_global_mouse_position()
	preview_houses = _houses_in_well_range(preview_position)
	hud.show_preview(preview_houses.size(), maxf(0.0, WELL_COST - float(owner.get_meta("money"))))
	queue_redraw()

func _cancel_placement() -> void:
	placing_well = false
	preview_houses.clear()
	hud.hide_preview()
	queue_redraw()

func _try_build_well(at: Vector2) -> void:
	var newly_served := _houses_in_well_range(at)
	if newly_served.is_empty() or owner.get_meta("money") < WELL_COST:
		return
	var well := WELL_TEMPLATE.instantiate() as Node2D
	owner.add_child(well)
	well.global_position = at
	owner.set_meta("money", owner.get_meta("money") - WELL_COST)
	_connect_houses(newly_served)
	connected_homes += newly_served.size()
	hud.show_progress(connected_homes, WATER_GOAL, %WaterProgress)
	_cancel_placement()
	
	#if connected_homes >= WATER_GOAL:
		#owner._finish_round(true)

func _houses_in_well_range(at: Vector2) -> Array[Node2D]:
	var served: Array[Node2D] = []
	var coverage := well_range.global_transform
	coverage.origin += at - starting_well.global_position
	for house in dry_houses:
		var house_range: CollisionShape2D = house.get_node("house_area/house_range")
		if well_range.shape.collide(coverage, house_range.shape, house_range.global_transform):
			served.append(house)
	return served

func _connect_houses(houses: Array[Node2D]) -> void:
	for house in houses:
		dry_houses.erase(house)
		house.set_meta("water", true)
		house.get_node("water_icon").hide()
		if house.get_meta("power") == false:
			house.get_node("house1_dead").hide()
			house.get_node("house1_nowater").hide()
			house.get_node("house1_healthy").hide()
			house.get_node("house1_nopower").show()
		else:
			house.get_node("house1_dead").hide()
			house.get_node("house1_nowater").hide()
			house.get_node("house1_healthy").show()
			house.get_node("house1_nopower").hide()
			
	owner.grass_update()

func _on_target_draw() -> void:
	if not placing_well:
		return
	var center := (preview_position + well_range.global_position - starting_well.global_position)
	var radius := (well_range.shape as CircleShape2D).radius * well_range.scale.x
	var accent := Color(0.42, 0.78, 0.90)
	target_canvas.draw_circle(center, radius, Color(accent, 0.14))
	target_canvas.draw_arc(center, radius, 0, TAU, 96, accent, 3.0, true)
	target_canvas.draw_circle(center, 10.0, accent)
	for house in preview_houses:
		target_canvas.draw_arc((house.global_position), 80.0, 0, TAU, 32, accent, 4.0, true)
