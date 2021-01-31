extends Node2D

export var use_remote: bool
export var min_star_size: float
export var star_scale: float

onready var _get_galaxy: HTTPRequest = $"../GetGalaxy"
onready var _tree := get_tree()

var _systems: Array

func _draw():
  for _system in _systems:
    var _star_size = _system.star.size * star_scale

    if _star_size < min_star_size:
      _star_size = min_star_size

    draw_circle(Vector2(_system.position.x, _system.position.y), _star_size, Color(_system.star.colorHex))

func _on_request_completed(response, code, headers, body):
  var _json = JSON.parse(body.get_string_from_utf8())

  _systems = _json.result.systems

  var _systems_data: Dictionary = {}
  for _system in _systems:
    if _systems_data.has(_system.star.sequence):
      _systems_data[_system.star.sequence] += 1
    else:
      _systems_data[_system.star.sequence] = 1

  Store.set_state("systems_data", _systems_data)

func _process(_delta):
  update()

func _ready():
  _get_galaxy.connect("request_completed", self, "_on_request_completed")

  if use_remote:
    _get_galaxy.request(ClientConstants.ENDPOINT_REMOTE + "galaxy")
  else:
    _get_galaxy.request(ClientConstants.ENDPOINT_LOCAL + "galaxy")
