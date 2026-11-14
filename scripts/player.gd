extends CharacterBody2D

var zoom_factor = 0.1;
	
func _physics_process(delta):
	var input_direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = input_direction * 700 / $Camera2D.zoom.x
	move_and_slide()
	zoom()
	
	
func zoom():
	if Input.is_action_pressed("Zoom in"):
		$Camera2D.zoom.x *= 1 + zoom_factor
		$Camera2D.zoom.y *= 1 + zoom_factor
	if Input.is_action_pressed("Zoom out") and $Camera2D.zoom.x > 0.1 and $Camera2D.zoom.y > 0.1:
		$Camera2D.zoom.x *= 1 - zoom_factor
		$Camera2D.zoom.y *= 1 - zoom_factor
	
