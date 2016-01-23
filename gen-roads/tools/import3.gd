tool
extends EditorScenePostImport

func save_data(c):
	if c.is_type("MeshInstance"):
		var name = c.get_name()
		ResourceSaver.save("res://building/import/" + name + ".msh", c.get_mesh())
	for k in c.get_children():
		save_data(k)
func post_import(scene):
	save_data(scene)
