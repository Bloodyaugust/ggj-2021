extends Node

onready var _gameEnd = $GameEnd
onready var _timer = $Timer

# Time in seconds
const timerInterval = 2

func _connection_completed(response, code, headers, body):
  var _response_body: String = body.get_string_from_utf8()
  
  var _json: Dictionary = JSON.parse(_response_body).result
  if _json.winner:
    Store.set_state("winner", _json.winner)
    Store.set_state("game", GameConstants.GAME_ENDING)

func _on_Timer_timeout():
  var query = to_json({"userID": str(Store.state["uid"])})
  _gameEnd.request(ClientConstants.ENDPOINT_ACTUAL + "gameover", ClientConstants.HEADER,\
    true, HTTPClient.METHOD_POST, query)

func _start_Timer():
  _timer.start(timerInterval)

func _stop_Timer():
  _timer.stop()

func _ready():
  _gameEnd.connect("request_completed", self, "_connection_completed")

