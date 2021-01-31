extends Node

signal resources_changed(val_key, val)
signal systems_changed(sys_key, sys)

var values: Dictionary = {
  # The game's currency -- how you pay to upkeep fleets, admin, etc.
  "credits":0,
  # You like seeing planets, kid?
  "fuel":0,
  # Om nom nom nom I like food... Why is my tooth chipped?
  "supplies":0,
  # The Borg would like to know your location
  # The different systems under the player's control, stored locally
  "owned_systems":0
 }

# Key Value Pair
var systems: Dictionary = {}

func set_state(val_key: String, val) -> void:
  values[val_key] = val
  emit_signal("resources_changed", val_key, values[val_key])
  print("State changed: ", val_key, " -> ", values[val_key])

func get_state(val_key: String):
  return values[val_key]

func set_system(sys_key: String, sys) -> void:
  systems[sys_key] = sys
  emit_signal("systems_changed", sys_key, sys[sys_key])
  print("State changed: ", sys_key, " -> ", systems[sys_key])

func get_system(val_key: String):
  return systems[val_key]

func _initialize():
  pass

func _ready():
  call_deferred("_initialize")
