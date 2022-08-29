#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
StructuredBuffer<float2> PositionsBuffer;
#endif

float2 position;

void ConfigureProcedural () {
	#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
	position = PositionsBuffer[unity_InstanceID];
	#endif
}

void ShaderGraphFunction_float (out float2 PositionOut) {
	PositionOut = position;
}

void ShaderGraphFunction_half (out half2 PositionOut) {
	PositionOut = position;
}