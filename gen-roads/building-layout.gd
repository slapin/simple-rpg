
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

var house = {
	"verts": [
		Vector2(-50.0, -50.0),
		Vector2(50.0, -50.0),
		Vector2(50.0, 50.0),
		Vector2(25.0, 50.0),
		Vector2(25.0, 25.0),
		Vector2(-50.0, 25.0),
	],
	"walls": [
		[0, 1],
		[1, 2],
		[2, 3],
		[3, 4],
		[4, 5],
		[5, 0],
	],
	"skel_edges": [
	],
}
class House:
	var verts
	var walls
	var skel_edges
	var skel_verts
	var wall2skel = {}
	var skel2wall = {}
	var vert2edge = {}
	var vert2wall = {}
	func add_vert2edge(edge):
		for k in edge:
			if vert2edge.has(verts[k]):
				vert2edge[verts[k]].append(edge)
			else:
				vert2edge[verts[k]] = [edge]
	func _init(data):
		verts = []
		walls = []
		skel_edges = []
		skel_verts = []
		for h in data["verts"]:
			verts.append(h)
			skel_verts.append(h)
		for h in data["walls"]:
			walls.append(h)
			add_vert2edge(h)
		check_house()
	func shared_edges(vert):
		if vert2edge.has(vert):
			return vert2edge[vert]
		else:
			return []
	func check_house():
		var valid = true
		for g in verts:
			if shared_edges(vert).size() != 2:
				valid = false
		if valid:
			print("House is valid")
		else:
			print("House is not valid, bad contour")
				
	func inside(pt):
		var v2a = Vector2Array(verts)
		var tris = Geometry.triangulate_polygon(v2a)
		for t in range(0,tris.size(), 3):
			var e = verts
			if Geometry.point_is_inside_triangle(pt, e[tris[t]], e[tris[t + 1]], e[tris[t + 2]]):
				return true
		return false
	func add_skel_edge(wall, edge):
		if wall2skel.has(wall):
			wall2skel[wall].append(edge)
		else:
			wall2skel[wall] = [edge]
		if skel2wall.has(edge):
			skel2wall[edge].append(wall)
		else:
			skel2wall[edge] = [wall]
func edge_origin(edge):
	return house["verts"][edge[0]]
func edge_vector(edge):
	return house["verts"][edge[1]] - edge_origin(edge)
func edge_tangent(edge):
	return edge_vector(edge).tangent()
func edge_eq(edge1, edge2):
	if edge1[0] != edge2[0]:
		return false
	elif edge1[1] != edge2[1]:
		return false
	else:
		return true
func shared_edges(edge):
	var elist = []
	for k in house["walls"]:
		if edge_eq(edge, k):
			continue
		for j in [k[0], k[1]]:
			if edge[0] == j:
				elist.append(k)
			elif edge[1] == j:
				elist.append(k)
	return elist
func midpoint(edge1, edge2, hint):
	if edge1[1] != edge2[0]:
		return null
	var vec1 = -edge_vector(edge1)
	var vec2 = edge_vector(edge2)
	if hint == 0:
		return (vec1.normalized() + vec2.normalized()) * vec1.length() * 20.0 + edge_origin(edge2)
	else:
		return -1.0 * (vec1.normalized() + vec2.normalized()) * vec1.length() * 20.0 + edge_origin(edge2)

func calc_fin(k, j, hint):
	var hint = 0
	var fin = [midpoint(k, j, hint), j[0]]
	if fin[0] == null:
		fin = [midpoint(j, k, hint), k[0]]
	return fin

func line_intersection(seg1, seg2):
	var A1 = seg1[1].y - seg1[0].y
	var B1 = seg1[0].x - seg1[1].x
	var C1 = -A1 * seg1[0].x - B1 * seg1[0].y
	var A2 = seg2[1].y - seg2[0].y
	var B2 = seg2[0].x - seg2[1].x
	var C2 = -A2 * seg2[0].x - B2 * seg2[0].y
	var det = A1 * B2 - B1 * A2
	if det == 0.0:
		return null
	var y = (A2 * C1 - A1 * C2) / det
	var x = (B1 * C2 - B2 * C1) / det
	return Vector2(x, y)

func _ready():
	var hd = House.new(house)
	for k in house["walls"]:
		k.append(-edge_tangent(k).normalized())
		k.append(-edge_tangent(k).normalized().dot(edge_origin(k)))
	for k in house["walls"]:
		var shared = shared_edges(k)
		var segment = []
		var edge_start = []
		for j in shared:
#			var off = house["verts"].size()
			var r = calc_fin(k, j, 0)
			var fin = r[0]
			var first = r[1]
			print(hd.inside(fin))
			if not hd.inside(fin):
				var r = calc_fin(k, j, 1)
				var fin = r[0]
				var first = r[1]
			segment.append([house["verts"][first], fin])
			edge_start.append(first)
#			house["verts"].append(fin)
#			house["skel_edges"].append([first, off])
		print(segment)
		var off = house["verts"].size()
		var isec = line_intersection(segment[0], segment[1])
		house["verts"].append(isec)
		print(isec)
		if isec != null:
			house["skel_edges"].append([edge_start[0], off])
			house["skel_edges"].append([edge_start[1], off])


func _draw():
	for k in house["walls"]:
		draw_line(house["verts"][k[0]] * 3 + Vector2(300.0, 300.0), house["verts"][k[1]] * 3 + Vector2(300.0, 300.0), Color(1.0, 0.0, 0.0))
		var v = (house["verts"][k[1]] - house["verts"][k[0]])
		var mp = v * 0.5
		var p = house["verts"][k[0]] + mp
		draw_line(p * 3 + Vector2(300.0, 300.0), (p + k[2] * 10) * 3 + Vector2(300.0, 300.0), Color(0.0, 1.0, 0.0))
		
	for k in house["skel_edges"]:
		draw_line(house["verts"][k[0]] * 3 + Vector2(300.0, 300.0), house["verts"][k[1]] * 3 + Vector2(300.0, 300.0), Color(0.0, 0.0, 1.0))


