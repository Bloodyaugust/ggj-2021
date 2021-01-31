extends Node

onready var _rename: HTTPRequest = $"Rename"

func _on_request_completed(response, code, headers, body):
  if code == 500:
    print("error")
    return
  var _json = JSON.parse(body.get_string_from_utf8()).result
  #Clientstore.set_system(_json.system.name, _json)

func _attempt_rename(sys_id: String, sys_name: String):
  var query = to_json({"userID": str(Store.state["uid"]), "systemID": sys_id, "systemName": sys_name})
  
  if ClientConstants.USE_LOCAL:
    _rename.request(ClientConstants.ENDPOINT_LOCAL + "rename", ClientConstants.HEADER, \
      true, HTTPClient.METHOD_POST, query)
  else:
    _rename.request(ClientConstants.ENDPOINT_REMOTE + "rename", ClientConstants.HEADER, \
      true, HTTPClient.METHOD_POST, query)

func _ready():
  _rename.connect("request_completed", self, "_on_request_completed")
