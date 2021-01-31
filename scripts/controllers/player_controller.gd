extends Node

export var _fleet_actor: PackedScene

onready var _fleets_container: Node2D = $"../Fleets"

func _on_state_changed(state_key: String, substate):
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_STARTING:
          GDUtil.queue_free_children(_fleets_container)

          # TODO: Move this code to after we have registered, which should trigger a change to GameConstants.GAME_IN_PROGRESS
          var _new_fleet: Node2D = _fleet_actor.instance()
          _fleets_container.add_child(_new_fleet)

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
