extends Node

export var title_msx_volume = 0.0 setget set_title_volume
export var game_msx_volume = 0.0 setget set_game_volume

var title_idx
var game_idx

# Called when the node enters the scene tree for the first time.
func _ready():
  title_idx = AudioServer.get_bus_index("TitleMusic")
  game_idx = AudioServer.get_bus_index("GameMusic")


func fade_in_title():
  if !$TitleMusic.playing:
    set_title_volume(-80.0)
    $TitleMusic.play()
    $Tween.interpolate_property(
      self, "title_msx_volume", -40.0, 0.0, 5.0, Tween.TRANS_LINEAR, Tween.EASE_IN
    )
    if !$Tween.is_active():
      $Tween.start()


func fade_out_title():
  if $TitleMusic.playing:
    $Tween.remove_all()
    var start = AudioServer.get_bus_volume_db(title_idx)
    $Tween.interpolate_property(
      self, "title_msx_volume", start, -40.0, 5.0, Tween.TRANS_LINEAR, Tween.EASE_IN
    )
    if ! $Tween.is_active():
      $Tween.start()


func set_title_volume(value):
  title_msx_volume = value
  AudioServer.set_bus_volume_db(title_idx, value)


func fade_in_game():
  if !$GameMusic.playing:
    set_game_volume(-80.0)
    $GameMusic.play()
    $Tween.interpolate_property(
      self, "game_msx_volume", -40.0, 0.0, 5.0, Tween.TRANS_LINEAR, Tween.EASE_IN
    )
    if !$Tween.is_active():
      $Tween.start()


func fade_out_game():
  if $GameMusic.playing:
    $Tween.remove_all()
    var start = AudioServer.get_bus_volume_db(game_idx)
    $Tween.interpolate_property(
      self, "game_msx_volume", start, -40.0, 5.0, Tween.TRANS_LINEAR, Tween.EASE_IN
    )
    if ! $Tween.is_active():
      $Tween.start()


func set_game_volume(value):
  game_msx_volume = value
  AudioServer.set_bus_volume_db(game_idx, value)


func _on_Tween_tween_completed(_object, key):
  if key == ":title_msx_volume":
    if AudioServer.get_bus_volume_db(title_idx) < -20.0:
      $TitleMusic.stop()
      set_title_volume(0.0)
  if key == ":game_msx_volume":
    if AudioServer.get_bus_volume_db(game_idx) < -20.0:
      $GameMusic.stop()
      set_game_volume(0.0)
