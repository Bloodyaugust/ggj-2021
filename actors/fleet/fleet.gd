extends Node2D

enum fleet_states {
  IDLE,
  MOVING
}

export var move_range: float
export var speed: float

onready var _area2d: Area2D = $"./Area2D"
onready var _camera: Camera2D = get_tree().get_root().find_node("RTS-Camera2D", true, false)
onready var _sprite: Sprite = $"./Sprite"

var _current_scale: float
var _current_state: int
var _selected: bool
var _target: Node2D

func _on_area2d_input_event(node, event, shape_index):
  if (event is InputEventMouseButton && event.pressed && (event.button_index == BUTTON_LEFT || event.button_index == BUTTON_RIGHT)) || (event is InputEventScreenTouch && event.pressed):
    Store.set_state("selection", self)

func _on_store_state_changed(state_key, substate):
  match state_key:
    "selection":
      if substate == self:
        _selected = true
      else:
        _selected = false
    "target":
      if _selected && _current_state == fleet_states.IDLE && substate != null && global_position.distance_to(substate.global_position) <= move_range:
        _target = substate
        _current_state = fleet_states.MOVING

func _draw():
  if _selected:
    draw_arc(Vector2(), (1000.0 * _current_scale) * lerp(0.8, 1.1, (sin(OS.get_ticks_msec() / 500.0) + 1.0) / 2.0), 0, PI * 2, 30, ClientConstants.COLOR_GREEN)
    draw_arc(Vector2(),  move_range, 0, PI * 2, 30, ClientConstants.COLOR_BLUE)

    if _current_state == fleet_states.MOVING:
      draw_line(Vector2(), Vector2.RIGHT * global_position.distance_to(_target.global_position), ClientConstants.COLOR_LIGHT_BLUE)

func _process(delta):
  _current_scale = lerp(0.10, 1, _camera.zoom.x / 20)
  _sprite.scale = Vector2(_current_scale, _current_scale)

  match _current_state:
    fleet_states.MOVING:
      if _target.global_position.distance_squared_to(global_position) < (speed):
        _current_state = fleet_states.IDLE
        Store.emit_signal("fleet_arrived", self, _target)
        continue

      look_at(_target.global_position)
      translate((_target.global_position - global_position).normalized() * speed * delta)

  update()

func _ready():
  _current_state = fleet_states.IDLE

  _area2d.connect("input_event", self, "_on_area2d_input_event")
  Store.connect("state_changed", self, "_on_store_state_changed")
