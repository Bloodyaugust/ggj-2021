extends WindowDialog

signal choice

onready var titleNode = get_node("EventPlacard/PanelContainer/EventTitle")
onready var flavorText = get_node("EventPlacard/Panel/FlavorText")
onready var eventPic = get_node("EventPlacard/EventPicture")
onready var optionContainer = get_node("EventPlacard/OptionContainer")

var max_options=-1

func _ready():
  get_close_button().connect("button_down", self, "_on_optionSelected", [-1])
  for nIndx in range(optionContainer.get_child_count()):
    optionContainer.get_child(nIndx).connect("pressed", self, "_on_optionSelected", [nIndx])

# Update the flavor text to now have the event's thing.
func _display_flavor_text(text: String):
  flavorText.text = text

# Display all the options to the event.
func _display_button_text(text: Array):
  max_options = text.size()
  for nIndx in range(optionContainer.get_child_count()):
    if nIndx >= text.size():
      optionContainer.get_child(nIndx).visible=false
    else:
      optionContainer.get_child(nIndx).visible=true
      optionContainer.get_child(nIndx).text = text[nIndx].text
      optionContainer.get_child(nIndx).disabled = text[nIndx].disabled


# Set the flavor picture, as it's stored client-side we can just receive
# an id.
func _set_flavor_picture(pic: String):
  if (pic.empty()):
    eventPic.visible=false
  else:
    var name="res://sprites/events/"+pic+".png"
    if (ResourceLoader.exists(name)):
      eventPic.texture=load(name)
      eventPic.visible=true
    else:
      print("Missing resource: '",name,"'")
      eventPic.visible=false


# Set the event's title on the placard.
func _set_event_title(text: String):
  titleNode.text = text


func _on_optionSelected(value):
  if (value<=max_options):
    emit_signal("choice_selected",value)
  emit_signal("choice_selected",-1)



