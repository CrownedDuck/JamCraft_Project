shader_type canvas_item;

uniform sampler2D flowMap; //Displacement map
uniform float strength;    //Force of the effect
uniform float speed;       //Speed of the effect
uniform int frames : hint_range(1, 10); //Frames of the effect
uniform vec4 color : source_color = vec4(1.0);
//Returns a value between 0 and 1 depending of the frames -> exemple: frames = 4, frame 1 = 0.25
float clock(float time){
	float fframes = float(frames);
	return floor(mod(time * speed, fframes)) / fframes;
}

void fragment(){
	float c = clock(TIME); //Get clock frame
	vec2 uv_offset = mod(vec2(UV.x+c, UV.y+c), 1.0);
	vec4 offset = texture(flowMap, uv_offset) * strength; //Get offset 
	COLOR *= texture(TEXTURE, vec2(UV.x,UV.y) + offset.xy - vec2(0.5,0.5)*strength); //We need to remove the displacement 
}

