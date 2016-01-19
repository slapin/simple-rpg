
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var housegrid = []
var room_dsc = [
	{
		"name": "Entry",
		"weight": 2,
		"type": "corridoor",
		"wall": false,
	},
	{
		"name": "Living room",
		"weight": 9,
		"type": "room",
		"wall": false,
		"distance": ["Entry", 4]
	},
	{
		"name": "Kitchen",
		"weight": 2,
		"type": "room",
		"wall": false,
		"distance": ["Living room", 6]
	},
	{
		"name": "Bedroom",
		"weight": 5,
		"type": "room",
		"wall": false,
	},
	{
		"name": "Bathroom",
		"weight": 1,
		"type": "room",
		"wall": false,
		"distance": ["Bedroom", 6]
	},
	{
		"name": "Toilet",
		"weight": 1,
		"type": "room",
		"wall": false,
		"distance": ["Bedroom", 6]
	},
	{
		"name": "Bedroom2",
		"weight": 3,
		"type": "room",
		"wall": false,
		"distance": ["Bedroom", 6]
	},
]

var floor_width = 100
var floor_height = 60

func grow_room_rect(id):
	var min_x = floor_width
	var max_x = -1
	var min_y = floor_height
	var max_y = -1
	for k in range(housegrid.size()):
		for l in range(housegrid[k].size()):
			if housegrid[k][l] == id:
				if min_x > l:
					min_x = l
				if max_x < l:
					max_x = l
				if min_y > k:
					min_y = k
				if max_y < k:
					max_y = k
	var start_x = clamp(min_x - 1, 0, floor_width - 1)
	var end_x = clamp(max_x + 1, 0, floor_width - 1)
	var start_y = clamp(min_y - 1, 0, floor_height - 1)
	var end_y = clamp(max_y + 1, 0, floor_height - 1)
	var can_grow_top = true
	var can_grow_bottom = true
	var can_grow_left = true
	var can_grow_right = true
	for k in range(start_x, end_x + 1):
		var h = housegrid[start_y][k]
		if h != id and h != 0:
			start_y = clamp(min_y, 0, floor_height)
			can_grow_top = false
			break
	for k in range(start_x, end_x + 1):
		var h = housegrid[end_y][k]
		if h != id and h != 0:
			end_y = clamp(max_y, 0, floor_height)
			can_grow_bottom = false
			break
	for k in range(start_y, end_y + 1):
		var h = housegrid[k][start_x]
		if h != id and h != 0:
			start_x = clamp(min_x, 0, floor_width)
			can_grow_left = false
			break
	for k in range(start_y, end_y + 1):
		var h = housegrid[k][end_x]
		if h != id and h != 0:
			end_x = clamp(max_x, 0, floor_width)
			can_grow_right = false
			break
	for k in range(start_y, end_y + 1):
		for l in range(start_x, end_x + 1):
			housegrid[k][l] = id
	for k in [can_grow_top, can_grow_bottom, can_grow_left, can_grow_right]:
		if k:
			return true
	return false

func check_wall_distance(p, wall_dist):
	var ret = true
	if !p.x in range(wall_dist, floor_width - wall_dist):
		ret = false
	if !p.y in range(wall_dist, floor_height - wall_dist):
		ret = false
	return ret
func check_min_distance(p1, p2, dist):
	if p1.distance_to(p2) >= dist:
		return true
	else:
		return false
func check_room_distance(e, place, dist):
	if e.has("pt"):
		return check_min_distance(e["pt"], place, dist)
	else:
		return true
func place_room(id, wall, room_dist, wall_dist):
	var room_place
	if wall:
		var place = randi() % 4
		if place == 0:
			room_place = Vector2(randi() % floor_width, 0)
		elif place == 1:
			room_place = Vector2(randi() % floor_width, floor_height - 1)
		elif place == 2:
			room_place = Vector2(0, randi() % floor_height)
		elif place == 3:
			room_place = Vector2(floor_width - 1, randi() % floor_height)
	else:
		room_place = Vector2(randi() % floor_width, randi() % floor_height)
	if !check_wall_distance(room_place, wall_dist):
		return false
	for k in range(room_dsc.size()):
		var e = room_dsc[k]
		if id - 1 == k:
			continue
		if !check_room_distance(e, room_place, room_dist):
			return false
	if housegrid[room_place.y][room_place.x] == 0:
		housegrid[room_place.y][room_place.x] = id
		room_dsc[id - 1]["pt"] = room_place
		return true
	

func _ready():
	# Initialization here
	var n_rooms = room_dsc.size()
	for k in range(floor_height):
		housegrid.append([])
		for l in range(floor_width):
			housegrid[k].append(0)
	var room_id = 1
	while true:
		if place_room(room_id, room_dsc[room_id - 1]["wall"], (floor_width + floor_height) / n_rooms, (floor_width + floor_height) / n_rooms / 2):
			room_id = room_id + 1
			if room_id > n_rooms:
				break
	for k in range(n_rooms):
		var r
		r = range(0, room_dsc[k]["weight"] + 1)
		room_dsc[k]["range"] = r
	var can_grow = []
	for k in range(n_rooms):
		can_grow.append(true)
	for l in range(int(floor_width * floor_height / n_rooms * 10)):
		for k in range(1, n_rooms + 1):
			if not can_grow[k - 1]:
				continue
			if randi() % n_rooms in room_dsc[k - 1]["range"]:
				can_grow[k - 1] = grow_room_rect(k)

func _draw():
	for k in range(housegrid.size()):
		for l in range(housegrid[k].size()):
			if housegrid[k][l] != 0:
				var rect = Rect2(l * 10, k * 10, 10, 10)
				draw_rect(rect, Color(housegrid[k][l]/float(room_dsc.size()), 0, 0))
	for k in room_dsc:
		var rect = Rect2(k["pt"].x * 10, k["pt"].y * 10, 10, 10)
		draw_rect(rect, Color(0, 0.5, 0))
