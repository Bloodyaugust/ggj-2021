extends Node


onready var _wonEndpoint = $WonEndpoint

func _request_completed(result, response_code, headers, body):
  var json = JSON.parse(body.get_string_from_utf8()).result
  print(json)
  print(response_code)
  #Store.set_state("gameOver", [json.gameStatus, json.winner]

func _send_win():
  var query = to_json({"userID": str(Store.state["uid"])})
  _wonEndpoint.request(ClientConstants.ENDPOINT_LOCAL + "won", ClientConstants.HEADER,\
    true, HTTPClient.METHOD_POST, query)
  print("sent")

func _ready():
  _wonEndpoint.connect("request_completed", self, "_request_completed")

