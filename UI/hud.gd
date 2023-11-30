extends Control

func initialize_max_hp_bar(player, max_hp):
	var health_bar
	
	if player == 1:
		health_bar = $HealthBar
	elif player == 2:
		health_bar = $HealthBar2
		
	health_bar.max_value = max_hp
	health_bar.value = max_hp

func set_p1_health(hp):
	$HealthBar.value = hp
	
func set_p2_health(hp):
	$HealthBar2.value = hp

func update_p1_super_bar(new_percentage):
	$SuperBar.value = new_percentage
	
func update_p2_super_bar(new_percentage):
	$SuperBar2.value = new_percentage
