// grayscale + darken

precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;

// 1.0 = no darkening
// < 1.0 = darker
// try 0.7–0.85 range for comfort
const float darknessStrength = 0.75;

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);
    float g = dot(pixColor.rgb, vec3(0.2126, 0.7152, 0.0722));
    g *= darknessStrength;
    gl_FragColor = vec4(vec3(g), pixColor.a);
}

