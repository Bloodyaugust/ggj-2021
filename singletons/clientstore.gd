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

  # fuel tick if you are sitting in an owned system
  "fuel_tick": 0,
  # no more fuel than this in the tank
  "fuel_max": 2000,

  # reputations
  "rep_merchants": 0,
  "rep_pirates": 0,
 }

# This is a key/value entry for each planet we know about
# key = system name (canonical name, not player name)
# value = "visited" or "owned"
var system_knowledge: Dictionary = {

 }

# Key Value Pair
var systems: Dictionary = {}


func set_state(val_key: String, val) -> void:
  values[val_key] = val
  emit_signal("resources_changed", val_key, values[val_key])
  if (val_key!="fuel"):
    print("Client resources changed: ", val_key, " -> ", values[val_key])


func get_state(val_key: String):
  return values[val_key]


func get_visit_status(sys_name: String)-> String:
  if system_knowledge.has(sys_name):
    return system_knowledge[sys_name]
  else:
    return("unknown")


func set_visit_status(sys_name: String, state: String)-> void:
  if (state!="owned")&&(state!="visited")&&(state!="enemy_owned"):
    return
  if system_knowledge.has(sys_name):
    if (system_knowledge[sys_name]=="owned")&&(state=="visited"):
      return

  if (state=="enemy_owned")&&(system_knowledge[sys_name]=="owned"):
    system_knowledge[sys_name]=state
    var owned=values["owned_systems"]-1
    set_state("owned_systems",owned)
    return

  system_knowledge[sys_name]=state
  if (state=="owned"):
    var owned=values["owned_systems"]+1
    set_state("owned_systems",owned)


func set_system(sys_key: String, sys) -> void:
  systems[sys_key] = sys
  emit_signal("systems_changed", sys_key, sys[sys_key])
  print("Client system changed: ", sys_key, " -> ", systems[sys_key])

func get_system(val_key: String):
  return systems[val_key]

func _load_all_systems(sys):
  systems = sys
  print("All systems have been loaded into Clientstate.")

func _initialize():
  pass

func _ready():
  call_deferred("_initialize")
