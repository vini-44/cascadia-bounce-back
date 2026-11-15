extends Node2D
const DAY_SECONDS := 2.0
var round_finished := false

var day_elapsed := 0.0
var day = 0

var occupied_positions: Dictionary = {}

var house_list: Array[Node2D]
var grass_list: Array[Node2D]

const grass_template = preload("res://scenes/grass_template.tscn")
const house_template = preload("res://scenes/house_template.tscn")
const StatsHUD = preload("res://scripts/stats_hud.gd")
var rng = RandomNumberGenerator.new()

@onready var hud: StatsHUD = $HUD

func _ready():
	spawn_houses(100,10,125)
	%BuildWell.dry_houses.assign(house_list)
	

func spawn_houses(max_house:int, size: int, grid_size:int) -> void:
	for grass_y in range(-size*4, size*4):
		for grass_x in range(-size*4, size*4):
			var grass_pos = Vector2i(grass_x,grass_y)*grid_size
			var grass = grass_template.instantiate()
			grass.global_position = grass_pos
			
			add_child(grass)
			grass_list.append(grass)
			grass.get_node("grass").hide()
			
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

func _physics_process(delta: float) -> void: 
	for current_house in house_list:
		house_update(current_house)
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
		
func grass_update():
	for grass in grass_list:
		var area = grass.get_node("area") as Area2D	
		var grass_tex = grass.get_node("grass") as Sprite2D
		var has_water := area.get_overlapping_areas().any(
			func(other: Area2D) -> bool: return other.is_in_group("power_source")
		)
		#print(has_water)
		if has_water != grass.get_meta("has_water"):
			grass.set_meta("water", has_water)
			grass_tex.visible = not has_water

func _finish_round(won: bool) -> void:
	round_finished = true
	%BuildWell._cancel_placement()
	$player.process_mode = Node.PROCESS_MODE_DISABLED
	set_physics_process(false)
	hud.show_result(won, %BuildWell.connected_homes, %BuildWell.WATER_GOAL)

func restart_round() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
