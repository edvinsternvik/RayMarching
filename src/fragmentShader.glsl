#version 330 core
out vec4 FragColor;

in vec4 gl_FragCoord;

uniform vec3 u_eyePos;
uniform float u_rotY;
uniform vec2 u_windowSize;

uniform vec3 u_spherePositions[255];
uniform vec3 u_sphereColors[255];
uniform int u_sphereCount;

struct hitInfo {
	bool hit;
	vec3 hitPosition;
	bool isNear;
	int hitObjectIndex;
};

hitInfo castRay(vec3 rayPos, vec3 rayDir, float maxRayLength) {
	hitInfo hitInf;
	hitInf.hit = false;
	hitInf.isNear = false;
	float rayDistance = 0.0;

	while(rayDistance < maxRayLength && !hitInf.hit) {
		float smallestDistance = 0.0;
		int smallestIndex = 0;
		for(int j = 0; j < u_sphereCount; ++j) {
			float dist = length(rayPos - u_spherePositions[j]) - 1.0;
			
			if(j == 0) {
				smallestDistance = dist;
			}
			else {
				float a = smallestDistance, b = dist, k = 0.5;
				if(b < a) {
					smallestIndex = j;
				}

				float h = max( k-abs(a-b), 0.0 )/k;
    			smallestDistance = min( a, b ) - h*h*k*(1.0/4.0);
			}
		}
		rayDistance += smallestDistance;

		rayPos += rayDir * smallestDistance;

		if(smallestDistance < 0.0001) {
			hitInf.hit = true;
			hitInf.hitPosition = rayPos;
			hitInf.hitObjectIndex = smallestIndex;
		}

		if(smallestDistance < 0.01) {
			hitInf.isNear = true;
		}
	}

	return hitInf;
}

void main() {
	vec2 npc = vec2(gl_FragCoord) / u_windowSize - vec2(0.5); //Normalized pixel coordiantes
	npc.x *= (u_windowSize.x / u_windowSize.y);

	vec3 rayDir = normalize(vec3(sin(u_rotY + npc.x), npc.y, cos(u_rotY + npc.x) * -1.0));

	hitInfo hitInf = castRay(u_eyePos, rayDir, 100.0);

	vec3 color = vec3(0.4, 0.7, 1.0);
	if(hitInf.hit) {
		vec3 hitToLight = vec3(5.0, 0.0, 0.0) - hitInf.hitPosition;
		float distToLight = length(hitToLight);

		color = u_sphereColors[hitInf.hitObjectIndex];
		color *= vec3(1.0 - (distToLight * 0.1));

		vec3 hitToLightNormalized = normalize(hitToLight);
		hitInfo lightHitInf = castRay(hitInf.hitPosition + hitToLightNormalized * 0.1, hitToLightNormalized, distToLight);
	}

	FragColor = vec4(color, 1);
}