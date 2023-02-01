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
	
# Generate an array of instanced scenery based on a level config file
# Supply the file path to the config file to use
# Each section in the config file should correspond to a scenery item to place
func get_scenery(config_file):
	if(!_mesh_instance):
		push_error("You must set the mesh instance using set_mesh() before placing scenery!")
	
	# We will place scenery items on random vertices of the ground mesh
	var vtx_count = _mdt.get_vertex_count()
	var random = RandomNumberGenerator.new()
	
	var scenery_array = []
	
	# Load data from the config file.
	var config = ConfigFile.new()
	var err = config.load(config_file)

	# If the file didn't load, ignore it.
	if err != OK:
		push_error("Something went wrong loading the level scenery config file!")
	
	# Iterate over all config sections e.g. scenery items
	for scenery in config.get_sections():
		# Fetch the data for each section.
		var path = config.get_value(scenery, "file_path")
		var scenery_name = config.get_value(scenery, "name")
		var count = config.get_value(scenery, "count")
		var lower_scale = config.get_value(scenery, "lower_scale")
		var upper_scale = config.get_value(scenery, "upper_scale")
		
		random.randomize()
		for scenery_instance in count:
			# Get a random vertex index to place the scenery on
			var scenery_index = random.randi_range(0,vtx_count)
			# Now set the vertex to an actual vertex (Vector3) from the mesh
			var scenery_vertex = _mdt.get_vertex(scenery_index)
			# Load the scenery scene
			var scenery_node = load(path).instance()
			# Set the scenery position to the vertex position
			scenery_node.translation = scenery_vertex
			scenery_node.name  = "{name}#{num}".format({"name":scenery_name, "num":scenery_instance})
			# Do a random rotation
			scenery_node.rotate_y(random.randf_range(0, PI * 2))
			# Randomize the scale based on lower and upper limits defined in the config
			# Use Gaussian distribution for more realistic variance around the mean
			var mean = (lower_scale + upper_scale)/2
			var deviation = mean/2
			scenery_node.scale *= random.randfn(mean, deviation)
			scenery_array.append(scenery_node)
	return scenery_array
