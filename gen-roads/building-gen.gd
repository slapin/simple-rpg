
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

var n_floors = 5
var floor_grid = []
var building_width = 60
var building_depth = 75
var entry_door

const grid_item = 0.5
const floor_height = 3.0
const OUTER_WALL = 1000
const CORRIDOOR = 1001
const ENTRY = 1002
const ENTRY_DOOR = 1003

class Map:
	var fl_map
	var fl_width
	var fl_depth
	var room_data = {}
	func _init(w, h):
		fl_map = []
		for k in range(h):
			fl_map.append([])
			for l in range(w):
				fl_map[k].append(0)
		fl_width = w
		fl_depth = h
	func get_map():
		return fl_map
	func size():
		return Vector2(fl_width, fl_depth)
	func setup_outer_walls():
		for k in [0, fl_depth - 1]:
			for l in range(1, fl_width - 1):
				fl_map[k][l] = OUTER_WALL
		for k in range(0, fl_depth):
			for l in [0, fl_width - 1]:
				fl_map[k][l] = OUTER_WALL
	func grow_room_rect(id):
		var min_x = fl_width
		var max_x = -1
		var min_y = fl_depth
		var max_y = -1
		for k in range(fl_map.size()):
			for l in range(fl_map[k].size()):
				if fl_map[k][l] == id:
					if min_x > l:
						min_x = l
					if max_x < l:
						max_x = l
					if min_y > k:
						min_y = k
					if max_y < k:
						max_y = k
		var start_x = clamp(min_x - 1, 0, fl_width - 1)
		var end_x = clamp(max_x + 1, 0, fl_width - 1)
		var start_y = clamp(min_y - 1, 0, fl_depth - 1)
		var end_y = clamp(max_y + 1, 0, fl_depth - 1)
		var can_grow_top = true
		var can_grow_bottom = true
		var can_grow_left = true
		var can_grow_right = true
		for k in range(start_x, end_x + 1):
			var h = fl_map[start_y][k]
			if h != id and h != 0:
				start_y = clamp(min_y, 0, fl_depth)
				can_grow_top = false
				break
		for k in range(start_x, end_x + 1):
			var h = fl_map[end_y][k]
			if h != id and h != 0:
				end_y = clamp(max_y, 0, fl_depth)
				can_grow_bottom = false
				break
		for k in range(start_y, end_y + 1):
			var h = fl_map[k][start_x]
			if h != id and h != 0:
				start_x = clamp(min_x, 0, fl_width)
				can_grow_left = false
				break
		for k in range(start_y, end_y + 1):
			var h = fl_map[k][end_x]
			if h != id and h != 0:
				end_x = clamp(max_x, 0, fl_width)
				can_grow_right = false
				break
		for k in range(start_y, end_y + 1):
			for l in range(start_x, end_x + 1):
				fl_map[k][l] = id
		for k in [can_grow_top, can_grow_bottom, can_grow_left, can_grow_right]:
			if k:
				return true
		return false
	func copy_id(id, obj):
		var v = obj.get_map()
		for k in range(v.size()):
			for l in range(v[k].size()):
				if k < fl_depth and l < fl_width and v[k][l] == id:
					if fl_map[k][l] == 0:
						fl_map[k][l] = id
	func grow_entry():
		for k in range(10 + randi() % 10):
			grow_room_rect(ENTRY)
	func spawn_appartment(id):
		var sz = size()
		var px = Vector2()
		while true:
			px.x = 10 + (randi() % (int((fl_width - 20) / 10))) * 10
			px.y = 10 + (randi() % (int((fl_depth - 20) / 10))) * 10
			if not fl_map[px.y][px.x] == 0:
				continue
			else:
				fl_map[px.y][px.x] = id
				break
		add_room(id, int(px.x), int(px.y))
	func find_edge_x(id, k, t, l1, l2, lstep):
		var state = 0
		var edges = []
		var prev = [l1, k, fl_map[k][l1]]
		for l in range(l1, l2, lstep):
			if state == 0:
				if fl_map[k][l] == id:
					prev = [l, k, fl_map[k][l]]
					state = 1
			elif state == 1:
				if fl_map[k][l] != id:
					state = 0
					edges.append([t, prev, [l, k, fl_map[k][l]]])
				else:
					prev = [l, k, fl_map[k][l]]
		return edges
	func find_edge_y(id, l, t, k1, k2, kstep):
		var state = 0
		var edges = []
		var prev = [l, k1, fl_map[k1][l]]
		for k in range(k1, k2, kstep):
			if state == 0:
				if fl_map[k][l] == id:
					prev = [l, k, fl_map[k][l]]
					state = 1
			elif state == 1:
				if fl_map[k][l] != id:
					state = t
					edges.append([t, prev, [l, k, fl_map[k][l]]])
				else:
					prev = [l, k, fl_map[k][l]]
		return edges
		
	func find_edges(id):
		var edges = []
		for k in range(1, fl_depth - 1):
			edges += find_edge_x(id, k, 0, 0, fl_width, 1)
			edges += find_edge_x(id, k, 1, fl_width - 1, -1, -1)
		for l in range(1, fl_width - 1):
			edges += find_edge_y(id, l, 2, 0, fl_depth, 1)
			edges += find_edge_y(id, l, 3, fl_depth - 1, -1, -1)
		return edges
	func find_wall_edges(id):
		var edges = find_edges(id)
		var r_edges = []
		for k in edges:
			if not edge_is_door(k):
				r_edges.append(k)
		return r_edges
	func find_door_edges(id):
		var edges = find_edges(id)
		var r_edges = []
		for k in edges:
			if edge_is_door(k):
				r_edges.append(k)
		return r_edges
	func add_room(id, x, y):
		room_data[id] = [x, y]
	func generate_corridoor():
		var C_DEPTH = 0
		var C_WIDTH = 1
		var c_style
		var c_width
		var c_length
		var cx = int(fl_width / 2 + 0.5)
		var cy = int(fl_depth / 2 + 0.5)
		var dx
		var dy
		var rx
		var ry
		var c_width_min = 2.0 / grid_item
		if fl_width > fl_depth:
			c_style = C_WIDTH
			c_width = c_width_min + randi() % int(fl_width / 4)
			c_length = fl_width
		elif fl_depth >= fl_width:
			c_style = C_DEPTH
			c_width = c_width_min + randi() % int(fl_depth / 4)
			c_length = fl_depth
		if c_style == C_WIDTH:
			rx = c_length
			ry = c_width
		elif c_style == C_DEPTH:
			rx = c_width
			ry = c_length
		dx = cx - int(rx / 2)
		dy = cy - int(ry / 2)
		for k in range(rx):
			var tx = dx + k
			for l in range(ry):
				var ty = dy + l
				if fl_map[ty][tx] == 0:
					fl_map[ty][tx] = CORRIDOOR
	func connect_entry(efrom, eto):
		pass
#		var efrom_edges = find_edges(efrom)
#		for l in efrom_edges:
#			if l[2][2] == eto:
#				print(l[1][2], " => ", l[2][2])
#				print(l[1][0], ", ", l[1][1], " --> ", l[2][0], ", ", l[2][1])
#		var eto_edges = find_edges(eto)
#		for l in eto_edges:
#			if l[2][2] == efrom:
#				print(l[1][2], " <= ", l[2][2])
#				print(l[1][0], ", ", l[1][1], " <-- ", l[2][0], ", ", l[2][1])
	func replace_tile(what, with):
#		print("FILL: ", what, ", ", with)
		for k in fl_map:
			for l in range(k.size()):
				if k[l] == what:
					k[l] = with
	func group_edges(edges):
		var edges_x = {}
		var edges_y = {}
		var group = []
		for k in edges:
			if not edges_x.has(k[1][0]):
				edges_x[k[1][0]] = {}
			edges_x[k[1][0]][k[1][1]] = k
			if not edges_y.has(k[1][1]):
				edges_y[k[1][1]] = {}
			edges_y[k[1][1]][k[1][0]] = k
		for r in edges_x.keys():
			var state = 0
			var prev
			var et = edges_x[r].keys()
			et.sort()
#			print("X:", et)
			prev = et[0]
			state = 0
			for t in et:
				if state == 0:
					prev = t
					group = []
					state = 1
				elif state == 1:
					if t - 1 == prev:
#						print("adding: ", t)
						group.append(edges_x[r][prev])
						if group.size() > 1:
							group.append(edges_x[r][t])
							return group
						prev = t
					else:
#						print("bad: ", t, " prev: ", prev, " group: ", group)
						prev = t
						group = []
		for r in edges_y.keys():
			var state = 0
			var prev
			var et = edges_y[r].keys()
			et.sort()
#			print("Y:", et)
			prev = et[0]
			state = 0
			for t in et:
				if state == 0:
					prev = t
					group = []
					state = 1
				elif state == 1:
					if t - 1 == prev:
#						print("adding: ", t)
						group.append(edges_y[r][prev])
						if group.size() > 1:
							group.append(edges_y[r][t])
							return group
						prev = t
					else:
#						print("bad: ", t, " prev: ", prev, " group: ", group)
						prev = t
						group = []
		return group
	var corridoor_edges = {}
	var outer_wall_edges = {}
	var door_map_x = {}
	var door_map_y = {}
	func is_door(e1, e2):
		var x = int(e1[0])
		var y = int(e1[1])
		var x1 = int(e2[0])
		var y1 = int(e2[1])
		if door_map_x.has(x):
			if door_map_x[x].has(y):
				if door_map_x[x][y].has(x1):
					if door_map_x[x][y][x1].has(y1):
#						print("is door: ", x, ", ", y, ": ", x1, ", ", y1)
						return true
#		print("not a door: ", x, ", ", y, ": ", x1, ", ", y1)
		return false
	func edge_is_door(edge):
		if not is_door(edge[1], edge[2]):
			if not is_door(edge[2], edge[1]):
				return false
		return true
	func add_4_map(m, p1, p2, p3, p4):
		if not m.has(p1):
			m[p1] = {}
		if not m[p1].has(p2):
			m[p1][p2] = {}
		if not m[p1][p2].has(p3):
			m[p1][p2][p3] = {}
		if not m[p1][p2][p3].has(p4):
			m[p1][p2][p3][p4] = true
		
	func add_door_map(e1, e2):
		var x = int(e1[0])
		var y = int(e1[1])
		var x1 = int(e2[0])
		var y1 = int(e2[1])
		add_4_map(door_map_x, x, y, x1, y1)
		add_4_map(door_map_y, y, x, y1, x1)
	func optimize_flats():
		for k in room_data.keys():
			var connected_to_corridoor = false
			var connected_to_outer_wall = false
			var room_edges = find_edges(k)
			var neighbor_count = {}
			for r in room_edges:
				if neighbor_count.has(r[2][2]):
					neighbor_count[r[2][2]] += 1
				else:
					neighbor_count[r[2][2]] = 1
				if r[2][2] == CORRIDOOR:
					connected_to_corridoor = true
					if corridoor_edges.has(k):
						corridoor_edges[k].append(r)
					else:
						corridoor_edges[k] = [r]
				elif r[2][2] == OUTER_WALL:
					connected_to_outer_wall = true
					if outer_wall_edges.has(k):
						outer_wall_edges[k].append(r)
					else:
						outer_wall_edges[k] = [r]
			if connected_to_corridoor and connected_to_outer_wall \
				and corridoor_edges[k].size() > 2 and outer_wall_edges[k].size() > 2:
#				print("good room ", k)
#				print(corridoor_edges[k])
#				print(outer_wall_edges[k])
#				print("group corridoor: ", group_edges(corridoor_edges[k]).size())
#				print("group wall: ", group_edges(outer_wall_edges[k]).size())
				for ev in corridoor_edges[k]:
					add_door_map(ev[1], ev[2])
				
				# add doors here
			else:
				var c = 0
				var d = 0
				for m in neighbor_count.keys():
					if c < neighbor_count[m]:
						c = neighbor_count[m]
						d = m
				if d != 0:
					replace_tile(k, d)
		for k in door_map_x.keys():
			for l in door_map_x[k].keys():
				for m in door_map_x[k][l].keys():
					for n in door_map_x[k][l][m].keys():
						print("door: ", k, ", ", l, " => ", m, ", ", n)
			

class BuildData extends MeshInstance:
	var shape_tris = []
	var material
	var col = true
	func add_triangle(st, v1, v2, v3, u1, u2, u3):
		var uvs = [u1, u2, u3]
		var pts = [v1, v2, v3]
		for g in range(pts.size()):
			st.add_uv(uvs[g])
			st.add_vertex(pts[g])
		if col:
			shape_tris = shape_tris + pts
	func add_quad(st, v1, v2, v3, v4, u1, u2, u3, u4):
		add_triangle(st, v1, v2, v3, u1, u2, u3)
		add_triangle(st, v3, v4, v1, u3, u4, u1)
	func quad_uvs(off, size):
		var u0 = Vector2(0.0, 0.0) + off
		var u1 = Vector2(size.x, 0.0) + off
		var u2 = Vector2(size.x, size.y) + off
		var u3 = Vector2(0.0, size.y) + off
		return [u0, u1, u2, u3]
	func quad1(off, size, id):
		var d
		var w
		var r
		if id == 0:
			d  = -size.z / 2.0
			w = -size.y / 2.0
			r = size.x / 2.0
		elif id == 1:
			d = size.z / 2.0
			w = -size.y / 2.0
			r = -size.x / 2.0
		var v1 = Vector3(-r, w, d) + off
		var v2 = Vector3(r, w, d) + off
		var v3 = Vector3(r, -w, d) + off
		var v4 = Vector3(-r, -w, d) + off
		return [v1, v2, v3, v4]
	func quad2(off, size, id):
		var d
		var w
		var r
		if id == 0:
			d  = -size.z / 2.0
			w = -size.y / 2.0
			r = -size.x / 2.0
		elif id == 1:
			d = size.z / 2.0
			w = size.y / 2.0
			r = -size.x / 2.0
		var v1 = Vector3(-r, w, d) + off
		var v2 = Vector3(r, w, d) + off
		var v3 = Vector3(r, w, -d) + off
		var v4 = Vector3(-r, w, -d) + off
		return [v1, v2, v3, v4]
	func quad3(off, size, id):
		var d
		var w
		var r
		if id == 0:
			d  = -size.z / 2.0
			w = size.y / 2.0
			r = size.x / 2.0
		elif id == 1:
			d = size.z / 2.0
			w = size.y / 2.0
			r = -size.x / 2.0
		var v1 = Vector3(d, w, -r) + off
		var v2 = Vector3(d, w, r) + off
		var v3 = Vector3(d, -w, r) + off
		var v4 = Vector3(d, -w, -r) + off
		return [v1, v2, v3, v4]

	func prepare_data(st):
		pass
	func _ready():
		var surfTool = SurfaceTool.new()
		var mesh = Mesh.new()
		material = FixedMaterial.new()
		var shape
		if col:
			shape = ConcavePolygonShape.new()
		prepare_data(surfTool)
		surfTool.generate_normals()
		surfTool.index()
		surfTool.commit(mesh)
		set_mesh(mesh)
		if col:
			shape.set_faces(Vector3Array(shape_tris))
			var body = StaticBody.new()
			body.add_shape(shape)
			add_child(body)

class Doors extends Spatial:
	var fl_edges
	var fl_width
	var fl_depth
	var fl_data
	func place_door(l, k, q):
#		var u = quad_uvs(Vector2(), Vector2(grid_item, grid_item))
#		var pv = Vector3((l - int(fl_width / 2.0)) * grid_item, 0.2 / 2.0 , (k - int(fl_depth / 2.0))* grid_item)
		var door_pv = Vector3((l - int(fl_width / 2.0)) * grid_item, 0.0 , (k - int(fl_depth / 2.0))* grid_item)
#		var vs = Vector3(0.8, 0.2, grid_item)
		var door = fl_data.instance()
		add_child(door)
		if q == 0:
			door_pv = door_pv + Vector3(-grid_item / 2.0, 0.0, 0.0)
			door.set_translation(door_pv)
			door.set_rotation(Vector3(0.0, PI/2.0, 0.0))
		if q == 1:
			door_pv = door_pv + Vector3(grid_item / 2.0, 0.0, 0.0)
			door.set_translation(door_pv)
			door.set_rotation(Vector3(0.0, -PI/2.0, 0.0))
		elif q == 2:
			door_pv = door_pv + Vector3(0.0, 0.0, grid_item / 2.0)
			door.set_translation(door_pv)
			door.set_rotation(Vector3(0.0, PI, 0.0))
		elif q == 3:
			door_pv = door_pv + Vector3(0.0, 0.0, -grid_item / 2.0)
			door.set_translation(door_pv)
			door.set_rotation(Vector3(0.0, -PI, 0.0))
#		var v
#		if q == 0 or q == 1:
#			v = quad3(pv, vs, q)
#		elif q == 2 or q == 3:
#			v = quad1(pv, vs, q - 2)
#		add_quad(st, v[0], v[1], v[2], v[3], u[0], u[1], u[2], u[3])
#		add_quad(st, v[3], v[2], v[1], v[0], u[0], u[1], u[2], u[3])
	func build_doors(edges):
		var e_edges = {}
		for l in edges:
			if e_edges.has(l[2][2]):
				e_edges[l[2][2]].append(l)
			else:
				e_edges[l[2][2]] = [l]
		for h in e_edges.keys():
			var k = e_edges[h][1]
			if k[2][0] > k[1][0]:
				place_door(k[2][0], k[2][1], 0)
			elif k[2][0] < k[1][0]:
				place_door(k[2][0], k[2][1], 1)
			elif k[2][1] > k[1][1]:
				place_door(k[2][0], k[2][1], 2)
			elif k[2][1] < k[1][1]:
				place_door(k[2][0], k[2][1], 3)
	func _ready():
#		material.set_parameter(material.PARAM_DIFFUSE, color)
#		st.set_material(material)
#		st.begin(VS.PRIMITIVE_TRIANGLES)
		build_doors(fl_edges)
	func _init(edges, w, d):
		._init()
		fl_edges = edges
		fl_width = w
		fl_depth = d
		fl_data = load("res://building/c_door.scn")

class Roomspace extends BuildData:
	var fl_width
	var fl_depth
	var fl_map
	var fl_edges
	var fl_exclusions
	var color
	func place_wall(st, l, k, q):
		var u = quad_uvs(Vector2(), Vector2(grid_item, grid_item))
		var pv = Vector3((l - int(fl_width / 2.0)) * grid_item, floor_height / 2.0 , (k - int(fl_depth / 2.0))* grid_item)
		var vs = Vector3(grid_item, floor_height, grid_item)
		var v
		if q == 0 or q == 1:
			v = quad3(pv, vs, q)
		elif q == 2 or q == 3:
			v = quad1(pv, vs, q - 2)
		add_quad(st, v[0], v[1], v[2], v[3], u[0], u[1], u[2], u[3])
		add_quad(st, v[3], v[2], v[1], v[0], u[0], u[1], u[2], u[3])
	func check_place_wall(st, l, k, q):
		if not fl_map[k][l] in fl_exclusions:
			place_wall(st, l, k, q)
	func build_walls(st, edges):
		for k in edges:
			if k[2][0] > k[1][0]:
				check_place_wall(st, k[2][0], k[2][1], 0)
			elif k[2][0] < k[1][0]:
				check_place_wall(st, k[2][0], k[2][1], 1)
			elif k[2][1] > k[1][1]:
				check_place_wall(st, k[2][0], k[2][1], 2)
			elif k[2][1] < k[1][1]:
				check_place_wall(st, k[2][0], k[2][1], 3)
	func prepare_data(st):
		material.set_parameter(material.PARAM_DIFFUSE, color)
		st.set_material(material)
		st.begin(VS.PRIMITIVE_TRIANGLES)
		build_walls(st, fl_edges)
	func _init(map, edges, exclusions, c):
		._init()
		color = c
		fl_width = map[0].size()
		fl_depth = map.size()
		fl_map = map
		fl_edges = edges
		fl_exclusions = exclusions

class OuterWalls extends MeshInstance:
	var shape_tris
	var fl_width
	var fl_depth
	var fl_map
	var outer_door_width
	var door_tail
	const WALL_DEPTH = 1
	const WALL_WIDTH = 2
	func add_triangle(st, v1, v2, v3, u1, u2, u3):
		var uvs = [u1, u2, u3]
		var pts = [v1, v2, v3]
		for g in range(pts.size()):
			st.add_uv(uvs[g])
			st.add_vertex(pts[g])
		shape_tris = shape_tris + pts
		
	func quad_uvs(off, size):
		var u0 = Vector2(0.0, 0.0) + off
		var u1 = Vector2(size.x, 0.0) + off
		var u2 = Vector2(size.x, size.y) + off
		var u3 = Vector2(0.0, size.y) + off
		return [u0, u1, u2, u3]
	func add_quad(st, v1, v2, v3, v4, u1, u2, u3, u4):
		add_triangle(st, v1, v2, v3, u1, u2, u3)
		add_triangle(st, v3, v4, v1, u3, u4, u1)
	func add_wall_block(st, pos, width, height, depth, walltype):
		var uvs = quad_uvs(Vector2(0.0, 0.0), Vector2(width, height))
		uvs += quad_uvs(Vector2(width + depth, 0.0), Vector2(width, height))
		var v1 = Vector3(-width / 2.0, height, depth / 2.0) + pos
		var u1 = uvs[0]
		var v2 = Vector3(width / 2.0, height, depth / 2.0) + pos
		var u2 = uvs[1]
		var v3 = Vector3(width / 2.0, 0.0, depth / 2.0) + pos
		var u3 = uvs[2]
		var v4 = Vector3(-width / 2.0, 0.0, depth / 2.0) + pos
		var u4 = uvs[3]
		var v5 = Vector3(-width / 2.0, 0.0, -depth / 2.0) + pos
		var u5 = uvs[4]
		var v6 = Vector3(width / 2.0, 0.0, -depth / 2.0) + pos
		var u6 = uvs[5]
		var v7 = Vector3(width / 2.0, height, -depth / 2.0) + pos
		var u7 = uvs[6]
		var v8 = Vector3(-width / 2.0, height, -depth / 2.0) + pos
		var u8 = uvs[7]
		
		if walltype == -1:
			add_quad(st, v1, v8, v7, v2, u1, u8, u7, u2)
			add_quad(st, v4, v3, v6, v5, u4, u3, u6, u5)
		elif walltype == 0:
			add_quad(st, v1, v2, v3, v4, u1, u2, u3, u4)
			add_quad(st, v5, v6, v7, v8, u5, u6, u7, u8)
			add_quad(st, v2, v7, v6, v3, u2, u7, u6, u3)
			add_quad(st, v8, v1, v4, v5, u8, u1, u4, u5)
		elif walltype == 1:
			add_quad(st, v1, v2, v3, v4, u1, u2, u3, u4)
			add_quad(st, v5, v6, v7, v8, u5, u6, u7, u8)
		elif walltype == 2:
			add_quad(st, v2, v7, v6, v3, u2, u7, u6, u3)
			add_quad(st, v8, v1, v4, v5, u8, u1, u4, u5)
	func add_floor_block(st, pos, width, height, depth):
		add_wall_block(st, pos, width, height, depth, -1)
	func find_wall_length(x, y, t):
		var sz = []
		if t == WALL_DEPTH:
			for g in range(y, fl_depth):
				if fl_map[g][x] == OUTER_WALL:
					continue
				else:
					sz.append(g)
		elif t == WALL_WIDTH:
			for g in range(x, fl_width):
				if fl_map[y][g] == OUTER_WALL:
					continue
				else:
					sz.append(g)
		return sz

	func calc_trans(x, y, pv):
		if pv.x > 0.0 and pv.z > 0.0:
			var trans = Vector3()
			x = x - int(fl_width / 2)
			y = y - int(fl_depth / 2)
			if pv.x > pv.z:
				trans.x = x * grid_item + pv.x / 2.0
				trans.z = y * grid_item
			elif pv.z > pv.z:
				trans.z = y * grid_item + pv.z / 2.0
				trans.x = x * grid_item
			else:
				trans.z = y * grid_item + pv.z / 2.0
				trans.x = x * grid_item + pv.x / 2.0
			return trans
		else:
			return Vector3()
	func wall_size(x, y, t, ml):
		var sz = 0
		if t == WALL_DEPTH:
			for g in range(y, ml):
				if fl_map[g][x] == OUTER_WALL:
					sz = sz + 1
				else:
					break
		elif t == WALL_WIDTH:
			for g in range(x, ml):
				if fl_map[y][g] == OUTER_WALL:
					sz = sz + 1
				else:
					break
		return sz
	func wall_segments(x, y, t, ml):
		var segments = []
		var dm = Vector2(x, y)
		var next_cut = false
		var cut_start = false
		var cut_end = false
		var v_offset
		var max_check
		if t == WALL_DEPTH:
			v_offset = Vector2(0, 1)
			if ml > fl_depth:
				ml = fl_depth
			max_check = fl_depth
		elif t == WALL_WIDTH:
			v_offset = Vector2(1, 0)
			if ml > fl_width:
				ml = fl_width
			max_check = fl_width
		while dm.x < fl_width and dm.y < fl_depth:
				var l = wall_size(dm.x, dm.y, t, ml)
				if l > 0:
					var cut_start = next_cut
					next_cut = false
					var vcheck = dm + l * v_offset
					if vcheck.x < fl_width - 1 and vcheck.y < fl_depth - 1:
						cut_end = true
						next_cut = true
					else:
						cut_end = false
					var size = l * v_offset
					if size.x < 1:
						size.x = 1
					if size.y < 1:
						size.y = 1
					segments.append([dm, size, cut_start, cut_end])
					dm = dm + l * v_offset
				else:
					dm = dm + v_offset
		return segments
	func all_wall_segments(ml):
		var s = []
		s += wall_segments(0, 0, WALL_WIDTH, ml)
		s += wall_segments(0, 1, WALL_DEPTH, ml)
		s += wall_segments(fl_width - 1, 1, WALL_DEPTH, ml)
		s += wall_segments(0, fl_depth - 1, WALL_WIDTH, ml)
		return s
	func convert_segments(tail, ml):
		var result = []
		var s = all_wall_segments(ml)
		for k in s:
			var posx = (k[0].x - int(fl_width / 2) + float(k[1].x) / 2.0) * grid_item - grid_item / 2.0
			var posz = (k[0].y - int(fl_depth / 2) + float(k[1].y) / 2.0) * grid_item - grid_item / 2.0
			var sizex = float(k[1].x) * grid_item
			var sizez = float(k[1].y) * grid_item
			var sizey = floor_height
			if k[2] and k[3]:
				if sizex > sizez:
					sizex = sizex - tail * 2.0
				elif sizez > sizex:
					sizez = sizez - tail * 2.0
			elif k[2]:
				if sizex > sizez:
					sizex = sizex - tail
					posx = posx + tail / 2.0
				elif sizez > sizex:
					sizez = sizez - tail
					posz = posz + tail / 2.0
			elif k[3]:
				if sizex > sizez:
					sizex = sizex - tail
					posx = posx - tail / 2.0
				elif sizez > sizex:
					sizez = sizez - tail
					posz = posz - tail / 2.0
			var trans = Vector3(posx, 0.0, posz)
			var pv = Vector3(sizex, sizey, sizez)
			result.append([pv, trans])
		return result

	func _ready():
		var surfTool = SurfaceTool.new()
		var mesh = Mesh.new()
		var material = FixedMaterial.new()
		var shape = ConcavePolygonShape.new()
		var image_texture = ImageTexture.new()
		image_texture.load("res://building/Concrete.png")
		door_tail = (outer_door_width - grid_item) / 2.0
		shape_tris = []
		material.set_parameter(material.PARAM_DIFFUSE, Color(0.6, 0.6, 0.6))
		material.set_texture(material.PARAM_DIFFUSE, image_texture)
		surfTool.set_material(material)
		surfTool.begin(VS.PRIMITIVE_TRIANGLES)
		var h = convert_segments(0.4, 100)
		for k in h:
			add_wall_block(surfTool, k[1], k[0].x, k[0].y, k[0].z, 0)
		for k in range(1, fl_depth - 1):
			for l in range(1, fl_width - 1):
					var trans = Vector3((l - int(fl_width / 2)) * grid_item, -0.1, (k - int(fl_depth / 2)) * grid_item)
					if not fl_map[k][l] in [0, ENTRY]:
						add_floor_block(surfTool, trans, 0.5, 0.2, 0.5)
		surfTool.generate_normals()
		surfTool.index()
		surfTool.commit(mesh)
		set_mesh(mesh)
		shape.set_faces(Vector3Array(shape_tris))
		var body = StaticBody.new()
		body.add_shape(shape)
		add_child(body)
	func _init(map, dw):
		._init()
		fl_width = map[0].size()
		fl_depth = map.size()
		fl_map = map
		outer_door_width = dw

func setup_entry_door():
	var wall = randi() % 4
	if wall == 0:
		entry_door = Vector2(randi() % building_width, 0)
		floor_grid[0].get_map()[entry_door.y + 1][entry_door.x] = ENTRY
	elif wall == 1:
		entry_door = Vector2(randi() % building_width, building_depth - 1)
		floor_grid[0].get_map()[entry_door.y - 1][entry_door.x] = ENTRY
	elif wall == 2:
		entry_door = Vector2(0, randi() % building_depth)
		floor_grid[0].get_map()[entry_door.y][entry_door.x + 1] = ENTRY
	elif wall == 3:
		entry_door = Vector2(building_width - 1, randi() % building_depth)
		floor_grid[0].get_map()[entry_door.y][entry_door.x - 1] = ENTRY
	floor_grid[0].get_map()[entry_door.y][entry_door.x] = ENTRY_DOOR
	floor_grid[n_floors - 1].get_map()[entry_door.y][entry_door.x] = ENTRY_DOOR
	
func _ready():
	# Initialization here
	for h in range(n_floors):
		var map = Map.new(building_width, building_depth)
		floor_grid.append(map)
		map.setup_outer_walls()
	for h in range(n_floors):
		if h == 0:
			setup_entry_door()
		floor_grid[h].generate_corridoor()
		if h == 0 or h == n_floors - 1:
			floor_grid[h].grow_entry()
		if h > 0:
			floor_grid[h].copy_id(ENTRY, floor_grid[0])
		floor_grid[h].connect_entry(ENTRY, CORRIDOOR)
		var max_appartments = int((building_width + building_depth) / 16)
		var min_appartments = 4
		var n_appartments = min_appartments + randi() % (max_appartments - min_appartments)
#		n_appartments = 10
		var can_grow = {}
		for k in range(2000, 2000 + n_appartments):
			can_grow[k] = true
			floor_grid[h].spawn_appartment(k)
		can_grow[ENTRY] = true
		var cnt = 8000
		while true:
			var grown = false
			for k in can_grow.keys():
				if not floor_grid[h].grow_room_rect(k):
					can_grow.erase(k)
				else:
					grown = true
#				break
			if cnt < 0:
				break
			else:
				cnt = cnt - 1
			if not grown:
				break
#			break
		floor_grid[h].optimize_flats()
	for h in range(n_floors):
		var edges_c = floor_grid[h].find_wall_edges(CORRIDOOR)
		var edges_e = floor_grid[h].find_wall_edges(ENTRY)
		var edges_d = floor_grid[h].find_door_edges(CORRIDOOR)
		for k in edges_d:
			print(k)
		var ov = OuterWalls.new(floor_grid[h].get_map(), 0.9)
		var c = Roomspace.new(floor_grid[h].get_map(), edges_c, [CORRIDOOR, ENTRY, OUTER_WALL, ENTRY_DOOR], Color(0.3, 0.3, 0.9))
		var e = Roomspace.new(floor_grid[h].get_map(), edges_e, [CORRIDOOR, OUTER_WALL, ENTRY_DOOR], Color(0.9, 0.3, 0.3))
		var d = Doors.new(edges_d, building_width, building_depth)
		add_child(ov)
		add_child(c)
		add_child(e)
		add_child(d)
		var tk = {}
		for t in floor_grid[h].room_data.keys():
			tk[t] = true
			var edges_d = floor_grid[h].find_wall_edges(t)
			var d = Roomspace.new(floor_grid[h].get_map(), edges_d, [CORRIDOOR, OUTER_WALL, ENTRY_DOOR] + tk.keys(), Color(1.0, 1.0, 1.0))
			add_child(d)
			d.set_translation(Vector3(0.0, floor_height * h, 0.0))
			var light = OmniLight.new()
			light.set_parameter(light.PARAM_ENERGY, 2.5)
			light.set_parameter(light.PARAM_RADIUS, 5.0)
			var trans = Vector3((floor_grid[h].room_data[t][0] - int(building_width / 2)) * grid_item, floor_height - 0.04, (floor_grid[h].room_data[t][1] - int(building_depth / 2)) * grid_item)
			add_child(light)
			light.set_translation(trans) 
		ov.set_translation(Vector3(0.0, floor_height * h, 0.0))
		c.set_translation(Vector3(0.0, floor_height * h, 0.0))
		e.set_translation(Vector3(0.0, floor_height * h, 0.0))
		d.set_translation(Vector3(0.0, floor_height * h, 0.0))
	
