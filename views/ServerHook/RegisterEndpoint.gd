extends Node

signal connection_attempts_expired()
signal connection_established()

onready var _send_endpoint: HTTPRequest = $"Register"

var connectAttempts = 0
var limitedAttempts = 25

var rng = RandomNumberGenerator.new()

func _send_endpoint_completed(result, response_code, headers, body):
  if response_code == 200:
    emit_signal("connection_established")
    var _json = JSON.parse(body.get_string_from_utf8()).result
    Store.set_state("starting_system", _json)
  elif response_code == 500:
    # Mostly an ID error, try again
    var id = rng.randi()
    var query = to_json({ "userID": str(id) })
    Store.set_state("uid", id)
    
    if ClientConstants.USE_LOCAL:
      _send_endpoint.request(ClientConstants.ENDPOINT_LOCAL + "register", ClientConstants.HEADER,\
        true, HTTPClient.METHOD_POST, query)
    else:
      _send_endpoint.request(ClientConstants.ENDPOINT_REMOTE + "register", ClientConstants.HEADER,\
        true, HTTPClient.METHOD_POST, query)
  else:
    if connectAttempts < limitedAttempts:
      var query = to_json({ "userID": str(Store.state["uid"]) })
      
      if ClientConstants.USE_LOCAL:
        _send_endpoint.request(ClientConstants.ENDPOINT_LOCAL + "register", ClientConstants.HEADER,\
          true, HTTPClient.METHOD_POST, query)
      else:
        _send_endpoint.request(ClientConstants.ENDPOINT_REMOTE + "register", ClientConstants.HEADER,\
          true, HTTPClient.METHOD_POST, query)
      
      connectAttempts += 1
    else:
      emit_signal("connection_attempts_expired")
      print("ran out of connection attempts")

# Prepare our UID and send it off to the server for registering
# ONLY RUN IF WE DON'T HAVE AN IDEA ALREADY
func _attempt_connection():
  rng.randomize()
  var id = rng.randi()
  var query = to_json({ "userID": str(id) })
  Store.set_state("uid", str(id))
  
  if ClientConstants.USE_LOCAL:
    _send_endpoint.request(ClientConstants.ENDPOINT_LOCAL + "register", ClientConstants.HEADER,\
      true, HTTPClient.METHOD_POST, query)
  else:
    _send_endpoint.request(ClientConstants.ENDPOINT_REMOTE + "register", ClientConstants.HEADER,\
      true, HTTPClient.METHOD_POST, query)

# Called when the node enters the scene tree for the first time.
func _ready():
  _send_endpoint.connect("request_completed", self, "_send_endpoint_completed")
  
