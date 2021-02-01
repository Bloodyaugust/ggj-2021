extends Node

signal resource_tick_updated
onready var _event_popup: WindowDialog = $"../UIRoot/EventPopup"

# event selection variables
var seeded_rnd = RandomNumberGenerator.new()
var regex = RegEx.new()
var weighted = preload("res://lib/chance/WeightedTable.gd")
var events={}
var weighted_events={}
var active_options=[]

enum REQUIREMENT {
  player_owned = 1,
  enemy_owned = 2,
  visited = 4,
  undiscovered = 8,
  no_planets = 16,
  any_planet = 32,
  silicate_planet = 64,
  gas_planet = 128,
  desert_planet = 256,
  lava_planet = 512,
  ocean_planet = 1024,
  iron_planet = 2048,
  ice_planet = 4096,
  terrestrial_planet = 8192,
  chthonian_planet = 16384,
}

# current system state
var current_system = null

func _on_store_fleet_arrived(fleet, target_system):
  arrive_at_system(target_system.system)

func _ready():
  # set-up connections
  _event_popup.connect("choice_selected",self,"_on_choiceSelected")
  Store.connect("fleet_arrived", self, "_on_store_fleet_arrived")

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

  regex.compile("({[^}]+})")

func update_current_system(system):
  # seed rng, so we can recreate
  current_system= system.duplicate()
  var loc=str(current_system.position.x)+str(current_system.position.y)
  seeded_rnd.set_seed(loc.hash())

  current_system["planet_types"]={}
  var sysConq=0.0
  var sysFuel=0.0
  var sysSupplies=0.0
  var sysCredits=0.0
  for planet in current_system.planets:
    planet["pop"]=seeded_rnd.randf_range(planet["popMin"],planet["popMax"])
    planet["hos"]=seeded_rnd.randf_range(planet["hosMin"],planet["hosMax"])
    planet["conq"]=planet["difficulty"]+(planet["pop"])+(planet["hos"])
    current_system.planet_types[planet.type]="true"
    sysConq+=planet["conq"]
    sysFuel+=planet["fuel"]
    sysSupplies+=planet["supplies"]
    sysCredits+=planet["credits"]
  current_system["sysConq"]=sysConq
  current_system["sysFuel"]=sysFuel
  current_system["sysSupplies"]=sysSupplies
  current_system["sysCredits"]=sysCredits
  current_system["status"]=Clientstore.get_visit_status(current_system.name)


func get_event_type(event_type):
  var req=0
  if (current_system.status=="owned"):
    req=req|REQUIREMENT.player_owned
    req=req|REQUIREMENT.visited
  elif (current_system.status=="enemy_owned"):
    req=req|REQUIREMENT.enemy_owned
  elif (current_system.status=="visited"):
    req=req|REQUIREMENT.visited
  else:
    req=req|REQUIREMENT.undiscovered

  if (current_system.planets.empty()):
    req=req|REQUIREMENT.no_planets
  else:
    req=req|REQUIREMENT.any_planet
    if (current_system.planet_types.has("Silicate")):
      req=req|REQUIREMENT.silicate_planet
    if (current_system.planet_types.has("Gas")):
      req=req|REQUIREMENT.gas_planet
    if (current_system.planet_types.has("Desert")):
      req=req|REQUIREMENT.desert_planet
    if (current_system.planet_types.has("Lava")):
      req=req|REQUIREMENT.lava_planet
    if (current_system.planet_types.has("Ocean")):
      req=req|REQUIREMENT.ocean_planet
    if (current_system.planet_types.has("Iron")):
      req=req|REQUIREMENT.iron_planet
    if (current_system.planet_types.has("Ice")):
      req=req|REQUIREMENT.ice_planet
    if (current_system.planet_types.has("Terrestrial")):
      req=req|REQUIREMENT.terrestrial_planet
    if (current_system.planet_types.has("Chthonian")):
      req=req|REQUIREMENT.chthonian_planet

  for _i in range(1000):
    var event=events[weighted_events[str(event_type)].pick_seeded(seeded_rnd.randi()).type]
    var event_req=int(event.requirements)
    if (event_req!=0):
      if (req&event_req!=0):
        # print("Event found: ",_i)
        return event
    else:
      return event

  print("No event found!")
  return {}


func arrive_at_system(system):
  update_current_system(system)
  Clientstore.set_visit_status(current_system.name,"visited")

  if (current_system.status!="owned"):
    var effort = current_system.sysConq
    var event_type=-1
    if (effort>0):
      event_type=0 # conq
    else:
      event_type=1 # empty

    var event=get_event_type(0)
    # print("Intro: ",event)
    var text=event.description
    event=get_event_type(1).duplicate()
    # print("Body: ",event)
    event.description=text+" "+event.description+"\n";
    final_flavor_text(event)
    populate_event(event)
    emit_signal("resource_tick_updated", 0)
  else:
    emit_signal("resource_tick_updated", current_system.sysFuel)


func randomize_flavor_text(text)->String:
# take text like:
#   Your {shuttle/ship} sets down on a landing platform. {You stare apprehensively down./The floating station sways./You fall over.}"
# Where blocks inside of {} replaced with an even choice of / divided phrases
# Also replaces select text with other values
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

  text_out=text_out.replace("$star_color",current_system.star.colorName)
  text_out=text_out.replace("$system_name",current_system.name)
  text_out=text_out.replace("$chosen_planet_type","planet") #current_system.chosen_planet_type)

  return text_out


func get_flavor_pop()->String:
  return randomize_flavor_text("{lonely/sparse/bustling/crowded/a writhing mass of humanity}")


func get_flavor_hos()->String:
  return randomize_flavor_text("{friendly/cooperative/apprehensive/aggressive}")


func get_flavor_rep()->String:
  return randomize_flavor_text("{contempt/mistrust/appreciation/respect/awe}")


func final_flavor_text(event):
  if (current_system.status=="enemy_owned"):
    event.options=2

  if (current_system.planets.empty()):
    return

  var text=""
  if (current_system.status=="owned"):
    if (current_system.planet_types.has("Chthonian")):
      text="Your people are nowhere to be found.  Curious."
    else:
      text="The people here are your subjects, and they look at you with clear "+get_flavor_rep()+"."
  elif (current_system.status=="enemy_owned"):
    if (current_system.planet_types.has("Chthonian")):
      text="It would be trivial to establish an outpost here, but do you really want to?"
    else:
      text="The people here tell you that someone else with a ship has been here."
  else:
    if (current_system.planet_types.has("Chthonian")):
      text="It would be trivial to establish an outpost here, but do you really want to?"
    else:
      text="The people seem "+get_flavor_hos()+", and their settlement is best described as "+get_flavor_pop()+"."
  event.description+=text


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
  _event_popup._set_event_title(randomize_flavor_text(event.title))
  _event_popup._display_flavor_text(randomize_flavor_text(event.description))
  # print("Description: " + event.description)
  _event_popup._set_flavor_picture(event.graphicID)

  active_options=[]
  match str(event.options):
    "1":  # take-over system
      active_options=[
          {"text":"Use "+str(conq_supply)+" supplies to take the system","disabled":!check_min_option("supplies",conq_supply),"cost":{"supplies":conq_supply},"get":{"system":current_system.name, "fuel":current_system.sysFuel, "credits":current_system.sysCredits}},
          {"text":"Pay "+str(conq_credit)+" credits to buy the system","disabled":!check_min_option("credits",conq_credit),"cost":{"credits":conq_credit},"get":{"system":current_system.name, "fuel":current_system.sysFuel, "supplies":current_system.sysSupplies}},
          {"text":"Continue on","disabled":false}]
    "0":  # Empty system / no options
      active_options=[{"text":"Continue on","disabled":false}]
    "2":  # steal system from another player
      active_options=[
          {"text":"Use "+str(conq_supply)+" supplies to take the system","disabled":!check_min_option("supplies",conq_supply),"cost":{"supplies":conq_supply},"get":{"system":current_system.name}},
          {"text":"Pay "+str(conq_credit)+" credits to foster distrust of their current ruler","disabled":!check_min_option("credits",conq_credit),"cost":{"credits":conq_credit},"get":{"system":current_system.name}},
          {"text":"Continue on","disabled":false}]
    _:  #
      active_options=[{"text":"Nothing to do","disabled":false}]

  _event_popup._display_button_text(active_options)
  _event_popup.popup_centered()


func _on_choiceSelected(value):
  if (value>=0)&&(value<active_options.size()):
    if (active_options[value].has("cost")):
      pay_cost(active_options[value].cost)
    if (active_options[value].has("get")):
      get_stuff(active_options[value].get)
