extends Node2D

var occupied_positions: Dictionary = {}
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
			print("house made")
