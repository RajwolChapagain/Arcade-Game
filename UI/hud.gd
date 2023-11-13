extends Control

func decrease_p1_health(damage):
	$HealthBar.value -= damage
	
func decrease_p2_health(damage):
	$HealthBar2.value -= damage

func update_p1_super_bar(new_percentage):
	$SuperBar.value = new_percentage
	
func update_p2_super_bar(new_percentage):
	$SuperBar2.value = new_percentage
