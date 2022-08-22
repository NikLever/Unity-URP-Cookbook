Shader "Custom/StencilMask"
{
	Properties{}

	SubShader{

		Tags {
			"RenderType" = "Opaque"
		}

		Pass {
			ZWrite Off

			HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);

                return OUT;
            }

            half4 frag() : SV_Target
            {
                return (half4)0;
            }

			ENDHLSL
		}
	}
}
