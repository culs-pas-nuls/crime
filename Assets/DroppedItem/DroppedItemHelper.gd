extends Area

func get_item():
	var parent = get_parent()
	return parent.get_item()

func pick_up():
	var parent = get_parent()
	return parent.pick_up()
