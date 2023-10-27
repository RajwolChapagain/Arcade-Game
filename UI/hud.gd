extends Control

func decrease_p1_health(damage):
	$HealthBar.value -= damage
	
func decrease_p2_health(damage):
	$HealthBar2.value -= damage

func update_p1_super_bar(new_percentage):
	$SuperBar.value = new_percentage
	
func update_p2_super_bar(new_percentage):
	$SuperBar2.value = new_percentage

func update_p1_offscreen_timer(time):
	$Label.text = str(ceil(time))
	
func update_p2_offscreen_timer(time):
	$Label2.text = str(ceil(time))

func make_p1_offscreen_timer_visible():
	$Label.visible = true

func make_p1_offscreen_timer_invisible():
	$Label.visible = false
	
func make_p2_offscreen_timer_visible():
	$Label2.visible = true

func make_p2_offscreen_timer_invisible():
	$Label2.visible = false
