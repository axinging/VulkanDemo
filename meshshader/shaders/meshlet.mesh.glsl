#version 450

#extension GL_EXT_shader_16bit_storage: require
#extension GL_EXT_shader_8bit_storage: require
#extension GL_NV_mesh_shader: require

// TODO: bad for perf! local_size_x should be 32
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
layout(triangles, max_vertices = 64, max_primitives = 42) out;

/*
struct Vertex
{
	float vx, vy, vz, vw;
	float nx, ny, nz, nw;
};
*/

//
struct Vertex
{
	float vx, vy, vz, vw;
	float nx, ny, nz, nw;
	float tu, tv;
};
//

layout(binding = 0) readonly buffer Vertices
{
	Vertex vertices[];
};

struct Meshlet
{
	uint vertices[64];
	uint8_t indices[126]; // up to 42 triangles
	uint8_t indexCount;
	uint8_t vertexCount;
};

layout(binding = 1) readonly buffer Meshlets
{
	Meshlet meshlets[];
};

layout(location = 0) out vec4 color[];

void main()
{
	uint mi = gl_WorkGroupID.x;

	// TODO: really bad for perf; our workgroup has 1 thread!
	
	for (uint i = 0; i < uint(meshlets[mi].vertexCount); ++i)
	{
		uint vi = meshlets[mi].vertices[i];

		vec3 position = vec3(vertices[vi].vx, vertices[vi].vy, vertices[vi].vz);
		//vec3 position = vec3(vertices[vi].vx, vertices[vi].vy, 0.0f);
		vec3 normal = vec3(int(vertices[vi].nx), int(vertices[vi].ny), int(vertices[vi].nz)) / 127.0 - 1.0;
		// vec2 texcoord = vec2(vertices[vi].tu, vertices[vi].tv);

		// gl_MeshVerticesNV[i].gl_Position = vec4(position * vec3(1, 1, 0.5) + vec3(0, 0, 0.5), 1.0);
		gl_MeshVerticesNV[i].gl_Position = vec4(position, 1.0);
		color[i] = vec4(1.0, 1.0, 0.5, 1.0);
	}
	/*
		const std::vector<Vertex> vertices {
		{-0.5f, -0.5f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f},
		{0.5f, -0.5f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f},
		{0.5f, 0.5f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f},
		{-0.5f, 0.5f,0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f}
	};
	*/
	/*
	gl_MeshVerticesNV[0].gl_Position = vec4(-0.5f, -0.5f, 0.0f, 1.0);
	gl_MeshVerticesNV[1].gl_Position = vec4(0.5f, -0.5f, 0.0f, 1.0);
	gl_MeshVerticesNV[2].gl_Position = vec4(0.5f, 0.5f, 0.0f, 1.0);
	gl_MeshVerticesNV[3].gl_Position = vec4(-0.5f, 0.5f, 0.0f, 1.0);
	color[0] = vec4(1.0, 1.0, 0.5, 1.0);
	color[1] = vec4(1.0, 1.0, 0.5, 1.0);
	color[2] = vec4(1.0, 1.0, 0.5, 1.0);
	color[3] = vec4(1.0, 1.0, 0.5, 1.0);
	*/

    gl_PrimitiveCountNV = uint(meshlets[mi].indexCount) / 3;

	// TODO: really bad for perf; our workgroup has 1 thread!
	for (uint i = 0; i < uint(meshlets[mi].indexCount); ++i)
	{
		// TODO: possibly bad for perf, consider writePackedPrimitiveIndices4x8NV
		gl_PrimitiveIndicesNV[i] = uint(meshlets[mi].indices[i]);
	}
}