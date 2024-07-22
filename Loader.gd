extends Node2D

export(bool) var isMobileOverride = false

func _ready():
	if isMobileDevice():
		Globals.isMobile = true
		get_tree().change_scene("res://MobileShell.tscn")
	else:
		get_tree().change_scene("res://TitleScreen.tscn")

func isMobileDevice() -> bool:
	if isMobileOverride:
		return true
		
	if OS.has_feature("mobile") or OS.has_feature("Android") or OS.has_feature("iOS"):
		return true
		
	if OS.has_feature("JavaScript"):
		var userAgent: String = JavaScript.eval("navigator.userAgent")
		userAgent = userAgent.to_lower()
		if "android" in userAgent or "ios" in userAgent:
			return true
	return false
		
