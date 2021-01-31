extends Node

var _galaxy_getter: HTTPRequest

func load_galaxy() -> void:
  _galaxy_getter.request(ClientConstants.ENDPOINT_LOCAL + "galaxy")

func _on_galaxy_getter_request_completed(response, code, headers, body):
  var _json = JSON.parse(body.get_string_from_utf8())

  Store.set_state("systems", _json.result.systems)

func _ready():
  _galaxy_getter = HTTPRequest.new()

  _galaxy_getter.connect("request_completed", self, "_on_galaxy_getter_request_completed")

  add_child(_galaxy_getter)
  load_galaxy()
