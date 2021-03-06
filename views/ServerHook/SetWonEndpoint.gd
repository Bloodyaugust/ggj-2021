extends Node


onready var _wonEndpoint = $WonEndpoint

func _request_completed(result, response_code, headers, body):
  var json = JSON.parse(body.get_string_from_utf8()).result
  
  if json.winner == Store.state.uid:
    print("Confirmed as winner")

func _send_win():
  var query = to_json({"userID": str(Store.state["uid"])})
  _wonEndpoint.request(ClientConstants.ENDPOINT_ACTUAL + "won", ClientConstants.HEADER,\
    true, HTTPClient.METHOD_POST, query)

func _ready():
  _wonEndpoint.connect("request_completed", self, "_request_completed")

