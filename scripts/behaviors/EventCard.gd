extends Control

signal choice

onready var titleNode = get_node("EventPlacard/PanelContainer/EventTitle")
onready var flavorText = get_node("EventPlacard/Panel/FlavorText")
onready var eventPic = get_node("EventPlacard/EventPicture")
onready var optionContainer = get_node("EventPlacard/OptionContainer")

# Update the flavor text to now have the event's thing.
func _display_flavor_text(text: String):
  flavorText.text = text

# Display all the options to the event.

func _display_button_text(text: Array):
  for nIndx in range(optionContainer.get_child_count()):
    if nIndx >= text.size():
      optionContainer.get_child(nIndx).rect_position.y = get_viewport().size.y
    else:
      rect_position.y = 67
      optionContainer.get_child(nIndx).text = text[nIndx]

# Set the flavor picture, as it's stored client-side we can just receive
# an id.
func _set_flavor_picture(pic_id: int):
  pass

# Set the event's title on the placard.
func _set_event_title(text: String):
  titleNode.text = text