extends Node2D

onready var _area2d: Area2D = $"./Area2D"
onready var _collision_shape: CollisionShape2D = $"./Area2D/CollisionShape2D"
onready var _sprite: Sprite = $"./Sprite"

var system: Dictionary

func initialize(new_system: Dictionary) -> void:
  system = new_system

  var _scale_modifier: float = lerp(-0.05, 0.15, system.star.size / 30.0)

  _sprite.modulate = Color(system.star.colorHex)
  global_position = Vector2(system.position.x * 25, system.position.y * 25)
  _sprite.scale = Vector2(0.15 + _scale_modifier, 0.15 + _scale_modifier)
  _collision_shape.shape.radius = (_sprite.texture.get_size().x * _sprite.scale.x) / 2

func _on_area2d_input_event(node, event, shape_index):
  if (event is InputEventMouseButton && event.pressed) || (event is InputEventScreenTouch && event.pressed):
    Store.set_state("target", self)

func _ready():
  _area2d.connect("input_event", self, "_on_area2d_input_event")
