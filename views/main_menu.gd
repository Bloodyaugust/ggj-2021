extends Control

onready var _play_button: Button = find_node("Play")

func _on_play_button_pressed() -> void:
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_NONE)
  Store.set_state("game", GameConstants.GAME_STARTING)

func _on_state_changed(state_key: String, substate):
  match state_key:
    "client_view":
      match substate:
        ClientConstants.CLIENT_VIEW_MAIN_MENU:
          rect_position.y = 0
        _:
          rect_position.y = get_viewport().size.y
    "game":
      match substate:
        GameConstants.GAME_OVER:
          _play_button.disabled = true
    "systems":
      _play_button.disabled = false

func _ready():
  _play_button.connect("pressed", self, "_on_play_button_pressed")
  Store.connect("state_changed", self, "_on_state_changed")
