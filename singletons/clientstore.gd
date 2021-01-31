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
  # The different systems under the player's control, stored locally
  "owned_systems":0,

  # reputations
  "rep_merchants": 0,
  "rep_pirates": 0,
 }

# This is a key/value entry for each planet we know about
# key = string index ('0' for _system[0])
# value = "visited" or "owned"
var system_knowledge: Dictionary = {

 }

# Key Value Pair
var systems: Dictionary = {}


func set_state(val_key: String, val) -> void:
  values[val_key] = val
  emit_signal("resources_changed", val_key, values[val_key])
  print("State changed: ", val_key, " -> ", values[val_key])


func get_state(val_key: String):
  return values[val_key]


func get_visit_status(sys_idx: int)-> String:
  var key=str(sys_idx)
  if system_knowledge.has(key):
    return system_knowledge[key]
  else:
    return("unknown")


func set_visit_status(sys_idx: int, state: String)-> void:
  if (state!="owned")&&(state!="visited"):
    return
  var key=str(sys_idx)
  if system_knowledge.has(key):
    if (system_knowledge[key]=="owned")&&(state=="visited"):
      return
  system_knowledge[key]=state
  if (state=="owned"):
    var owned=values["owned_systems"]+1
    set_state("owned_systems",owned)


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
