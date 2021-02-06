extends Node2D

onready var _area2d: Area2D = $"./Area2D"
onready var _collision_shape: CollisionShape2D = $"./Area2D/CollisionShape2D"
onready var _label: Label = $"./Label"
onready var _sprite: Sprite = $"./Sprite"

var system: Dictionary

var _fleet_present: bool
var _hovered: bool
var _targeted: bool

func initialize(new_system: Dictionary) -> void:
  system = new_system

  var _scale_modifier: float = lerp(-0.05, 0.15, system.star.size / 30.0)

  _sprite.modulate = Color(system.star.colorHex)
  global_position = Vector2((system.position.x - 960) * 25, (system.position.y - 540) * 25)
  _sprite.scale = Vector2(0.15 + _scale_modifier, 0.15 + _scale_modifier)
  _collision_shape.shape.radius = (_sprite.texture.get_size().x * _sprite.scale.x) / 2

func _draw():
  if system.owner == Store.state.uid:
    draw_arc(Vector2(), 300, 0, PI * 2, 32, ClientConstants.COLOR_GREEN)
  if (_hovered || _targeted) && Store.state.selection.is_in_range(self):
    var i = 0
    var col = Color(1,1,1,1)
    for planet in system.planets:
      i += 30
      col = Color(planet.colorHex)
      draw_arc(Vector2(), 320 + i, 0, PI * 2, 32, col, 3, true)

func _evaluate_name_label():
  if Store.state.selection == null:
    _label.text = "???"
    return

  if _fleet_present:
    _label.text = system.name
    return

  if _hovered || _targeted:
    if Store.state.selection.is_in_range(self):
      _label.text = "{name} ({fuel} fuel to travel)".format({
        "name": system.name,
        "fuel": stepify(Store.state.selection.get_fuel_consumption_to_target(self), 1)
      })
    else:
      _label.text = "???"
  else:
    _label.text = ""

func _on_area2d_input_event(node, event, shape_index):
  if (event is InputEventMouseButton && event.pressed && (event.button_index == BUTTON_LEFT || event.button_index == BUTTON_RIGHT)) || (event is InputEventScreenTouch && event.pressed):
    Store.set_state("target", self)

func _on_area2d_mouse_entered():
  _hovered = true
  _evaluate_name_label()

func _on_area2d_mouse_exited():
  _hovered = false
  _evaluate_name_label()

func _on_store_fleet_arrived(fleet, target_system):
  _fleet_present = target_system == self

  if _fleet_present:
    _label.text = system.name

func _on_store_state_changed(state_key, substate):
  match state_key:
    "target":
      if substate == self:
        _targeted = true
      else:
        _targeted = false

      _evaluate_name_label()

func _on_galaxy_controller_system_updated(updating_system: Dictionary):
  if system.name == updating_system.name:
    system = updating_system

func _process(_delta):
  if _targeted && !_fleet_present:
    _label.text = "{name} ({fuel} fuel to travel)".format({
      "name": system.name,
      "fuel": stepify(Store.state.selection.get_fuel_consumption_to_target(self), 1)
    })
  update()

func _ready():
  _area2d.connect("mouse_entered", self, "_on_area2d_mouse_entered")
  _area2d.connect("mouse_exited", self, "_on_area2d_mouse_exited")
  _area2d.connect("input_event", self, "_on_area2d_input_event")
  Store.connect("fleet_arrived", self, "_on_store_fleet_arrived")
  Store.connect("state_changed", self, "_on_store_state_changed")
  GalaxyController.connect("system_updated", self, "_on_galaxy_controller_system_updated")
