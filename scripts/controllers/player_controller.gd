extends Node

export var _fleet_actor: PackedScene

onready var _fleets_container: Node2D = $"../Fleets"
onready var _rts_camera2d: Camera2D = $"../RTS-Camera2D"
onready var _systems_container: Node2D = $"../Systems"
onready var _server_hook: Node = $"../ServerHook"
onready var _star_system_controller: Node = $"../StarSystemController"

func _on_state_changed(state_key: String, substate):
  match state_key:
    "gameOver":
      if substate[0]:
        # Store.set_state("game", GameConstants.GAME_OVER)
        # Store.set_state("client_view", ClientConstants.CLIENT_VIEW_MAIN_MENU)

    "game":
      match substate:
        GameConstants.GAME_STARTING:
          GDUtil.queue_free_children(_fleets_container)

          var _starting_system_actor: Node2D
          for _system in _systems_container.get_children():
            if _system.system.name == Store.state.starting_system.system.name:
              _starting_system_actor = _system
              break

          var _new_fleet: Node2D = _fleet_actor.instance()
          _fleets_container.add_child(_new_fleet)
          _new_fleet.global_position = _starting_system_actor.global_position
          Store.set_state("selection", _new_fleet)
          _rts_camera2d.global_position = _new_fleet.global_position

    "systems":
      if Store.state.game == GameConstants.GAME_OVER:
        _server_hook._request_galaxy()

    "starting_system":
      Clientstore.set_visit_status(substate.system.name, "owned")

func _on_client_store_resources_changed(state_key, substate):
  if Clientstore.values.owned_systems >= 5 && Store.state.game != GameConstants.GAME_OVER:
    _server_hook._win_the_game();
    Store.set_state("game", GameConstants.GAME_OVER)
    Store.set_state("client_view", ClientConstants.CLIENT_VIEW_MAIN_MENU)

func _ready():
  Clientstore.connect("resources_changed", self, "_on_client_store_resources_changed")
  Store.connect("state_changed", self, "_on_state_changed")

  Clientstore.set_state("supplies",rand_range(40,60))
  Clientstore.set_state("credits",rand_range(50,100))
  Clientstore.set_state("fuel", 999999)
