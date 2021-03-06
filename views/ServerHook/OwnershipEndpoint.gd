extends Node

onready var _register : HTTPRequest = $"Ownership"

func _request_completed(result, response_code, headers, body):
  var json = JSON.parse(body.get_string_from_utf8()).result
  Clientstore.set_state("ownership", json)

func _attempt_control(sys_name: String):
  var query = to_json({ "userID": Store.state["uid"], "systemName": sys_name })
  
  _register.request(ClientConstants.ENDPOINT_ACTUAL + "owner", ClientConstants.HEADER,\
    true, HTTPClient.METHOD_POST, query)

func _ready():
  _register.connect("request_completed", self, "_request_completed")

