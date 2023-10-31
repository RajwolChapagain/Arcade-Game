extends Area2D

@export var DAMAGE = 50

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body.has_method("on_hit"):
			body.on_hit(DAMAGE * delta)
		
		if body.has_method("freeze"):
			body.freeze()

func _on_body_exited(body):
	if body.has_method("unfreeze"):
		body.unfreeze()
