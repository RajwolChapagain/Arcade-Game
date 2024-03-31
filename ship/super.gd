extends Area2D

@export var DAMAGE = 50
var owner_player = 1

signal super_did_damage(damage)

func _ready():
	$AnimationPlayer.play("grow")
	
func _physics_process(delta):
	for body in get_overlapping_bodies():		
		if body.has_method("on_hit"):
			if body == get_parent(): #Don't damage the ship that fired it
				continue

			if body.is_in_group("ship") or body.is_in_group("ufo"):
				super_did_damage.emit(DAMAGE * delta)
				
			body.on_hit(DAMAGE * delta)
		
