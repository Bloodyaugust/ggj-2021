extends Control

var _systems: Array

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")

func _on_state_changed(state_key, substate):
  if state_key == "systems":
    _systems = Store.state["systems"]

func _on_Button_pressed():
  $ServerHook/RegisterEndpoint._attempt_connection()

func _on_Button2_pressed():
  var rng = RandomNumberGenerator.new()
  rng.randomize()
  var name = _systems[rng.randi_range(0, _systems.size())].name
  $ServerHook/SetOwnershipEndpoint._attempt_control(name)

func _on_Button3_pressed():
  var rng = RandomNumberGenerator.new()
  rng.randomize()
  var name = _systems[rng.randi_range(0, _systems.size())].name
  $ServerHook/ExplorationEndpoint._attempt_exploration(name)
  pass

func _on_Button4_pressed():
  $ServerHook/GetGalaxyEndpoint._request_galaxy()
