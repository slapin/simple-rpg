tool
extends EditorScenePostImport

func post_import(scene):
	scene.replace_by(RigidBody.new())
#	for k in scene.get_children():
#		scene.remove_child(k)
#		k.queue_free()
