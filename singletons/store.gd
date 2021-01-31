extends Node

signal fleet_arrived(fleet, target)
signal state_changed(state_key, substate)

var state: Dictionary = {
  "client_view": "",
  "game": "",
  "uid": "", # Unique user ID, generated locally once and stored
  "selection": null, # Selected Fleet actor
  "systems": [], # Systems in the galaxy, fetched from server
  "target": null # StarSystem actor targeted for action
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
