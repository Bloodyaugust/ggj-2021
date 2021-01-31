extends Node2D

export var speed: float

onready var _area2d: Area2D = $"./Area2D"
onready var _camera: Camera2D = get_tree().get_root().find_node("RTS-Camera2D", true, false)
onready var _sprite: Sprite = $"./Sprite"

var _current_scale: float
var _selected: bool

func _on_area2d_input_event(node, event, shape_index):
  if (event is InputEventMouseButton && event.pressed) || (event is InputEventScreenTouch && event.pressed):
    Store.set_state("selection", self)

func _on_store_state_changed(state_key, substate):
  match state_key:
    "selection":
      if substate == self:
        _selected = true
      else:
        _selected = false

func _draw():
  if _selected:
    draw_arc(Vector2(), (800.0 * _current_scale) * lerp(0.5, 1.1, (sin(OS.get_ticks_msec() / 500.0) + 1.0) / 2.0), 0, PI * 2, 30, ClientConstants.COLOR_GREEN)

func _process(_delta):
  _current_scale = lerp(0.10, 1, _camera.zoom.x / 20)

  _sprite.scale = Vector2(_current_scale, _current_scale)
  update()

func _ready():
  _area2d.connect("input_event", self, "_on_area2d_input_event")
  Store.connect("state_changed", self, "_on_store_state_changed")
