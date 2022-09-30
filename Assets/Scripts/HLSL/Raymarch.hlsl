//Based on code from DMEville https://www.youtube.com/watch?v=0G8CVQZhMXw

void raymarch_float( float3 rayOrigin, float3 rayDirection, float numSteps, float stepSize,
                     float densityScale, UnityTexture3D volumeTex, UnitySamplerState volumeSampler,
                     float3 offset, float numLightSteps, float lightStepSize, float3 lightDir,
                     float lightAbsorb, float darknessThreshold, float transmittance, out float3 result )
{
	float density = 0;
	float transmission = 0;
	float lightAccumulation = 0;
	float finalLight = 0;

    offset -= SHADERGRAPH_OBJECT_POSITION;

	for(int i =0; i< numSteps; i++){
		rayOrigin += (rayDirection*stepSize);
					
		float3 samplePos = rayOrigin+offset;
		float sampledDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, samplePos).r;
		density += sampledDensity*densityScale;
		//light loop
		float3 lightRayOrigin = samplePos;
		
		for(int j = 0; j < numLightSteps; j++){
			lightRayOrigin += -lightDir*lightStepSize;
			float lightDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, lightRayOrigin).r;
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

void raymarchv1_float( float3 rayOrigin, float3 rayDirection, float numSteps, float stepSize,
                     float densityScale, float4 Sphere, out float result )
{
	float density = 0;
	
	for(int i =0; i< numSteps; i++){
		rayOrigin += (rayDirection*stepSize);
					
		//Calculate density
		float sphereDist = distance(rayOrigin, Sphere.xyz);

		if(sphereDist < Sphere.w){
			density += 0.1 * densityScale;
        }
					
	}

	result = density;
}

void raymarchv2_float( float3 rayOrigin, float3 rayDirection, float numSteps, float stepSize,
                       float densityScale, UnityTexture3D volumeTex, UnitySamplerState volumeSampler,
                       float3 offset, out float result )
{
	float density = 0;
	float transmission = 0;
	offset -= SHADERGRAPH_OBJECT_POSITION;
	
	for(int i =0; i< numSteps; i++){
		rayOrigin += (rayDirection*stepSize);
					
		//Calculate density
		float sampledDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, rayOrigin + offset).r;
		density += sampledDensity;
					
	}

	result = density * densityScale;
}

void raymarchv3_float( float3 rayOrigin, float3 rayDirection, float numSteps, float stepSize,
                       float densityScale, UnityTexture3D volumeTex, UnitySamplerState volumeSampler,
                       float3 offset, float numLightSteps, float lightStepSize, float3 lightPosition,
                       out float result )
{
	float density = 0;
	float lightAccumulation = 0;
	offset -= SHADERGRAPH_OBJECT_POSITION;
	
	for(int i =0; i< numSteps; i++){
		rayOrigin += (rayDirection*stepSize);
		float3 samplePos = rayOrigin+offset;		
		//Calculate density
		float sampledDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, samplePos).r;
		density += sampledDensity;

		float3 lightRayOrigin = samplePos;
		float3 lightDir = samplePos - lightPosition;

		for(int j = 0; j < numLightSteps; j++){
			lightRayOrigin += lightDir*lightStepSize;
			float lightDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, lightRayOrigin).r;
			lightAccumulation += lightDensity;
		}	
	}

	result = density * densityScale;
}