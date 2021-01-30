extends Node

onready var _get_galaxy: HTTPRequest = $"../GetGalaxy"
onready var _send_endpoint: HTTPRequest = $"../SendEndpoint"
onready var _explore: HTTPRequest = $"../Explore"

var connectAttempts = 0
var limitedAttempts = 5

func _on_play_button_pressed() -> void:
  Clientstore.set_state("client_view", ClientConstants.CLIENT_VIEW_NONE)

func _on_state_changed(state_key: String, substate):
  pass

func _send_endpoint_compeleted(result, response_code, headers, body):
  if result == RESULT_SUCCESS:
    var json = JSON.parse(result)
  else:
    # Attempt to retry
    _send_endpoint.request("http://localhost:3000/endpoint", headers, true, HTTPClient.METHOD_POST, query)

func _ready():
  _get_galaxy.connect("request_completed", self, "_on_request_completed")
  _send_endpoint.connect("request_completed", self, "_send_endpoint_completed")
  _explore.connect("request_completed", self, "_on_request_completed")
  
  _get_galaxy.request("http://localhost:3000/galaxy")
  
  # Prepare 
  var headers = ["user: new"]
  var rng = RandomNumberGenerator.new()
  rng.randomize()
  var id = rng.rand()
  var query = "{ \"id\": " + str(id) + "}"
  _send_endpoint.request("http://localhost:3000/endpoint", headers, true, HTTPClient.METHOD_POST, query)
