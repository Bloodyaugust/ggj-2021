extends Node

onready var _gameEnd = $GameEnd
onready var _timer = $Timer

# Time in seconds
const timerInterval = 2

func _connection_completed(response, code, headers, body):
  var json = JSON.parse(body.get_string_from_utf8()).result
  Store.set_state("gameOver", [json.gameStatus, json.winner])

func _on_Timer_timeout():
  _gameEnd.request(ClientConstants.ENDPOINT_LOCAL + "gameover")

func _start_Timer():
  _timer.start(timerInterval)

func _stop_Timer():
  _timer.stop()

func _ready():
  _gameEnd.connect("request_completed", self, "_connection_completed")
  
