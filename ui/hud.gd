extends Control
	
var beep_seconds = [0, 1, 2, 3, 4, 5]

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

func announce_winner(player):
	var player_name
	
	if player == 1:
		player_name = "Player 1"
	elif player == 2:
		player_name = "Player 2"
		
	var announcement = player_name + " WINS!!!"
	show_announcement_text(announcement)

func hide_announcement_text():
	$WinnerAnnouncementText.set_visible(false)	

func show_announcement_text(text):
	$WinnerAnnouncementText.set_text(text)
	$WinnerAnnouncementText.set_visible(true)	

func set_round_time(text):
	if int(text) in beep_seconds and str(text) != %RoundTime.text:
		$Beep.play()
	%RoundTime.set_text(str(text))
		
func indicate_round_won(player, victory_count):
	if player == 1:
		if victory_count == 1:
			%P1Round1Indicator.toggle_to_win()
		elif victory_count == 2:
			%P1Round2Indicator.toggle_to_win()
	if player == 2:
		if victory_count == 1:
			%P2Round1Indicator.toggle_to_win()
		elif victory_count == 2:
			%P2Round2Indicator.toggle_to_win()
