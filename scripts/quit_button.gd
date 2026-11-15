extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _pressed():
	if disabled:
		return
	disabled = true
	var click: AudioStreamPlayer = $"../MenuClick"
	click.play()
	await click.finished
	print("quit!")
	get_tree().quit()
