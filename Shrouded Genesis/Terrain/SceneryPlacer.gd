extends Node

class_name SceneryPlacer

var _mesh_instance
var _mdt
	
func _init(mesh_instance):
	_mesh_instance = mesh_instance
	_mdt = MeshDataTool.new() 
	var m = _mesh_instance.get_mesh()
	# get surface 0 into mesh data tool
	_mdt.create_from_surface(m, 0)
	
func get_trees(amount):
	if(!_mesh_instance):
		push_error("You must set the mesh instance using set_mesh() before placing scenery!")
	
	var vtx_count = _mdt.get_vertex_count()
	var random = RandomNumberGenerator.new()
	var tree_array = []
	random.randomize()
	for tree in amount:
		print(tree)
		# Get a random vertex index to place the tree on
		var tree_index = random.randi_range(0,vtx_count)
		# Now set the vertex to an actual vertex (Vector3) from the mesh
		var tree_vertex = _mdt.get_vertex(tree_index)
		var tree_node = load("res://Terrain/DeadTree1.tscn").instance()
		tree_node.translate(tree_vertex)
		tree_node.name  = "TreeNode{num}".format({"num":tree})
		tree_node.rotate_y(random.randf_range(0, PI * 2))
		tree_node.scale *= random.randf_range(0.5, 1.5)
		tree_array.append(tree_node)
	return tree_array
