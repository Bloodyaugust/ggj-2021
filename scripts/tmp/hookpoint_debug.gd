extends Control

var _systems: Array
var owned:String

onready var textEdit = $TextEdit

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
  owned = name
  $ServerHook/SetOwnershipEndpoint._attempt_control(name)

func _on_Button3_pressed():
  var rng = RandomNumberGenerator.new()
  rng.randomize()
  var name = _systems[rng.randi_range(0, _systems.size())].name
  $ServerHook/ExplorationEndpoint._attempt_exploration(name)

func _on_Button4_pressed():
  $ServerHook/GetGalaxyEndpoint._request_galaxy()

func _on_Button5_pressed():
  $ServerHook/RenameEndpoint._attempt_rename(owned, textEdit.get_text())

func _on_Button6_pressed():
  $ServerHook._win_the_game()
