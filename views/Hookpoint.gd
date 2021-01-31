extends Node

signal connection_attempts_expired()

onready var _get_galaxy: HTTPRequest = $"GetGalaxy"
onready var _send_endpoint: HTTPRequest = $"Register"
onready var _explore: HTTPRequest = $"Explore"

var connectAttempts = 0
var limitedAttempts = 25

var rng = RandomNumberGenerator.new()

# Our attempt to connect to the server
func _send_endpoint_completed(result, response_code, headers, body):
  print(response_code)
  if response_code == 200:
    var file = File.new()
    file.open("res://player.info", File.WRITE)
    var uid = Store.state["uid"]
    file.store_var(uid)
    file.close()
  elif response_code == 500:
    var id = rng.randi()
    var query = "{id:" + str(id) +"}"
    Store.set_state("uid", query)
    _send_endpoint.request("http://localhost:3000/register", [], true, HTTPClient.METHOD_POST, query)
  else:
    if connectAttempts < limitedAttempts:
      _send_endpoint.request("http://localhost:3000/register", [], true, HTTPClient.METHOD_POST, Store.state["uid"])
      connectAttempts += 1
    else:
      emit_signal("connection_attempts_expired")
      print("ran out of connection attempts")
  
func _ready():
  _get_galaxy.connect("request_completed", self, "_on_request_completed")
  _send_endpoint.connect("request_completed", self, "_send_endpoint_completed")
  _explore.connect("request_completed", self, "_on_request_completed")
  
  # Get the galaxy information
  #_get_galaxy.request("http://localhost:3000/galaxy")
  
  # Prepare our UID and send it off to the server for registering
  # ONLY RUN IF WE DON'T HAVE AN IDEA ALREADY
  var file = File.new()
  if file.file_exists("res://player.info") == false:
    rng.randomize()
    var id = rng.randi()
    var query = "{id:" + str(0) +"}"
    Store.set_state("uid", "0")
    _send_endpoint.request("http://localhost:3000/register", [], true, HTTPClient.METHOD_POST, query)
  else:
    file.open("res://player.info", File.READ)
    var uid = file.get_var()
    file.close()
    Store.set_state("uid", uid)
