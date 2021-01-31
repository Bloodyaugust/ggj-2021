extends Node

onready var _register : HTTPRequest = $"Ownership"

func _request_completed(result, response_code, headers, body):
  var json = JSON.parse(body.get_string_from_utf8())
  Store.set_state("system_claim", json["system"])

func _attempt_control(sys_name: String):
  var query = "{userID: " + str(Store.state["uid"]) + ", systemName:" + sys_name + "}"
  _register.request("http://localhost:3000/ownership", [], true, HTTPClient.METHOD_GET, query)

func _ready():
  _register.connect("request_completed", self, "_request_completed")

