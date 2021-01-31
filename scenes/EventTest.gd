extends Node2D

onready var _get_galaxy: HTTPRequest = $GetGalaxy
onready var _tree := get_tree()

var seeded_rnd = RandomNumberGenerator.new()
var weighted = preload("res://lib/chance/WeightedTable.gd")

var _systems: Array

var current_system_idx = -1
var current_system = null

var events={}
var weighted_events={}

func _ready():
  $GUI/Control/VBoxContainer/HBoxContainer/SystemID.text="Travelling to system: "
  $GUI/EventPopup.visible=false

  _get_galaxy.connect("request_completed", self, "_on_request_completed")
  _get_galaxy.request("http://localhost:3000/galaxy")

  var event_tables={}
  var all_events=Castledb.get_entries("Event")
  for event in all_events:
    events[event.eventID]=event
    if (event_tables.has(str(event.type))):
      event_tables[str(event.type)].append({"type":event.eventID,"weight":event.weight})
    else:
      event_tables[str(event.type)]=[{"type":event.eventID,"weight":event.weight}]

  for table_type in event_tables.keys():
    var wtable=weighted.new()
    wtable.initialize_table(event_tables[table_type])
    weighted_events[table_type]=wtable


#func _process(_delta):
  #update()


func update_current_system():
  var idx=current_system_idx
  if (idx>=_systems.size()):
    print("Off the map!")
    idx=0

  # seed rng, so we can recreate
  current_system=_systems[idx].duplicate()
  var loc=str(current_system.position.x)+str(current_system.position.y)
  seeded_rnd.set_seed(loc.hash())

  var sysConq=0.0
  for planet in current_system.planets:
    planet["pop"]=planet["popBase"]+seeded_rnd.randf()*planet["popMod"]
    planet["hos"]=planet["hosBase"]+seeded_rnd.randf()*planet["hosMod"]
    planet["conq"]=planet["difficulty"]*(planet["pop"]/planet["popBase"])*(planet["hos"]/planet["hosBase"])
    sysConq+=planet["conq"]
  current_system["sysConq"]=sysConq


func display_system(system):
  var text="Star: "+system.star.sequence+" ["+str(system.position.x)+", "+str(system.position.y)+"]\n"
  var idx=1
  for planet in system.planets:
    text+="  Planet "+str(idx)+": "+planet.type+" credits: "+str(planet.credits)+" fuel: "+str(planet.fuel)+" supplies: "+str(planet.supplies)+" "+str(planet.pop)+" "+str(planet.hos)+"\n"
    idx+=1
  text+="Effort to conquor system: "+str(system.sysConq)
  $GUI/Control/VBoxContainer/SystemInfo.text=text


func travel_to_system(value):
  current_system_idx=value
  update_current_system()
  display_system(current_system)

  var effort = current_system.sysConq
  var event_type=-1
  if (effort>0):
    event_type=0 # conq
  else:
    event_type=1 # empty

  var event=events[weighted_events[str(event_type)].pick_seeded(seeded_rnd.randi()).type]
  populate_event(event)


func populate_event(event):
  $GUI/EventPopup._set_event_title(event.title)
  $GUI/EventPopup._display_flavor_text(event.description)

  match str(event.type):
    "0":  # conquor
      $GUI/EventPopup._display_button_text(["Use supplies to take system","Use credits to take system","Move on"])
    _:  #
      $GUI/EventPopup._display_button_text(["Move on"])

  $GUI/EventPopup.popup_centered()


func _on_request_completed(response, code, headers, body):
  var _json = JSON.parse(body.get_string_from_utf8())

  _systems = _json.result.systems

  var _systems_data: Dictionary = {}
  for _system in _systems:
    if _systems_data.has(_system.star.sequence):
      _systems_data[_system.star.sequence] += 1
    else:
      _systems_data[_system.star.sequence] = 0
  Store.set_state("systems_data", _systems_data)

  # start at the very beginning
  $GUI/Control/VBoxContainer/HBoxContainer/SpinBox.min_value=0
  $GUI/Control/VBoxContainer/HBoxContainer/SpinBox.max_value=_systems.size()
  $GUI/Control/VBoxContainer/HBoxContainer/SpinBox.value=0
  $GUI/Control/VBoxContainer/HBoxContainer/SystemID.text="Arrived in system: "
  travel_to_system(0)


func _on_SpinBox_value_changed(value):
  travel_to_system(value)
