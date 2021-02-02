extends Node

signal system_updated(system)

var _galaxy_getter: HTTPRequest

func get_system(name: String) -> Dictionary:
  for _system in Store.state.systems:
    if name == _system.name:
      return _system

  return {}

func load_galaxy() -> void:
  _galaxy_getter.request(ClientConstants.ENDPOINT_ACTUAL + "galaxy")

func update_system(system: Dictionary) -> void:
  for _system in Store.state.systems:
    if _system.name == system.name:
      _system = system
      emit_signal("system_updated", _system)
      return

func _on_galaxy_getter_request_completed(response, code, headers, body):
  var _json = JSON.parse(body.get_string_from_utf8())

  Store.set_state("systems", _json.result.systems)

func _ready():
  _galaxy_getter = HTTPRequest.new()

  _galaxy_getter.connect("request_completed", self, "_on_galaxy_getter_request_completed")

  add_child(_galaxy_getter)
  load_galaxy()
