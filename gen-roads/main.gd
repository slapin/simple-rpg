
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

var citymap = []

func _ready():
	var road = load("res://road.scn")
	var block = load("res://block.scn")
	for g in range(0, 256):
		citymap.append([])
		for h in range(0, 256):
			citymap[g].append(1)
	var mainroads = []
	var iterations = 0
	while mainroads.size() < 64 && iterations < 1000:
		while iterations < 1000:
			var pos = Vector2(randi() % 256, randi() % 256)
			var found = false
			for m in mainroads:
				if pos.x == m.x or pos.y == m.y:
					found = true
					break
				if abs(pos.x - m.x) < 4 or abs(pos.y - m.y) < 4:
					found = true
					break
			if not found:
				mainroads.append(pos)
				break
			iterations = iterations + 1
		
	for g in mainroads:
		for h in range(0, citymap[g.y].size()):
			citymap[g.y][h] = 0
		for h in range(0, citymap.size()):
			citymap[h][g.x] = 0
	iterations = 0
	while iterations < 10:
		var randomy = randi() % citymap.size()
		var randomx = randi() % citymap[randomy].size()
		if randomx <= 0 or randomy <= 0:
			continue
		var horizontal = true
		var vertical = true
		var fval
		var hcheck = citymap[randomy][randomx - 1] + citymap[randomy][randomx + 1]
		var vcheck = citymap[randomy][randomx - 1] + citymap[randomy][randomx + 1]
		if citymap[randomy][randomx] == 1:
			fval = 0
			if hcheck < 2:
				horizontal = false
			if vcheck < 2:
				vertical = false
		else:
			continue
			fval = 1
			if hcheck >= 1:
				horizontal = false
			if vcheck >= 1:
				vertical = false
		if horizontal:
			for k in range(randomx, citymap[randomy].size()):
				if citymap[randomy][k] == fval:
					break;
				citymap[randomy][k] = fval
			for k in range(randomx - 1, 0, -1):
				if citymap[randomy][k] == fval:
					break;
				citymap[randomy][k] = fval
		if vertical:
			for k in range(randomy, citymap.size()):
				if citymap[k][randomx] == fval:
					break;
				citymap[k][randomx] = fval
			for k in range(randomy - 1, 0, -1):
				if citymap[k][randomx] == fval:
					break;
				citymap[k][randomx] = fval
		iterations = iterations + 1

	for g in range(0, citymap.size()):
		for h in range(0, citymap[g].size()):
			var p = null
			if citymap[g][h] == 0:
				p = road.instance()
			elif citymap[g][h] == 1:
				p = block.instance()
				p.height_scale = 1.0 + randf() * 12.0
			if p:
				add_child(p)
				p.set_translation(Vector3((h - 128) * 12, 0.0, (g - 128) * 12))
				p.show()

