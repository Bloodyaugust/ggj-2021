extends Sprite

export(float) var _degrees_per_second := 2.5

func _process(delta):
  rotate(delta * deg2rad(_degrees_per_second))
