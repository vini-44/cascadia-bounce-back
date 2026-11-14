extends Node2D

var tick = 0;
var day = 0

var occupied_positions: Dictionary = {}

var house_list: Array[Node2D]

const house_template = preload("res://scenes/house_template.tscn")
var rng = RandomNumberGenerator.new()

func _ready():
	spawn_houses(100,10,125)

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
	if (tick == 120):
		day_event()
		day += 1;
		tick = 0;
	else:
		tick += 1
		#print(tick)

func _physics_process(delta: float) -> void: 
	for current_house in house_list:
		house_update(current_house);
		#print(current_house)

func day_event() -> void:
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
	
	if (get_meta("support") == 0):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func support_calc():
	var total_support = float(0)
	var house_count = float(house_list.size())
	
	for current_house in house_list:
		if (current_house.get_meta("power") == true):
			total_support += 1
		if (current_house.get_meta("water") == true):
			total_support += 1
	set_meta("support", get_meta("support") - 1.5 + total_support/house_count)
	#print(float(total_support/house_count))
	#print(total_support)
	#print(house_count)
	#print(get_meta("support"))

func house_update(house: Node2D):
	var area = house.get_node("house_area") as Area2D	
	var water_icon = house.get_node("water_icon") as Sprite2D
	var power_icon = house.get_node("power_icon") as Sprite2D
	
	for body in area.get_overlapping_areas():
		
		if body.is_in_group("well"):
			house.set_meta("water", true)
			water_icon.hide()
		if body.is_in_group("power_source"):
			house.set_meta("power", true)
			power_icon.hide()
	if(!area.has_overlapping_areas()):
		house.set_meta("power", false)
		power_icon.show()
		house.set_meta("water", false)
		water_icon.show()
