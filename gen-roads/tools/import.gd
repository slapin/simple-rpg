tool
extends EditorScenePostImport

func post_import(scene):
	for k in scene.get_children()
		remove_child(k)
		k.queue_free()
