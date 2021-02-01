extends Path2D

onready var _path_follow = get_node("PathFollow2D")

func _on_state_changed(state_key: String, substate):
  match state_key:
    "client_view":
      match substate:
        ClientConstants.CLIENT_VIEW_NONE:
          set_process(false)
          _path_follow.set_unit_offset(0.6)
        ClientConstants.CLIENT_VIEW_MAIN_MENU:
          set_process(true)
          _path_follow.set_unit_offset(0)
          

func _ready():
  set_process(true)
  Store.connect("state_changed", self, "_on_state_changed")

func _process(delta):
  _path_follow.set_offset(_path_follow.get_offset() + 125 * delta)
