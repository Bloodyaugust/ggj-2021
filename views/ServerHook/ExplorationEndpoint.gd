extends Node

onready var _explore: HTTPRequest = $"Explore"

func _request_completed(result, response_code, headers, body):
  if response_code == 200:
    var json = JSON.parse(body.get_string_from_utf8()).result
    print(json)
    var system_data = [json["system"]["name"], json["system"]["explorers"], json["system"]["owner"]]
    Clientstore.set_state("exploration", system_data)

func _attempt_exploration(sys_id: String):
  var query = to_json({"userID": str(Store.state["uid"]), "systemName":sys_id})
  _explore.request(ClientConstants.ENDPOINT_LOCAL + "explore", ClientConstants.HEADER, \
    true, HTTPClient.METHOD_POST, query)

func _ready():
  _explore.connect("request_completed", self, "_request_completed")

