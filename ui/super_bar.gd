extends TextureProgressBar

func _on_value_changed(value):
	if value >= 100 and not $Glow.is_playing():
		$Glow.play("glow")
	else:
		$Glow.stop()
