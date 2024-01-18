extends NinePatchRect
	
func tween_to_stats(stats : ShipStats):
	var tween_time = 0.5
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Bars/Toughness, "value", stats.toughness, tween_time)
	tween.tween_property($Bars/Damage, "value", stats.damage, tween_time)
	tween.tween_property($Bars/RechargeRate, "value", stats.recharge_rate, tween_time)
	tween.tween_property($Bars/TopSpeed, "value", stats.top_speed, tween_time)
	tween.tween_property($Bars/Acceleration, "value", stats.acceleration, tween_time)	
	
	
	
