extends Sprite

var _system: Dictionary

func initialize(system: Dictionary) -> void:
  _system = system

  var _scale_modifier: float = lerp(-0.05, 0.15, _system.star.size / 30.0)

  modulate = Color(_system.star.colorHex)
  global_position = Vector2(_system.position.x * 25, _system.position.y * 25)
  scale = Vector2(0.15 + _scale_modifier, 0.15 + _scale_modifier)
