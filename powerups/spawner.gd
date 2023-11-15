extends Node2D

var super_boost = preload("res://powerups/super_boost.tscn")

signal powerup_spawned(power_up)

func _on_timer_timeout():
	var power_up = super_boost.instantiate()
	add_child(power_up)
	powerup_spawned.emit(power_up)
