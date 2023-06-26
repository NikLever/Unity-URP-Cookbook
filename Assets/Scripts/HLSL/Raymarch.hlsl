//Based on code from DMEville https://www.youtube.com/watch?v=0G8CVQZhMXw

//Uses 3D texture and lighting 
void raymarch_float( float3 rayOrigin, float3 rayDirection, float numSteps, float stepSize,
                     float densityScale, UnityTexture3D volumeTex, UnitySamplerState volumeSampler,
                     float3 offset, float numLightSteps, float lightStepSize, float3 lightDir,
                     float lightAbsorb, float darknessThreshold, float transmittance, out float3 result )
{
	float density = 0;
	float transmission = 0;
	float lightAccumulation = 0;
	float finalLight = 0;

    
	for(int i =0; i< numSteps; i++){
		rayOrigin += (rayDirection*stepSize);

		//The blue dot position
		float3 samplePos = rayOrigin+offset;
		float sampledDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, samplePos).r;
		density += sampledDensity*densityScale;

		//light loop
		float3 lightRayOrigin = samplePos;
		
		for(int j = 0; j < numLightSteps; j++){
			//The red dot position
			lightRayOrigin += -lightDir*lightStepSize;
			float lightDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, lightRayOrigin).r;
			//The accumulated density from samplePos to the light - the higher this value the less light reaches samplePos
			lightAccumulation += lightDensity;
		}

		//The amount of light received along the ray from param rayOrigin in the direction rayDirection
        float lightTransmission = exp(-lightAccumulation);
		//shadow tends to the darkness threshold as lightAccumulation rises
		float shadow = darknessThreshold + lightTransmission * (1.0 -darknessThreshold);
		//The final light value is accumulated based on the current density, transmittance value and the calculated shadow value 
		finalLight += density*transmittance*shadow;
		//Initially a param its value is updated at each step by lightAbsorb, this sets the light lost by scattering
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
			density += 0.1;
        }
					
	}

	result = density * densityScale;
}

void raymarchv2_float( float3 rayOrigin, float3 rayDirection, float numSteps, float stepSize,
                       float densityScale, UnityTexture3D volumeTex, UnitySamplerState volumeSampler,
                       float3 offset, out float result )
{
	float density = 0;
	float transmission = 0;
	
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
	//offset -= SHADERGRAPH_OBJECT_POSITION;
	
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