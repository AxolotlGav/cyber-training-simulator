extends Area

func _on_pickup_body_entered(body):
	if body.has_method("walk"):
		get_node("/root/main").add_time(10)
		queue_free()


func _on_Timer_timeout():
	queue_free()
