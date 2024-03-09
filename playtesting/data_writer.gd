extends Node

func _ready():
	save_data("Actual 3rd line")
	save_data("4rth line!")
	
func save_data(data):
	var write_file
	if FileAccess.file_exists("user://testfile.data"):
		write_file = FileAccess.open("user://testfile.data", FileAccess.READ_WRITE)
	else:
		write_file = FileAccess.open("user://testfile.data", FileAccess.WRITE)
		
	write_file.seek_end()
	write_file.store_line(data)
