extends MarginContainer

onready var _play_button: Button = find_node("PlayButton")
onready var _credits_button: Button = find_node("CreditsButton")
onready var _quit_button: Button = find_node("QuitButton")
onready var _back_button: Button = find_node("BackToMenu")

onready var _buttons: VBoxContainer = find_node("Buttons")
onready var _credits: VBoxContainer = find_node("Credits")

var about: bool = false

func _on_play_button_pressed():
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_NONE)
  Store.set_state("game", GameConstants.GAME_STARTING)
  $"../../ServerHook"._start_Timer()

func _on_credits_pressed():
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_ABOUT)

func _on_back_pressed():
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_MAIN_MENU)

func _on_quit_pressed():
  get_tree().quit()

func _on_state_changed(state_key: String, substate):
  match state_key:
    "client_view":
      match substate:
        ClientConstants.CLIENT_VIEW_MAIN_MENU:
          if about:
            _credits.rect_position.y = get_viewport().size.y
            _buttons.rect_position.y = 0
          else:
            rect_position.y = 0
        ClientConstants.CLIENT_VIEW_ABOUT:
          _buttons.rect_position.y = get_viewport().size.y
          _credits.rect_position.y = 0
          about = true
        _:
          rect_position.y = get_viewport().size.y
    "game":
      match substate:
        GameConstants.GAME_OVER:
          _play_button.disabled = true
    "systems":
      _play_button.disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
  _play_button.connect("pressed", self, "_on_play_button_pressed")
  _credits_button.connect("pressed", self, "_on_credits_pressed")
  _quit_button.connect("pressed", self, "_on_quit_pressed")
  _back_button.connect("pressed", self, "_on_back_pressed")
  
  Store.connect("state_changed", self, "_on_state_changed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass
