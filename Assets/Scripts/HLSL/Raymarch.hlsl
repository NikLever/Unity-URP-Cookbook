//Based on code from DMEville https://www.youtube.com/watch?v=0G8CVQZhMXw

void raymarch_float( float3 rayOrigin, float3 rayDirection, int numSteps, float stepSize, float densityScale, sampler3D Volume, float3 offset, int numLightSteps, float lightStepSize, float3 lightDir, float lightAbsorb, float darknessThreshold, float transmittance, out float3 result )
{
	float density = 0;
	float transmission = 0;
	float lightAccumulation = 0;
	float finalLight = 0;
	for(int i =0; i< numSteps; i++){
		rayOrigin += (rayDirection*stepSize);
					
		float3 samplePos = rayOrigin+offset;
		float sampledDensity = tex3D(Volume, samplePos).r;
		density += sampledDensity*densityScale;
		//light loop
		float3 lightRayOrigin = samplePos;
		for(int j = 0; j < numLightSteps; j++){
			lightRayOrigin += lightDir*lightStepSize;
			float lightDensity = tex3D(Volume, lightRayOrigin).r;
			lightAccumulation += lightDensity;
		}
		float lightTransmission = exp(-lightAccumulation);
		float shadow = darknessThreshold + lightTransmission * (1.0 -darknessThreshold);
		finalLight += density*transmittance*shadow;
		transmittance *= exp(-density*lightAbsorb);
					
	}
	transmission = exp(-density);

	result = float3(finalLight, transmission, transmittance);
}