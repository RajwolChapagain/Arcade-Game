extends Area2D

const super_gain = 50
signal super_boost_collected(player, super_gain)

var collected = super_boost_collected

func _on_body_entered(body):
	if body.is_in_group("ship"):
		if body.get_collision_layer_value(1):
			super_boost_collected.emit(1, super_gain)
		else:
			super_boost_collected.emit(2, super_gain)
		queue_free()
	elif body.is_in_group("bullet"):
		if body.get_collision_layer_value(2):
			super_boost_collected.emit(1, super_gain)
		else:
			super_boost_collected.emit(2, super_gain)	
		queue_free()
