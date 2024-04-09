extends TextureProgressBar

func _ready():
	value = 100

func _on_value_changed(new_value):
	if new_value >= 100 and not $Glow.is_playing():
		$Glow.play("glow")
	else:
		$Glow.stop()
