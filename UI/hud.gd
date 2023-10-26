extends Control

func decrease_p1_health(damage):
	$HealthBar.value -= damage
	
func decrease_p2_health(damage):
	$HealthBar2.value -= damage
