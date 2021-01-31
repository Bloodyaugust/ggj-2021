extends Node

onready var _get_galaxy: HTTPRequest = $"GetGalaxy"

func _on_request_completed(response, code, headers, body):
  var _json = JSON.parse(body.get_string_from_utf8())

  var _systems: Array = _json.result.systems

  #var _systems_data: Dictionary = {}
  #for _system in _systems:
  #  if _systems_data.has(_system.star.sequence):
  #    _systems_data[_system.star.sequence] += 1
  #  else:
  #    _systems_data[_system.star.sequence] = 0

  #Clientstore.set_state("systems_data", _systems_data)
  Clientstore._load_all_systems(_systems)

func _request_galaxy():
  _get_galaxy.request(ClientConstants.ENDPOINT_LOCAL + "galaxy")

func _ready():
  _get_galaxy.connect("request_completed", self, "_on_request_completed")
