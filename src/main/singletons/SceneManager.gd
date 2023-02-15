extends Node


var scenes_folder_path: String = "res://main/scenes/"

var current_scene: Node

func unload_scene() -> void:
	helpers.delete_children(self)

func load_scene(scene_name: String) -> void:
	unload_scene()
	var scene_path: String = scenes_folder_path + scene_name.to_lower() + "/" + \
					 scene_name.capitalize().replace(" ","") + ".tscn"

	
	current_scene = load(scene_path).instance()

	add_child(current_scene)
	print("[SceneManager] Loaded Scene: %s" % scene_path)
