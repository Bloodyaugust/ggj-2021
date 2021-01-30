extends Node

signal state_changed(state_key, substate)

var state: Dictionary = {
  "client_view": "",
  "game": "",
  # The game's currency -- how you pay to upkeep fleets, admin, etc.
  "credits":0,
  # You like seeing planets, kid?
  "fuel":0,
  # Om nom nom nom I like food... Why is my tooth chipped?
  "supplies":0,
  # The Borg would like to know your location
  # The different systems under the player's control, stored locally
  "owned_systems":[]
 }

func set_state(state_key: String, new_state) -> void:
  state[state_key] = new_state
  emit_signal("state_changed", state_key, state[state_key])
  print("State changed: ", state_key, " -> ", state[state_key])
  
func _initialize():
  set_state("client_view", ClientConstants.CLIENT_VIEW_MAIN_MENU)
  set_state("game", GameConstants.GAME_OVER)

func _ready():
  call_deferred("_initialize")
