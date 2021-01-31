extends Node

const CLIENT_VIEW_ABOUT = "CLIENT_VIEW_ABOUT"
const CLIENT_VIEW_ACHIEVEMENTS = "CLIENT_VIEW_ACHIEVEMENTS"
const CLIENT_VIEW_MAIN_MENU = "CLIENT_VIEW_MAIN_MENU"
const CLIENT_VIEW_NONE = "CLIENT_VIEW_NONE"

const COLOR_BLUE = Color("#5EB8E7")
const COLOR_GREEN = Color("#CBD928")
const COLOR_LIGHT_BLUE = Color("#C1E5F8")
const COLOR_RED = Color("#E71D24")

const ENDPOINT_LOCAL = "http://localhost:3000/"
const ENDPOINT_REMOTE = "http://192.81.135.83:3000/"
var ENDPOINT_ACTUAL = ENDPOINT_REMOTE if OS.has_feature("standalone") else ENDPOINT_LOCAL

const HEADER = ["Content-Type: application/json; charset=utf-8"]
