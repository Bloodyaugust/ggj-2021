extends Node

export var star_system_actor: PackedScene

onready var _systems_container: Node2D = $"../Systems"

func _on_store_state_changed(state_key, substate):
  match state_key:
    "systems":
      GDUtil.queue_free_children(_systems_container)

      for _system in substate:
        var _new_system: Node2D = star_system_actor.instance()

        _systems_container.add_child(_new_system)
        _new_system.initialize(_system)

func _ready():
  Store.connect("state_changed", self, "_on_store_state_changed")

