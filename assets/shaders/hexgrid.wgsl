#import bevy_pbr::mesh_view_bindings
#import bevy_pbr::mesh_types

@group(1) @binding(0)
var<uniform> mesh: Mesh;

struct Vertex {
    @location(0) position: vec3<f32>,
    @location(1) normal: vec3<f32>,
    @location(2) uv: vec2<f32>,

    @location(3) i_pos_scale: vec4<f32>,
    @location(4) i_color: u32,
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec4<f32>,
};

@vertex
fn vertex(vertex: Vertex) -> VertexOutput {
    let position = vertex.position * vertex.i_pos_scale.w + vertex.i_pos_scale.xyz;
    let world_position = mesh.model * vec4<f32>(position, 1.0);
    let world_normal = (mesh.inverse_transpose_model * vec4<f32>(vertex.normal, 0.0)).xyz;

    var color = vec4<f32>((vec4<u32>(vertex.i_color) >> vec4<u32>(0u, 8u, 16u, 24u)) & vec4<u32>(255u)) / 255.0;
    color = vec4<f32>(color.rgb * (dot(world_normal, normalize(vec3<f32>(0.2, 1.0, 0.1))) * 0.25 + 0.75), color.a);

    var out: VertexOutput;
    out.clip_position = view.view_proj * world_position;
    out.color = color;
    return out;
}

struct FragmentInput {
    @builtin(front_facing) is_front: bool,
    @builtin(position) frag_coord: vec4<f32>,
    @location(0) color: vec4<f32>,
};

@fragment
fn fragment(in: FragmentInput) -> @location(0) vec4<f32> {
    if (!in.is_front) {
		discard;
	}

    var threshold = array<array<f32, 4>, 4>(
        array<f32, 4>( 1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0),
        array<f32, 4>(13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0),
        array<f32, 4>( 4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0),
        array<f32, 4>(16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0)
    );

    return vec4<f32>(in.color.rgb, 1.0);
}
