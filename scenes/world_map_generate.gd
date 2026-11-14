extends Node2D

var house_template = preload("res://scenes/house_template.tscn")


func _ready():
	for house_number in 10:
		var house = house_template.instantiate()
		house.name = "House"
		#add_child(house)
		print("house made")
