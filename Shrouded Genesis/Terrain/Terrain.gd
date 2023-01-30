extends Spatial

func _ready():
	var noise = create_noise()
	var mesh_instance = create_mesh(noise)
	adjust_mesh_for_level(mesh_instance)
	# Add the mesh instance to the scene
	add_child(mesh_instance)
	
	var scenery_placer = SceneryPlacer.new(mesh_instance)
	var trees = scenery_placer.get_trees(200)
	for tree in trees:
		add_child(tree)
	
# Use a noise generator to make "interesting" terrain templates
func create_noise():
	var noise = OpenSimplexNoise.new()
	# How many hills/spikes in the terrain are there? Higher = more
	noise.period = 100
	# How "noisy" is the terrain? 9 is max and "most noisy". Lower = smoother
	noise.octaves = 3
	
	return noise

# Create the MeshInstance to be used for the terrain
func create_mesh(noise):
		# Use a plane to represent the ground. Mesh applies materials.
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(400,400)
	# How many triangles should be in the mesh? Higher = more polys
	plane_mesh.subdivide_depth = 100
	plane_mesh.subdivide_width = 100
	
	# Surface tools are used to construct a mesh
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	# Get an ArrayMesh to be fed into a MeshDataTool for editing vertices
	var array_plane = surface_tool.commit()
	
	# Feed the ArrayMesh into a MeshDataTool
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(array_plane, 0)
	
	# Set the height (y) of each vertex according to noise value
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = noise.get_noise_3d(vertex.x, vertex.y, vertex.z) * 20
		data_tool.set_vertex(i, vertex)
	
	# Remove old surfaces from ArrayMesh
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)
	
	# Replace with new surfaces from MeshDataTool
	data_tool.commit_to_surface(array_plane)
	
	# Load into the surface tool to vertex normals (used for lighting, etc.)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	# Create the MeshInstance so we can add to the scene
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = surface_tool.commit()
	
	# Add physics collisions to the mesh instance
	mesh_instance.create_trimesh_collision()
	return mesh_instance
	
# Make level-specific adjustments to the terrain
func adjust_mesh_for_level(mesh_instance):
	mesh_instance.set_surface_material(0, load("res://Terrain/Materials/terrain.material"))
