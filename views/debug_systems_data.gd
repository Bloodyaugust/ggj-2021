extends RichTextLabel

func _on_state_changed(state_key, substate):
  match state_key:
    "systems_data":
      var _new_text: String = ""

      for _key in substate.keys():
        _new_text += _key + ": " + str(substate[_key]) + "\r\n"

      text = _new_text

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
