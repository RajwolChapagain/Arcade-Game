extends Area2D

@export var DAMAGE = 50

func _on_body_entered(body):
	if body.has_method("on_hit"):
		body.on_hit(DAMAGE)
	
	if body.has_method("freeze"):
		body.freeze()


func _on_body_exited(body):
	if body.has_method("unfreeze"):
		body.unfreeze()
