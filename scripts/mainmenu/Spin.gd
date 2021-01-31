extends Sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  rotate(delta * deg2rad(2.5))
