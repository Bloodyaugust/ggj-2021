extends Node

signal connection_attempts_expired()
signal connection_established()

onready var _send_endpoint: HTTPRequest = $"Register"

var connectAttempts = 0
var limitedAttempts = 25

var rng = RandomNumberGenerator.new()

func _send_endpoint_completed(result, response_code, headers, body):
  if response_code == 200:
    var file = File.new()
    file.open("res://player.info", File.WRITE)
    var uid = Store.state["uid"]
    file.store_var(uid)
    file.close()
    emit_signal("connection_established")
  elif response_code == 500:
    # Mostly an ID error, try again
    var id = rng.randi()
    var query = to_json({ "userID": str(id) })
    Store.set_state("uid", id)
    _send_endpoint.request("http://localhost:3000/register", ClientConstants.HEADER, \
      true, HTTPClient.METHOD_POST, query)
  else:
    if connectAttempts < limitedAttempts:
      var query = to_json({ "userID": str(Store.state["uid"]) })
      _send_endpoint.request("http://localhost:3000/register", ClientConstants.HEADER, \
        true, HTTPClient.METHOD_POST, query)
      connectAttempts += 1
    else:
      emit_signal("connection_attempts_expired")
      print("ran out of connection attempts")

# Prepare our UID and send it off to the server for registering
# ONLY RUN IF WE DON'T HAVE AN IDEA ALREADY
func _attempt_connection():
  var file = File.new()
  if file.file_exists("res://player.info") == false:
    rng.randomize()
    var id = rng.randi()
    var query = to_json({ "userID": str(id) })
    Store.set_state("uid", str(id))
    _send_endpoint.request("http://localhost:3000/register", ClientConstants.HEADER, true, HTTPClient.METHOD_GET, query)
  else:
    file.open("res://player.info", File.READ)
    var uid = file.get_var()
    file.close()
    Store.set_state("uid", uid)

# Called when the node enters the scene tree for the first time.
func _ready():
  _send_endpoint.connect("request_completed", self, "_send_endpoint_completed")
  
