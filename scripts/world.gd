extends Node2D

var tick = 0;
var day = 0

var occupied_positions: Dictionary = {}
var house_list: Array = [Node2D]

const house_template = preload("res://scenes/house_template.tscn")
var rng = RandomNumberGenerator.new()

func _ready():
	spawn_houses(100,10,125)

func spawn_houses(max_house:int, size: int, grid_size:int) -> void:
	
	for house_number in max_house:
		var grid_pos = Vector2i(rng.randi_range(-size,size),rng.randi_range(-size,size))
		
		if occupied_positions.has(grid_pos):
			print("house deleted")
			
		else:
			var house = house_template.instantiate()
			house.name = str("House_", house_number)
			house.global_position = grid_pos*grid_size
			occupied_positions[grid_pos] = true
			
			add_child(house)
			house_list.append(house)
			print("house made")
	
	#print(house_list)

func _process(delta: float) -> void:
	if (tick == 120):
		day_event()
		day += 1;
		tick = 0;
	else:
		tick += 1
		#print(tick)
		
func day_event() -> void:
	print("day:")
	print(day)
	
	set_meta("money", get_meta("money") + 50)
	set_meta("support", get_meta("support") - 1)
	
	print("Money:")
	print(get_meta("money"))
	
	if (get_meta("support") == 0):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
