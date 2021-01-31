extends Node

func _attempt_exploration(sys_actor):
  $ExplorationEndpoint._attempt_exploration(sys_actor.system.name)

func _request_galaxy():
  $RegisterEndpoint._attempt_connection()

func _attempt_control(sys_actor):
  $SetOwnershipEndpoint._attempt_control(sys_actor.system.name)

func _attempt_connection():
  $RegisterEndpoint._attempt_connection()

func _attempt_rename(sys_actor, sys_name: String):
  $RenameEndpoint._attempt_rename(sys_actor.system.name, sys_name)

func _start_timer():
  $GameEndEndpoint._start_Timer()

func _win_the_game():
  $SetWonEndpoint._send_win()

func _clear_userID():
  Store.set_state("uid", "")
