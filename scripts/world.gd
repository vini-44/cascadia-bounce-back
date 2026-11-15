extends Node2D

const WELL_TEMPLATE := preload("res://scenes/well_template.tscn")
const StatsHUD = preload("res://scripts/stats_hud.gd")
const WELL_COST := 100
const WATER_GOAL := 10
const DAY_SECONDS := 2.0

var day_elapsed := 0.0
var day = 0
var connected_homes := 0
var placing_well := false
var round_finished := false
var preview_position := Vector2.ZERO
var preview_houses: Array[Node2D] = []

var occupied_positions: Dictionary = {}

var house_list: Array[Node2D]
var dry_houses: Array[Node2D] = []

const house_template = preload("res://scenes/house_template.tscn")
var rng = RandomNumberGenerator.new()

@onready var starting_well: Node2D = $well
@onready var well_range: CollisionShape2D = $well/well_area/well_range
@onready var hud: StatsHUD = $HUD

func _ready():
	spawn_houses(100,10,125)
	dry_houses.assign(house_list)
	for node in get_children():
		if node is Node2D and node.is_in_group("well"):
			_connect_houses(_houses_in_well_range(node.global_position))
	hud.setup_round(WELL_COST, WATER_GOAL)

func spawn_houses(max_house:int, size: int, grid_size:int) -> void:
	
	for house_number in max_house:
		var grid_pos = Vector2i(rng.randi_range(-size,size),rng.randi_range(-size,size))
		
		if occupied_positions.has(grid_pos):
			#print("house deleted")
			pass
			
		else:
			var house = house_template.instantiate()
			house.name = str("House_", house_number)
			house.global_position = grid_pos*grid_size
			occupied_positions[grid_pos] = true
			
			add_child(house)
			house_list.append(house)
			#print("house made")
	
	#print(house_list)

func _process(delta: float) -> void:
	if round_finished:
		return
	day_elapsed += delta
	while day_elapsed >= DAY_SECONDS and not round_finished:
		day_elapsed -= DAY_SECONDS
		day_event()
		day += 1
	if placing_well:
		_update_preview()

func _physics_process(delta: float) -> void: 
	for current_house in house_list:
		house_update(current_house);
		#print(current_house)

func day_event() -> void:
	if round_finished:
		return
	print("day:")
	print(day)
	
	var bonus_money = 0
	for current_house in house_list:
		if (current_house.get_meta("power") == true):
			bonus_money += 0.25
		if (current_house.get_meta("water") == true):
			bonus_money += 0.25
			
	set_meta("money", get_meta("money") + 20 + bonus_money)
	
	support_calc()
	
	#print("Money:")
	#print(get_meta("money"))
	
	if get_meta("support") <= 0.0:
		_finish_round(false)

func support_calc():
	var total_support := 0.0
	var house_count := float(house_list.size())
	
	for current_house in house_list:
		if (current_house.get_meta("power") == true):
			total_support += 1
		if (current_house.get_meta("water") == true):
			total_support += 1
	var service_support := total_support / maxf(1.0, house_count)
	set_meta("support", clampf(get_meta("support") - 1.5 + service_support, 0.0, 100.0))
	#print(float(total_support/house_count))
	#print(total_support)
	#print(house_count)
	#print(get_meta("support"))

func house_update(house: Node2D):
	var area = house.get_node("house_area") as Area2D	
	var power_icon = house.get_node("power_icon") as Sprite2D
	var has_power := area.get_overlapping_areas().any(
		func(other: Area2D) -> bool: return other.is_in_group("power_source")
	)
	if has_power != house.get_meta("power"):
		house.set_meta("power", has_power)
		power_icon.visible = not has_power

func _unhandled_input(event: InputEvent) -> void:
	if round_finished:
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
	if round_finished:
		return
	if placing_well:
		_cancel_placement()
	else:
		placing_well = true
		_update_preview()

func _update_preview() -> void:
	preview_position = get_global_mouse_position()
	preview_houses = _houses_in_well_range(preview_position)
	hud.show_preview(preview_houses.size(), maxf(0.0, WELL_COST - float(get_meta("money"))))
	queue_redraw()

func _cancel_placement() -> void:
	placing_well = false
	preview_houses.clear()
	hud.hide_preview()
	queue_redraw()

func _try_build_well(at: Vector2) -> void:
	var newly_served := _houses_in_well_range(at)
	if newly_served.is_empty() or get_meta("money") < WELL_COST:
		return
	var well := WELL_TEMPLATE.instantiate() as Node2D
	add_child(well)
	well.global_position = at
	set_meta("money", get_meta("money") - WELL_COST)
	_connect_houses(newly_served)
	connected_homes += newly_served.size()
	hud.show_progress(connected_homes, WATER_GOAL)
	_cancel_placement()
	if connected_homes >= WATER_GOAL:
		_finish_round(true)

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

func _draw() -> void:
	if not placing_well:
		return
	var center := to_local(preview_position + well_range.global_position - starting_well.global_position)
	var radius := (well_range.shape as CircleShape2D).radius * well_range.scale.x
	var accent := Color(0.42, 0.78, 0.90)
	draw_circle(center, radius, Color(accent, 0.14))
	draw_arc(center, radius, 0, TAU, 96, accent, 3.0, true)
	draw_circle(center, 10.0, accent)
	for house in preview_houses:
		draw_arc(to_local(house.global_position), 80.0, 0, TAU, 32, accent, 4.0, true)

func _finish_round(won: bool) -> void:
	round_finished = true
	_cancel_placement()
	$player.process_mode = Node.PROCESS_MODE_DISABLED
	set_physics_process(false)
	hud.show_result(won, connected_homes, WATER_GOAL)

func restart_round() -> void:
	get_tree().reload_current_scene()
