extends CollisionShape3D

func take_damage(damage : float):
	get_parent().take_damage(damage)
