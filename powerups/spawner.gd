extends Node2D

var super_boost = preload("res://powerups/super_boost.tscn")

func _on_timer_timeout():
	var power_up = super_boost.instantiate()
	add_child(power_up)
