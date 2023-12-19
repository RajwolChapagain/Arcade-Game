extends Area2D

@export var DAMAGE = 50

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body.has_method("on_hit"):
			if body == get_parent(): #Don't damage the ship that fired it
				continue
				
			body.on_hit(DAMAGE * delta)
