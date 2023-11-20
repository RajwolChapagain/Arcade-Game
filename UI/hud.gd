extends Control

func set_p1_health(hp):
	$HealthBar.value = hp
	
func set_p2_health(hp):
	$HealthBar2.value = hp

func update_p1_super_bar(new_percentage):
	$SuperBar.value = new_percentage
	
func update_p2_super_bar(new_percentage):
	$SuperBar2.value = new_percentage
