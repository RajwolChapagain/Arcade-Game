extends Area2D

@export var DAMAGE = 50

signal super_did_damage(damage)

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body.has_method("on_hit"):
			if body == get_parent(): #Don't damage the ship that fired it
				continue
			#🛑 Make super utilize on_bullet_did_damage function in main
			if body.is_in_group("ship") or body.is_in_group("ufo"):
				super_did_damage.emit(DAMAGE * delta)
				
			body.on_hit(DAMAGE * delta)
