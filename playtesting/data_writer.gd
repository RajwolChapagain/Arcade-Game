extends Node
	
func save_data(data):
	var file_path = "user://playtest.data"
	var write_file
	if FileAccess.file_exists(file_path):
		write_file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	else:
		write_file = FileAccess.open(file_path, FileAccess.WRITE)
		
	write_file.seek_end()
	write_file.store_line(data)
