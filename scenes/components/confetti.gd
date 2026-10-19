class_name Confetti
extends CPUParticles2D
## A one-shot burst of coloured paper. CPU particles: safe on the Compatibility renderer.


static func burst(parent: Node, at: Vector2) -> void:
	var c := Confetti.new()
	c.position = at
	c.one_shot = true
	c.emitting = false
	c.amount = 60
	c.lifetime = 1.4
	c.explosiveness = 0.95
	c.direction = Vector2.UP
	c.spread = 80.0
	c.initial_velocity_min = 350.0
	c.initial_velocity_max = 650.0
	c.gravity = Vector2(0, 900)
	c.angular_velocity_min = -400.0
	c.angular_velocity_max = 400.0
	c.scale_amount_min = 8.0
	c.scale_amount_max = 14.0
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.25, 0.5, 0.75, 1.0])
	g.colors = PackedColorArray([Color("#FF5252"), Color("#FFD740"), Color("#69F0AE"), Color("#40C4FF"), Color("#E040FB")])
	c.color_initial_ramp = g
	parent.add_child(c)
	c.emitting = true
	c.finished.connect(c.queue_free)
