#version 110

uniform sampler2D DiffuseSampler;

varying vec2 texCoord;
varying vec2 oneTexel;

uniform vec2 InSize;

void main() {

    vec4 InTexel = texture2D(DiffuseSampler, texCoord);
    gl_FragColor = InTexel;
    
}
