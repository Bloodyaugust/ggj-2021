extends Control

onready var titleNode = get_node("EventPlacard/PanelContainer/EventTitle")
onready var flavorText = get_node("EventPlacard/FlavorText")
onready var eventPic = get_node("EventPlacard/EventPicture")
onready var optionContainer = get_node("EventPlacard/OptionContainer")

# Update the flavor text to now have the event's thing.
func _display_flavor_text(text: String):
  flavorText.text = text

# Display all the options to the event.
func _display_button_text(text: String):
  pass

# Set the flavor picture, as it's stored client-side we can just receive
# an id.
func _set_flavor_picture(pic_id: int):
  pass

# Set the event's title on the placard.
func _set_event_title(text: String):
  titleNode.text = text
