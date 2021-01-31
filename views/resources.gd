extends MarginContainer

onready var _credits: Label = $"./PanelContainer/HBoxContainer/Credits"
onready var _fuel: Label = $"./PanelContainer/HBoxContainer/Fuel"
onready var _supplies: Label = $"./PanelContainer/HBoxContainer/Supplies"

func _on_client_store_resources_changed(state_key, value):
  _credits.text = "Credits: " + str(int(Clientstore.get_state("credits")))
  _fuel.text = "Fuel: " + str(int(Clientstore.get_state("fuel")))
  _supplies.text = "Supplies: " + str(int(Clientstore.get_state("supplies")))

func _ready():
  Clientstore.connect("resources_changed", self, "_on_client_store_resources_changed")
