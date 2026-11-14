extends CharacterBody2D

var tick = 0;
var day = 0

var zoom_factor = 0.1;

	
func _physics_process(delta):
	var input_direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = input_direction * 700
	move_and_slide()
	zoom()
	
	
func zoom():
	if Input.is_action_pressed("Zoom in"):
		$Camera2D.zoom.x *= 1 + zoom_factor
		$Camera2D.zoom.y *= 1 + zoom_factor
	if Input.is_action_pressed("Zoom out") and $Camera2D.zoom.x > 0.1 and $Camera2D.zoom.y > 0.1:
		$Camera2D.zoom.x *= 1 - zoom_factor
		$Camera2D.zoom.y *= 1 - zoom_factor
	
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
