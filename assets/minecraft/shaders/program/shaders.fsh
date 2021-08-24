#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D FinalSampler;
uniform sampler2D DataSampler;
uniform sampler2D PrevSampler;

varying vec2 texCoord;
varying vec2 oneTexel;

uniform float Time;
uniform vec2 InSize;

uniform vec2 Frequency;
uniform vec2 WobbleAmount;
uniform vec3 Phosphor;

// GLOWING SHADER
void glowing(float rIn, float gIn, float bIn){
    vec4 center = texture2D(FinalSampler, texCoord);
    vec4 left = texture2D(FinalSampler, texCoord - vec2(oneTexel.x, 0.0));
    vec4 right = texture2D(FinalSampler, texCoord + vec2(oneTexel.x, 0.0));
    vec4 up = texture2D(FinalSampler, texCoord - vec2(0.0, oneTexel.y));
    vec4 down = texture2D(FinalSampler, texCoord + vec2(0.0, oneTexel.y));
    float leftDiff  = abs(center.a - left.a);
    float rightDiff = abs(center.a - right.a);
    float upDiff    = abs(center.a - up.a);
    float downDiff  = abs(center.a - down.a);
    float total = clamp(leftDiff + rightDiff + upDiff + downDiff, 0.0, 1.0);
    vec3 outColor = center.rgb * center.a + left.rgb * left.a + right.rgb * right.a + up.rgb * up.a + down.rgb * down.a;
    gl_FragColor = vec4(rIn, gIn, bIn, total);
}

// Player Blur
void pblur() {
	vec2 BlurDir = vec2(2.0, 2.0);
	float Radius = 5.0;
	vec4 blurred = vec4(0.0);
	float totalStrength = 0.0;
	float totalAlpha = 0.0;
	float totalSamples = 0.0;
	float count = 0.0;
	for(float r = -Radius; r <= Radius; r += 1.0) {
		vec4 FinalTexel = texture2D(FinalSampler, texCoord + oneTexel * r * BlurDir);
		if(FinalTexel.r > 0.1 || FinalTexel.g > 0.1 || FinalTexel.b > 0.1) {
			vec4 sampleValue = texture2D(DiffuseSampler, texCoord + oneTexel * r * BlurDir);
			// Accumulate average alpha
			totalAlpha = totalAlpha + sampleValue.a;
			totalSamples = totalSamples + 1.0;

			// Accumulate smoothed blur
			float strength = 1.0 - abs(r / Radius);
			totalStrength = totalStrength + strength;
			blurred = blurred + sampleValue;
			
			count = count + 1.0;
		}
	}
	if(count > 0.0) {
		gl_FragColor = vec4(blurred.rgb / count, 0.5);
	} else {
		gl_FragColor = vec4(1.0, 1.0, 1.0, 0.0);
	}
}


/*
// Main Function
*/
void main() {
    
    vec4 InTexel = texture2D(DiffuseSampler, texCoord);
    vec3 InData = texture2D(DataSampler, vec2(1.0, 1.0)).rgb;

    if(InTexel == InTexel) {

		//  Detect Color
        if (InData == vec3(0.33333333, 1.0, 1.0)) { 
			// Aqua
            pblur();
        } else if (InData == vec3(0.33333333, 0.33333333, 1.0)) { 
			// Blue
            glowing(0.33, 0.33, 1.0);
        } else if (InData == vec3(0.0, 0.66666666, 0.66666666)) { 
			// Dark Aqua
            wobble();
        } else if (InData == vec3(0.0, 0.0, 0.66666666)) { 
			// Dark Blue
			glowing(0.0, 0.0, 0.66);
        } else if (InData == vec3(0.33333333, 0.33333333, 0.33333333)) { 
			// Dark Gray
          glowing(0.33, 0.33, 0.33);
        } else if (InData == vec3(0.0, 0.66666666, 0.0)) { 
			// Dark Green
            glowing(0.0, 0.66, 0.0);
        } else if (InData == vec3(0.66666666, 0.0, 0.66666666)) { 
			// Dark Purple
            glowing(0.66, 0.0, 0.66);
        } else if (InData == vec3(0.66666666, 0.0, 0.0)) { 
			// Dark Red
            glowing(0.66, 0.0, 0.0);
        } else if (InData == vec3(1.0, 0.66666666, 0.0)) { 
			// Gold
            glowing(1.0, 0.66, 0.0);
        } else if (InData == vec3(0.66666666, 0.66666666, 0.66666666)) { 
			//Gray
           glowing(0.66, 0.66, 0.66);
        } else if (InData == vec3(0.33333333, 1.0, 0.33333333)) { 
			// Green
            glowing(0.33, 1.0, 0.33);
        } else if (InData == vec3(1.0, 0.33333333, 1.0)) { 
			// Light Purple
			 glowing(1.0, 0.33, 1.0);
        } else if (InData == vec3(1.0, 0.33333333, 0.33333333)) { 
			// Red
			glowing(1.0, 0.33, 0.33);
        } else if (InData == vec3(1.0, 1.0, 1.0)) { 
			// White
           glowing(1.0, 1.0, 1.0);
        } else if (InData == vec3(1.0, 1.0, 0.33333333)) { 
		   // Yellow
            glowing(1.0, 1.0, 0.33);
        } else { 
			// No Color (Black) - UNUSED
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0); 
        }

    }
    
}