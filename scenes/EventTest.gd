extends Node2D

onready var _get_galaxy: HTTPRequest = $GetGalaxy
onready var _tree := get_tree()

var _systems: Array

# event selection variables
var seeded_rnd = RandomNumberGenerator.new()
var regex = RegEx.new()
var weighted = preload("res://lib/chance/WeightedTable.gd")
var events={}
var weighted_events={}
var active_options=[]

# current system state
var current_system_idx = -1
var current_system = null

func _ready():
  # stuff that should be in main game loop
  $GUI/Control/MarginContainer/VBoxContainer/HBoxContainer/SystemID.text="Travelling to system: "
  $GUI/EventPopup.visible=false

  _get_galaxy.connect("request_completed", self, "_on_request_completed")
  _get_galaxy.request("http://localhost:3000/galaxy")

  Clientstore.set_state("supplies",rand_range(40,60))
  Clientstore.set_state("credits",rand_range(50,100))
  Clientstore.set_state("fuel",rand_range(180,220))

  # --- normal init
  # Create event probablity tables
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

  # update UI by faking a resource change
  _resources_changed("",0)

  # set-up connections
  $GUI/EventPopup.connect("choice_selected",self,"_on_choiceSelected")
  Clientstore.connect("resources_changed",self,"_resources_changed")
  regex.compile("({[^}]+})")


func _resources_changed(_key, _value):
  $GUI/Control/MarginContainer/VBoxContainer/HBoxContainer/PlanetsLabel.text="Systems Owned: "+str(int(Clientstore.get_state("owned_systems")))
  $GUI/Control/MarginContainer/VBoxContainer/HBoxContainer/CreditLabel.text="Credits: "+str(int(Clientstore.get_state("credits")))
  $GUI/Control/MarginContainer/VBoxContainer/HBoxContainer/SupplyLabel.text="Supplies: "+str(int(Clientstore.get_state("supplies")))
  $GUI/Control/MarginContainer/VBoxContainer/HBoxContainer/FuelLabel.text="Fuel: "+str(int(Clientstore.get_state("fuel")))

  # not needed if we have other current_system info
  if (_key!=""):
    display_system(current_system)

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
    planet["pop"]=seeded_rnd.randf_range(planet["popMin"],planet["popMax"])
    planet["hos"]=seeded_rnd.randf_range(planet["hosMin"],planet["hosMax"])
    planet["conq"]=planet["difficulty"]+(planet["pop"])+(planet["hos"])
    sysConq+=planet["conq"]
  current_system["sysConq"]=sysConq
  current_system["status"]=Clientstore.get_visit_status(current_system.name)


func display_system(system):
  var text="System: "+system.name+"  ("+current_system["status"]+")\n"
  text+="Star: "+system.star.sequence+" ["+str(system.position.x)+", "+str(system.position.y)+"]\n"
  var idx=1
  for planet in system.planets:
    text+="  Planet "+str(idx)+": "+planet.type+" credits: "+str(planet.credits)+" fuel: "+str(planet.fuel)+" supplies: "+str(planet.supplies)+" "+str(planet.pop)+" "+str(planet.hos)+"\n"
    idx+=1
  text+="Effort to conquer system: "+str(int(system.sysConq))
  $GUI/Control/MarginContainer/VBoxContainer/SystemInfo.text=text


func travel_to_system(value):
  current_system_idx=value
  update_current_system()
  display_system(current_system)
  Clientstore.set_visit_status(current_system.name,"visited")

  if (current_system.status!="owned"):
    var effort = current_system.sysConq
    var event_type=-1
    if (effort>0):
      event_type=0 # conq
    else:
      event_type=1 # empty

    var event=events[weighted_events[str(event_type)].pick_seeded(seeded_rnd.randi()).type]
    populate_event(event)


func randomize_flavor_text(text)->String:
# take text like:
#   Your {shuttle/ship} sets down on a landing platform. {You stare apprehensively down./The floating station sways./You fall over.}"
# Where blocks inside of {} replaced with an even choice of / divided phrases
  var text_out=""
  while(!text.empty()):
    var m=regex.search(text)
    if (m==null):
      text_out+=text
      break
    else:
      text_out+=text.left(m.get_start())
      var choice=m.get_string().trim_prefix("{").trim_suffix("}").split("/")
      text_out+=choice[seeded_rnd.randi_range(0,choice.size()-1)]
      text.erase(0,m.get_end())
  return text_out


func check_min_option(key,min_value) -> bool:
  var value=Clientstore.get_state(key)
  return value>=min_value


func pay_cost(costs):
  for key in costs.keys():
    var cost=costs[key]
    var update=Clientstore.get_state(key)-cost
    Clientstore.set_state(key,update)

func get_stuff(rewards):
  for key in rewards.keys():
    match key:
      "system":
        var system_name=rewards[key]
        current_system["status"]="owned"
        Clientstore.set_visit_status(system_name,"owned")
      _:
        var goods=rewards[key]
        var update=Clientstore.get_state(key)+goods
        Clientstore.set_state(key,update)


func populate_event(event):
  var conq_supply=int(current_system.sysConq)
  var conq_credit=int(current_system.sysConq*1.7)
  $GUI/EventPopup._set_event_title(randomize_flavor_text(event.title))
  $GUI/EventPopup._display_flavor_text(randomize_flavor_text(event.description))
  $GUI/EventPopup._set_flavor_picture(event.graphicID)

  active_options=[]
  match str(event.type):
    "0":  # conquor
      active_options=[
          {"text":"Use "+str(conq_supply)+" supplies to take the system","disabled":!check_min_option("supplies",conq_supply),"cost":{"supplies":conq_supply},"get":{"system":current_system.name}},
          {"text":"Pay "+str(conq_credit)+" credits to buy the system","disabled":!check_min_option("credits",conq_credit),"cost":{"credits":conq_credit},"get":{"system":current_system.name}},
          {"text":"Continue on","disabled":false}]
    "1":  # Empty system
      active_options=[{"text":"Continue on","disabled":false}]
    _:  #
      active_options=[{"text":"Nothing to do","disabled":false}]

  $GUI/EventPopup._display_button_text(active_options)
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
  $GUI/Control/MarginContainer/VBoxContainer/HBoxContainer/SpinBox.min_value=0
  $GUI/Control/MarginContainer/VBoxContainer/HBoxContainer/SpinBox.max_value=_systems.size()
  $GUI/Control/MarginContainer/VBoxContainer/HBoxContainer/SpinBox.value=0
  $GUI/Control/MarginContainer/VBoxContainer/HBoxContainer/SystemID.text="Arrived in system: "
  travel_to_system(0)


func _on_SpinBox_value_changed(value):
  travel_to_system(value)


func _on_choiceSelected(value):
  if (value>=0)&&(value<active_options.size()):
    if (active_options[value].has("cost")):
      pay_cost(active_options[value].cost)
    if (active_options[value].has("get")):
      get_stuff(active_options[value].get)
