extends Node

export var _fleet_actor: PackedScene

onready var _fleets_container: Node2D = $"../Fleets"
onready var _server_hook: Node = $"../ServerHook"

func _on_state_changed(state_key: String, substate):
  match state_key:
    "systems":
      if Store.state.game == GameConstants.GAME_OVER:
        _server_hook._request_galaxy()
    "uid":
      GDUtil.queue_free_children(_fleets_container)

      var _new_fleet: Node2D = _fleet_actor.instance()
      _fleets_container.add_child(_new_fleet)
      Store.set_state("selection", _new_fleet)

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")

  Clientstore.set_state("supplies",rand_range(40,60))
  Clientstore.set_state("credits",rand_range(50,100))
  Clientstore.set_state("fuel", 999999)
