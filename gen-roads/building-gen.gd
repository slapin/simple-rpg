
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

var n_floors = 9
var floor_grid = []
var building_width = 40
var building_depth = 45
var entry_door

const grid_item = 0.5
const floor_height = 3.0
const OUTER_WALL = 1000
const CORRIDOOR = 1001
const ENTRY = 1002
const ENTRY_DOOR = 1003

class BuildData extends MeshInstance:
	var shape_tris = []
	var material
	func add_triangle(st, v1, v2, v3, u1, u2, u3):
		var uvs = [u1, u2, u3]
		var pts = [v1, v2, v3]
		for g in range(pts.size()):
			st.add_uv(uvs[g])
			st.add_vertex(pts[g])
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
		var shape = ConcavePolygonShape.new()
		prepare_data(surfTool)
		surfTool.generate_normals()
		surfTool.index()
		surfTool.commit(mesh)
		set_mesh(mesh)
		shape.set_faces(Vector3Array(shape_tris))
		var body = StaticBody.new()
		body.add_shape(shape)
		add_child(body)

class Corridoor extends BuildData:
	var corridoor_width_min
	const C_DEPTH = 0
	const C_WIDTH = 1
	var c_style
	var c_width
	var c_length
	var fl_width
	var fl_depth
	var fl_map
	func generate_corridoor():
		var cx = int(fl_width / 2 + 0.5)
		var cy = int(fl_depth / 2 + 0.5)
		var dx
		var dy
		var rx
		var ry
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
				fl_map[ty][tx] = CORRIDOOR
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

	func grow_entry():
		for k in range(10 + randi() % 10):
			grow_room_rect(ENTRY)
	func connect_entry():
		pass
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
		if not fl_map[k][l] in [CORRIDOOR, ENTRY, OUTER_WALL, ENTRY_DOOR]:
			place_wall(st, l, k, q)
	func build_walls(st, id):
		var state = 0
		for k in range(1, fl_depth - 1):
			for l in range(0, fl_width):
				if state == 0:
					if fl_map[k][l] == id:
						state = 1
				elif state == 1:
					if fl_map[k][l] != id:
						print([l, k])
						state = 0
						check_place_wall(st, l, k, 0)
			for l in range(fl_width - 1, -1, -1):
				if state == 0:
					if fl_map[k][l] == id:
						state = 1
				elif state == 1:
					if fl_map[k][l] != id:
						print([l, k])
						state = 0
						check_place_wall(st, l, k, 1)
		for l in range(1, fl_width - 1):
			for k in range(0, fl_depth):
				if state == 0:
					if fl_map[k][l] == id:
						state = 1
				elif state == 1:
					if fl_map[k][l] != id:
						print([l, k])
						state = 0
						check_place_wall(st, l, k, 3)
			for k in range(fl_depth - 1, -1, -1):
				if state == 0:
					if fl_map[k][l] == id:
						state = 1
				elif state == 1:
					if fl_map[k][l] != id:
						print([l, k])
						state = 0
						check_place_wall(st, l, k, 3)
#		var u = quad_uvs(Vector2(), Vector2(grid_item, grid_item))
#		var pv = Vector3(0.0, floor_height / 2.0 + 0.5, 0.0)
#		var vs = Vector3(grid_item, floor_height - 1.8, grid_item)
#		var v = quad1(pv, vs, 0)
#		add_quad(st, v[0], v[1], v[2], v[3], u[0], u[1], u[2], u[3])
#		add_quad(st, v[3], v[2], v[1], v[0], u[0], u[1], u[2], u[3])
#		v = quad1(pv, vs, 1)
#		add_quad(st, v[0], v[1], v[2], v[3], u[0], u[1], u[2], u[3])
#		add_quad(st, v[3], v[2], v[1], v[0], u[0], u[1], u[2], u[3])
#		v = quad2(pv, vs, 0)
#		add_quad(st, v[0], v[1], v[2], v[3], u[0], u[1], u[2], u[3])
#		add_quad(st, v[3], v[2], v[1], v[0], u[0], u[1], u[2], u[3])
#		v = quad2(pv, vs, 1)
#		add_quad(st, v[0], v[1], v[2], v[3], u[0], u[1], u[2], u[3])
#		add_quad(st, v[3], v[2], v[1], v[0], u[0], u[1], u[2], u[3])
#		v = quad3(pv, vs, 0)
#		add_quad(st, v[0], v[1], v[2], v[3], u[0], u[1], u[2], u[3])
#		add_quad(st, v[3], v[2], v[1], v[0], u[0], u[1], u[2], u[3])
#		v = quad3(pv, vs, 1)
#		add_quad(st, v[0], v[1], v[2], v[3], u[0], u[1], u[2], u[3])
#		add_quad(st, v[3], v[2], v[1], v[0], u[0], u[1], u[2], u[3])
	func prepare_data(st):
		generate_corridoor()
		grow_entry()
		connect_entry()
		material.set_parameter(material.PARAM_DIFFUSE, Color(0.2, 0.2, 1.6))
		st.set_material(material)
		st.begin(VS.PRIMITIVE_TRIANGLES)
		build_walls(st, ENTRY)
		build_walls(st, CORRIDOOR)
	func _init(map):
		var c_width_min = 2.0 / grid_item
		._init()
		fl_width = map[0].size()
		fl_depth = map.size()
		fl_map = map
		if fl_width > fl_depth:
			c_style = C_WIDTH
			c_width = c_width_min + randi() % int(fl_width / 4)
			c_length = fl_width
		elif fl_depth >= fl_width:
			c_style = C_DEPTH
			c_width = c_width_min + randi() % int(fl_depth / 4)
			c_length = fl_depth
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
					var trans = Vector3((l - int(fl_width / 2)) * grid_item, 0.0, (k - int(fl_depth / 2)) * grid_item)
					add_floor_block(surfTool, trans, 0.5, 0.02, 0.5)
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


func init_grid():
	for r in range(n_floors):
		floor_grid.append([])
		for k in range(building_depth):
			floor_grid[r].append([])
			for l in range(building_width):
				floor_grid[r][k].append(0)
func setup_outer_walls():
	for r in range(n_floors):
		for k in [0, building_depth - 1]:
			for l in range(1, building_width - 1):
				floor_grid[r][k][l] = OUTER_WALL
		for k in range(0, building_depth):
			for l in [0, building_width - 1]:
				floor_grid[r][k][l] = OUTER_WALL
	
func setup_entry_door():
	var wall = randi() % 4
	if wall == 0:
		entry_door = Vector2(randi() % building_width, 0)
		floor_grid[0][entry_door.y + 1][entry_door.x] = ENTRY
		floor_grid[n_floors - 1][entry_door.y + 1][entry_door.x] = ENTRY
	elif wall == 1:
		entry_door = Vector2(randi() % building_width, building_depth - 1)
		floor_grid[0][entry_door.y - 1][entry_door.x] = ENTRY
		floor_grid[n_floors - 1][entry_door.y - 1][entry_door.x] = ENTRY
	elif wall == 2:
		entry_door = Vector2(0, randi() % building_depth)
		floor_grid[0][entry_door.y][entry_door.x + 1] = ENTRY
		floor_grid[n_floors - 1][entry_door.y][entry_door.x + 1] = ENTRY
	elif wall == 3:
		entry_door = Vector2(building_width - 1, randi() % building_depth)
		floor_grid[0][entry_door.y][entry_door.x - 1] = ENTRY
		floor_grid[n_floors - 1][entry_door.y][entry_door.x - 1] = ENTRY
	floor_grid[0][entry_door.y][entry_door.x] = ENTRY_DOOR
	floor_grid[n_floors - 1][entry_door.y][entry_door.x] = ENTRY_DOOR

func _ready():
	# Initialization here
	init_grid()
	setup_outer_walls()
	setup_entry_door()
	for h in range(n_floors):
		var ov = OuterWalls.new(floor_grid[h], 0.9)
		var c = Corridoor.new(floor_grid[h])
		add_child(ov)
		add_child(c)
		ov.set_translation(Vector3(0.0, floor_height * h, 0.0))
		c.set_translation(Vector3(0.0, floor_height * h, 0.0))
	
