Shader "GPU Instancing Shader"
{
    Properties
    {
        [NoScaleOffset]_MainTexture("MainTexture", 2D) = "white" {}
        _WindShiftStrength("WindShiftStrength", Float) = 0
        _WindSpeed("WindSpeed", Float) = 0
        _WindStrength("WindStrength", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Geometry"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma shader_feature _ _SAMPLE_GI
            #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
            #define _FOG_FRAGMENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 positionWS;
                 float3 normalWS;
                 float4 texCoord0;
                 float3 viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 WorldSpaceTangent;
                 float3 ObjectSpaceBiTangent;
                 float3 WorldSpaceBiTangent;
                 float3 ObjectSpacePosition;
                 float3 WorldSpacePosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float3 interp1 : INTERP1;
                 float4 interp2 : INTERP2;
                 float3 interp3 : INTERP3;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
        PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.positionWS;
                output.interp1.xyz =  input.normalWS;
                output.interp2.xyzw =  input.texCoord0;
                output.interp3.xyz =  input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp0.xyz;
                output.normalWS = input.interp1.xyz;
                output.texCoord0 = input.interp2.xyzw;
                output.viewDirectionWS = input.interp3.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        //CBUFFER_START(UnityPerMaterial)
            float4 _MainTexture_TexelSize;
            half _WindShiftStrength;
            half _WindSpeed;
            half _WindStrength;
        //CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void TriangleWave_float(float In, out float Out)
            {
                Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            struct Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float
            {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            half4 uv0;
            float3 TimeParameters;
            };
            
            void SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(float _WindShiftStrength, float _WindSpeed, float _WindStrength, float3 _Position, Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float IN, out float3 Out_Vector4_1)
            {
            float3 _Property_ba69af3795ca452485fcfe9cc304b675_Out_0 = _Position;
            float _Split_3de17e256df54a5b841367501dc105e0_R_1 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[0];
            float _Split_3de17e256df54a5b841367501dc105e0_G_2 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[1];
            float _Split_3de17e256df54a5b841367501dc105e0_B_3 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[2];
            float _Split_3de17e256df54a5b841367501dc105e0_A_4 = 0;
            float _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2;
            Unity_SimpleNoise_float((_Property_ba69af3795ca452485fcfe9cc304b675_Out_0.xy), 500, _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2);
            float _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0 = _WindShiftStrength;
            float _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2;
            Unity_Multiply_float_float(_SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2, _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0, _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2);
            float _Property_c83311d520c04d448c73e13e9052b2cc_Out_0 = _WindSpeed;
            float _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c83311d520c04d448c73e13e9052b2cc_Out_0, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2);
            float _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2;
            Unity_Add_float(_Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2, _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2);
            float _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1;
            TriangleWave_float(_Add_3d041f187ef34d55a625c5bc1d943b79_Out_2, _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1);
            float _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0 = _WindStrength;
            float _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2;
            Unity_Multiply_float_float(_TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1, _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0, _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2);
            float _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2;
            Unity_Add_float(_Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2, _Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2);
            float4 _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0 = IN.uv0;
            float _Split_4ae5fe99a45d499bb8995259f1e45171_R_1 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[0];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_G_2 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[1];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_B_3 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[2];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_A_4 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[3];
            float _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3;
            Unity_Lerp_float(_Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2, _Split_4ae5fe99a45d499bb8995259f1e45171_G_2, _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3);
            float4 _Combine_f2511984976342d49af4e53718bb5361_RGBA_4;
            float3 _Combine_f2511984976342d49af4e53718bb5361_RGB_5;
            float2 _Combine_f2511984976342d49af4e53718bb5361_RG_6;
            Unity_Combine_float(_Lerp_dadcef85ff3d409d99e21489893493ac_Out_3, _Split_3de17e256df54a5b841367501dc105e0_G_2, _Split_3de17e256df54a5b841367501dc105e0_B_3, 0, _Combine_f2511984976342d49af4e53718bb5361_RGBA_4, _Combine_f2511984976342d49af4e53718bb5361_RGB_5, _Combine_f2511984976342d49af4e53718bb5361_RG_6);
            float3 _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1 = TransformWorldToObject(_Combine_f2511984976342d49af4e53718bb5361_RGB_5.xyz);
            Out_Vector4_1 = _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1;
            }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
            {
                float3 Position;
                half3 Normal;
                half3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                half _Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0 = _WindShiftStrength;
                half _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0 = _WindSpeed;
                half _Property_5beac3890650409fa717a2b959879df4_Out_0 = _WindStrength;
                Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float _GrassWave_861c999f8d524dc08fd61adc330a40e8;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceNormal = IN.WorldSpaceNormal;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceTangent = IN.WorldSpaceTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.uv0 = IN.uv0;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.TimeParameters = IN.TimeParameters;
                float3 _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(_Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0, _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0, _Property_5beac3890650409fa717a2b959879df4_Out_0, IN.WorldSpacePosition, _GrassWave_861c999f8d524dc08fd61adc330a40e8, _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1);
                description.Position = _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
            {
                half3 BaseColor;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Property_1379c5cf6aa241f68dba76eb3f0c04b1_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
                half4 _SampleTexture2D_24292768c977440c99e04baff4d312ca_RGBA_0 = SAMPLE_TEXTURE2D(_Property_1379c5cf6aa241f68dba76eb3f0c04b1_Out_0.tex, _Property_1379c5cf6aa241f68dba76eb3f0c04b1_Out_0.samplerstate, _Property_1379c5cf6aa241f68dba76eb3f0c04b1_Out_0.GetTransformedUV(IN.uv0.xy));
                half _SampleTexture2D_24292768c977440c99e04baff4d312ca_R_4 = _SampleTexture2D_24292768c977440c99e04baff4d312ca_RGBA_0.r;
                half _SampleTexture2D_24292768c977440c99e04baff4d312ca_G_5 = _SampleTexture2D_24292768c977440c99e04baff4d312ca_RGBA_0.g;
                half _SampleTexture2D_24292768c977440c99e04baff4d312ca_B_6 = _SampleTexture2D_24292768c977440c99e04baff4d312ca_RGBA_0.b;
                half _SampleTexture2D_24292768c977440c99e04baff4d312ca_A_7 = _SampleTexture2D_24292768c977440c99e04baff4d312ca_RGBA_0.a;
                surface.BaseColor = (_SampleTexture2D_24292768c977440c99e04baff4d312ca_RGBA_0.xyz);
                return surface;
            }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.WorldSpaceTangent =                          TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent =                       normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent =                        TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition =                        input.positionOS;
                output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                output.uv0 =                                        input.uv0;
                output.TimeParameters =                             _TimeParameters.xyz;
            
                return output;
            }
            
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 WorldSpaceTangent;
                 float3 ObjectSpaceBiTangent;
                 float3 WorldSpaceBiTangent;
                 float3 ObjectSpacePosition;
                 float3 WorldSpacePosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
        PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTexture_TexelSize;
            half _WindShiftStrength;
            half _WindSpeed;
            half _WindStrength;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void TriangleWave_float(float In, out float Out)
            {
                Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            struct Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float
            {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            half4 uv0;
            float3 TimeParameters;
            };
            
            void SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(float _WindShiftStrength, float _WindSpeed, float _WindStrength, float3 _Position, Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float IN, out float3 Out_Vector4_1)
            {
            float3 _Property_ba69af3795ca452485fcfe9cc304b675_Out_0 = _Position;
            float _Split_3de17e256df54a5b841367501dc105e0_R_1 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[0];
            float _Split_3de17e256df54a5b841367501dc105e0_G_2 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[1];
            float _Split_3de17e256df54a5b841367501dc105e0_B_3 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[2];
            float _Split_3de17e256df54a5b841367501dc105e0_A_4 = 0;
            float _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2;
            Unity_SimpleNoise_float((_Property_ba69af3795ca452485fcfe9cc304b675_Out_0.xy), 500, _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2);
            float _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0 = _WindShiftStrength;
            float _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2;
            Unity_Multiply_float_float(_SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2, _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0, _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2);
            float _Property_c83311d520c04d448c73e13e9052b2cc_Out_0 = _WindSpeed;
            float _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c83311d520c04d448c73e13e9052b2cc_Out_0, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2);
            float _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2;
            Unity_Add_float(_Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2, _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2);
            float _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1;
            TriangleWave_float(_Add_3d041f187ef34d55a625c5bc1d943b79_Out_2, _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1);
            float _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0 = _WindStrength;
            float _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2;
            Unity_Multiply_float_float(_TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1, _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0, _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2);
            float _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2;
            Unity_Add_float(_Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2, _Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2);
            float4 _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0 = IN.uv0;
            float _Split_4ae5fe99a45d499bb8995259f1e45171_R_1 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[0];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_G_2 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[1];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_B_3 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[2];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_A_4 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[3];
            float _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3;
            Unity_Lerp_float(_Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2, _Split_4ae5fe99a45d499bb8995259f1e45171_G_2, _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3);
            float4 _Combine_f2511984976342d49af4e53718bb5361_RGBA_4;
            float3 _Combine_f2511984976342d49af4e53718bb5361_RGB_5;
            float2 _Combine_f2511984976342d49af4e53718bb5361_RG_6;
            Unity_Combine_float(_Lerp_dadcef85ff3d409d99e21489893493ac_Out_3, _Split_3de17e256df54a5b841367501dc105e0_G_2, _Split_3de17e256df54a5b841367501dc105e0_B_3, 0, _Combine_f2511984976342d49af4e53718bb5361_RGBA_4, _Combine_f2511984976342d49af4e53718bb5361_RGB_5, _Combine_f2511984976342d49af4e53718bb5361_RG_6);
            float3 _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1 = TransformWorldToObject(_Combine_f2511984976342d49af4e53718bb5361_RGB_5.xyz);
            Out_Vector4_1 = _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1;
            }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
            {
                float3 Position;
                half3 Normal;
                half3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                half _Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0 = _WindShiftStrength;
                half _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0 = _WindSpeed;
                half _Property_5beac3890650409fa717a2b959879df4_Out_0 = _WindStrength;
                Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float _GrassWave_861c999f8d524dc08fd61adc330a40e8;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceNormal = IN.WorldSpaceNormal;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceTangent = IN.WorldSpaceTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.uv0 = IN.uv0;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.TimeParameters = IN.TimeParameters;
                float3 _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(_Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0, _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0, _Property_5beac3890650409fa717a2b959879df4_Out_0, IN.WorldSpacePosition, _GrassWave_861c999f8d524dc08fd61adc330a40e8, _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1);
                description.Position = _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
            {
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                return surface;
            }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.WorldSpaceTangent =                          TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent =                       normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent =                        TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition =                        input.positionOS;
                output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                output.uv0 =                                        input.uv0;
                output.TimeParameters =                             _TimeParameters.xyz;
            
                return output;
            }
            
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Back
            ZTest LEqual
            ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                 float4 uv1 : TEXCOORD1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 normalWS;
                 float4 tangentWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 WorldSpaceTangent;
                 float3 ObjectSpaceBiTangent;
                 float3 WorldSpaceBiTangent;
                 float3 ObjectSpacePosition;
                 float3 WorldSpacePosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float4 interp1 : INTERP1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
        PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.normalWS;
                output.interp1.xyzw =  input.tangentWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.normalWS = input.interp0.xyz;
                output.tangentWS = input.interp1.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTexture_TexelSize;
            half _WindShiftStrength;
            half _WindSpeed;
            half _WindStrength;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void TriangleWave_float(float In, out float Out)
            {
                Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            struct Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float
            {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            half4 uv0;
            float3 TimeParameters;
            };
            
            void SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(float _WindShiftStrength, float _WindSpeed, float _WindStrength, float3 _Position, Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float IN, out float3 Out_Vector4_1)
            {
            float3 _Property_ba69af3795ca452485fcfe9cc304b675_Out_0 = _Position;
            float _Split_3de17e256df54a5b841367501dc105e0_R_1 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[0];
            float _Split_3de17e256df54a5b841367501dc105e0_G_2 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[1];
            float _Split_3de17e256df54a5b841367501dc105e0_B_3 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[2];
            float _Split_3de17e256df54a5b841367501dc105e0_A_4 = 0;
            float _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2;
            Unity_SimpleNoise_float((_Property_ba69af3795ca452485fcfe9cc304b675_Out_0.xy), 500, _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2);
            float _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0 = _WindShiftStrength;
            float _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2;
            Unity_Multiply_float_float(_SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2, _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0, _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2);
            float _Property_c83311d520c04d448c73e13e9052b2cc_Out_0 = _WindSpeed;
            float _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c83311d520c04d448c73e13e9052b2cc_Out_0, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2);
            float _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2;
            Unity_Add_float(_Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2, _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2);
            float _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1;
            TriangleWave_float(_Add_3d041f187ef34d55a625c5bc1d943b79_Out_2, _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1);
            float _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0 = _WindStrength;
            float _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2;
            Unity_Multiply_float_float(_TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1, _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0, _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2);
            float _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2;
            Unity_Add_float(_Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2, _Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2);
            float4 _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0 = IN.uv0;
            float _Split_4ae5fe99a45d499bb8995259f1e45171_R_1 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[0];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_G_2 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[1];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_B_3 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[2];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_A_4 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[3];
            float _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3;
            Unity_Lerp_float(_Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2, _Split_4ae5fe99a45d499bb8995259f1e45171_G_2, _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3);
            float4 _Combine_f2511984976342d49af4e53718bb5361_RGBA_4;
            float3 _Combine_f2511984976342d49af4e53718bb5361_RGB_5;
            float2 _Combine_f2511984976342d49af4e53718bb5361_RG_6;
            Unity_Combine_float(_Lerp_dadcef85ff3d409d99e21489893493ac_Out_3, _Split_3de17e256df54a5b841367501dc105e0_G_2, _Split_3de17e256df54a5b841367501dc105e0_B_3, 0, _Combine_f2511984976342d49af4e53718bb5361_RGBA_4, _Combine_f2511984976342d49af4e53718bb5361_RGB_5, _Combine_f2511984976342d49af4e53718bb5361_RG_6);
            float3 _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1 = TransformWorldToObject(_Combine_f2511984976342d49af4e53718bb5361_RGB_5.xyz);
            Out_Vector4_1 = _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1;
            }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
            {
                float3 Position;
                half3 Normal;
                half3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                half _Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0 = _WindShiftStrength;
                half _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0 = _WindSpeed;
                half _Property_5beac3890650409fa717a2b959879df4_Out_0 = _WindStrength;
                Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float _GrassWave_861c999f8d524dc08fd61adc330a40e8;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceNormal = IN.WorldSpaceNormal;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceTangent = IN.WorldSpaceTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.uv0 = IN.uv0;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.TimeParameters = IN.TimeParameters;
                float3 _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(_Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0, _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0, _Property_5beac3890650409fa717a2b959879df4_Out_0, IN.WorldSpacePosition, _GrassWave_861c999f8d524dc08fd61adc330a40e8, _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1);
                description.Position = _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
            {
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                return surface;
            }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.WorldSpaceTangent =                          TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent =                       normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent =                        TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition =                        input.positionOS;
                output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                output.uv0 =                                        input.uv0;
                output.TimeParameters =                             _TimeParameters.xyz;
            
                return output;
            }
            
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
            #define SCENESELECTIONPASS 1
            #define ALPHA_CLIP_THRESHOLD 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 WorldSpaceTangent;
                 float3 ObjectSpaceBiTangent;
                 float3 WorldSpaceBiTangent;
                 float3 ObjectSpacePosition;
                 float3 WorldSpacePosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
        PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTexture_TexelSize;
            half _WindShiftStrength;
            half _WindSpeed;
            half _WindStrength;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void TriangleWave_float(float In, out float Out)
            {
                Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            struct Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float
            {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            half4 uv0;
            float3 TimeParameters;
            };
            
            void SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(float _WindShiftStrength, float _WindSpeed, float _WindStrength, float3 _Position, Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float IN, out float3 Out_Vector4_1)
            {
            float3 _Property_ba69af3795ca452485fcfe9cc304b675_Out_0 = _Position;
            float _Split_3de17e256df54a5b841367501dc105e0_R_1 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[0];
            float _Split_3de17e256df54a5b841367501dc105e0_G_2 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[1];
            float _Split_3de17e256df54a5b841367501dc105e0_B_3 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[2];
            float _Split_3de17e256df54a5b841367501dc105e0_A_4 = 0;
            float _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2;
            Unity_SimpleNoise_float((_Property_ba69af3795ca452485fcfe9cc304b675_Out_0.xy), 500, _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2);
            float _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0 = _WindShiftStrength;
            float _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2;
            Unity_Multiply_float_float(_SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2, _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0, _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2);
            float _Property_c83311d520c04d448c73e13e9052b2cc_Out_0 = _WindSpeed;
            float _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c83311d520c04d448c73e13e9052b2cc_Out_0, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2);
            float _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2;
            Unity_Add_float(_Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2, _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2);
            float _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1;
            TriangleWave_float(_Add_3d041f187ef34d55a625c5bc1d943b79_Out_2, _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1);
            float _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0 = _WindStrength;
            float _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2;
            Unity_Multiply_float_float(_TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1, _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0, _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2);
            float _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2;
            Unity_Add_float(_Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2, _Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2);
            float4 _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0 = IN.uv0;
            float _Split_4ae5fe99a45d499bb8995259f1e45171_R_1 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[0];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_G_2 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[1];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_B_3 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[2];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_A_4 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[3];
            float _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3;
            Unity_Lerp_float(_Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2, _Split_4ae5fe99a45d499bb8995259f1e45171_G_2, _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3);
            float4 _Combine_f2511984976342d49af4e53718bb5361_RGBA_4;
            float3 _Combine_f2511984976342d49af4e53718bb5361_RGB_5;
            float2 _Combine_f2511984976342d49af4e53718bb5361_RG_6;
            Unity_Combine_float(_Lerp_dadcef85ff3d409d99e21489893493ac_Out_3, _Split_3de17e256df54a5b841367501dc105e0_G_2, _Split_3de17e256df54a5b841367501dc105e0_B_3, 0, _Combine_f2511984976342d49af4e53718bb5361_RGBA_4, _Combine_f2511984976342d49af4e53718bb5361_RGB_5, _Combine_f2511984976342d49af4e53718bb5361_RG_6);
            float3 _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1 = TransformWorldToObject(_Combine_f2511984976342d49af4e53718bb5361_RGB_5.xyz);
            Out_Vector4_1 = _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1;
            }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
            {
                float3 Position;
                half3 Normal;
                half3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                half _Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0 = _WindShiftStrength;
                half _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0 = _WindSpeed;
                half _Property_5beac3890650409fa717a2b959879df4_Out_0 = _WindStrength;
                Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float _GrassWave_861c999f8d524dc08fd61adc330a40e8;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceNormal = IN.WorldSpaceNormal;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceTangent = IN.WorldSpaceTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.uv0 = IN.uv0;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.TimeParameters = IN.TimeParameters;
                float3 _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(_Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0, _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0, _Property_5beac3890650409fa717a2b959879df4_Out_0, IN.WorldSpacePosition, _GrassWave_861c999f8d524dc08fd61adc330a40e8, _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1);
                description.Position = _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
            {
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                return surface;
            }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.WorldSpaceTangent =                          TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent =                       normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent =                        TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition =                        input.positionOS;
                output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                output.uv0 =                                        input.uv0;
                output.TimeParameters =                             _TimeParameters.xyz;
            
                return output;
            }
            
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
            #define SCENEPICKINGPASS 1
            #define ALPHA_CLIP_THRESHOLD 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 WorldSpaceTangent;
                 float3 ObjectSpaceBiTangent;
                 float3 WorldSpaceBiTangent;
                 float3 ObjectSpacePosition;
                 float3 WorldSpacePosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
        PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTexture_TexelSize;
            half _WindShiftStrength;
            half _WindSpeed;
            half _WindStrength;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void TriangleWave_float(float In, out float Out)
            {
                Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            struct Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float
            {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            half4 uv0;
            float3 TimeParameters;
            };
            
            void SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(float _WindShiftStrength, float _WindSpeed, float _WindStrength, float3 _Position, Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float IN, out float3 Out_Vector4_1)
            {
            float3 _Property_ba69af3795ca452485fcfe9cc304b675_Out_0 = _Position;
            float _Split_3de17e256df54a5b841367501dc105e0_R_1 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[0];
            float _Split_3de17e256df54a5b841367501dc105e0_G_2 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[1];
            float _Split_3de17e256df54a5b841367501dc105e0_B_3 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[2];
            float _Split_3de17e256df54a5b841367501dc105e0_A_4 = 0;
            float _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2;
            Unity_SimpleNoise_float((_Property_ba69af3795ca452485fcfe9cc304b675_Out_0.xy), 500, _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2);
            float _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0 = _WindShiftStrength;
            float _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2;
            Unity_Multiply_float_float(_SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2, _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0, _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2);
            float _Property_c83311d520c04d448c73e13e9052b2cc_Out_0 = _WindSpeed;
            float _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c83311d520c04d448c73e13e9052b2cc_Out_0, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2);
            float _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2;
            Unity_Add_float(_Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2, _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2);
            float _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1;
            TriangleWave_float(_Add_3d041f187ef34d55a625c5bc1d943b79_Out_2, _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1);
            float _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0 = _WindStrength;
            float _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2;
            Unity_Multiply_float_float(_TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1, _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0, _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2);
            float _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2;
            Unity_Add_float(_Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2, _Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2);
            float4 _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0 = IN.uv0;
            float _Split_4ae5fe99a45d499bb8995259f1e45171_R_1 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[0];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_G_2 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[1];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_B_3 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[2];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_A_4 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[3];
            float _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3;
            Unity_Lerp_float(_Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2, _Split_4ae5fe99a45d499bb8995259f1e45171_G_2, _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3);
            float4 _Combine_f2511984976342d49af4e53718bb5361_RGBA_4;
            float3 _Combine_f2511984976342d49af4e53718bb5361_RGB_5;
            float2 _Combine_f2511984976342d49af4e53718bb5361_RG_6;
            Unity_Combine_float(_Lerp_dadcef85ff3d409d99e21489893493ac_Out_3, _Split_3de17e256df54a5b841367501dc105e0_G_2, _Split_3de17e256df54a5b841367501dc105e0_B_3, 0, _Combine_f2511984976342d49af4e53718bb5361_RGBA_4, _Combine_f2511984976342d49af4e53718bb5361_RGB_5, _Combine_f2511984976342d49af4e53718bb5361_RG_6);
            float3 _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1 = TransformWorldToObject(_Combine_f2511984976342d49af4e53718bb5361_RGB_5.xyz);
            Out_Vector4_1 = _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1;
            }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
            {
                float3 Position;
                half3 Normal;
                half3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                half _Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0 = _WindShiftStrength;
                half _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0 = _WindSpeed;
                half _Property_5beac3890650409fa717a2b959879df4_Out_0 = _WindStrength;
                Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float _GrassWave_861c999f8d524dc08fd61adc330a40e8;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceNormal = IN.WorldSpaceNormal;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceTangent = IN.WorldSpaceTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.uv0 = IN.uv0;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.TimeParameters = IN.TimeParameters;
                float3 _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(_Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0, _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0, _Property_5beac3890650409fa717a2b959879df4_Out_0, IN.WorldSpacePosition, _GrassWave_861c999f8d524dc08fd61adc330a40e8, _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1);
                description.Position = _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
            {
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                return surface;
            }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.WorldSpaceTangent =                          TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent =                       normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent =                        TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition =                        input.positionOS;
                output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                output.uv0 =                                        input.uv0;
                output.TimeParameters =                             _TimeParameters.xyz;
            
                return output;
            }
            
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Back
            ZTest LEqual
            ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma vertex vert
            #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 WorldSpaceTangent;
                 float3 ObjectSpaceBiTangent;
                 float3 WorldSpaceBiTangent;
                 float3 ObjectSpacePosition;
                 float3 WorldSpacePosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
        PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.normalWS = input.interp0.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTexture_TexelSize;
            half _WindShiftStrength;
            half _WindSpeed;
            half _WindStrength;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void TriangleWave_float(float In, out float Out)
            {
                Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            struct Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float
            {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            half4 uv0;
            float3 TimeParameters;
            };
            
            void SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(float _WindShiftStrength, float _WindSpeed, float _WindStrength, float3 _Position, Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float IN, out float3 Out_Vector4_1)
            {
            float3 _Property_ba69af3795ca452485fcfe9cc304b675_Out_0 = _Position;
            float _Split_3de17e256df54a5b841367501dc105e0_R_1 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[0];
            float _Split_3de17e256df54a5b841367501dc105e0_G_2 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[1];
            float _Split_3de17e256df54a5b841367501dc105e0_B_3 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[2];
            float _Split_3de17e256df54a5b841367501dc105e0_A_4 = 0;
            float _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2;
            Unity_SimpleNoise_float((_Property_ba69af3795ca452485fcfe9cc304b675_Out_0.xy), 500, _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2);
            float _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0 = _WindShiftStrength;
            float _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2;
            Unity_Multiply_float_float(_SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2, _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0, _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2);
            float _Property_c83311d520c04d448c73e13e9052b2cc_Out_0 = _WindSpeed;
            float _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c83311d520c04d448c73e13e9052b2cc_Out_0, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2);
            float _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2;
            Unity_Add_float(_Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2, _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2);
            float _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1;
            TriangleWave_float(_Add_3d041f187ef34d55a625c5bc1d943b79_Out_2, _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1);
            float _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0 = _WindStrength;
            float _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2;
            Unity_Multiply_float_float(_TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1, _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0, _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2);
            float _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2;
            Unity_Add_float(_Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2, _Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2);
            float4 _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0 = IN.uv0;
            float _Split_4ae5fe99a45d499bb8995259f1e45171_R_1 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[0];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_G_2 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[1];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_B_3 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[2];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_A_4 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[3];
            float _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3;
            Unity_Lerp_float(_Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2, _Split_4ae5fe99a45d499bb8995259f1e45171_G_2, _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3);
            float4 _Combine_f2511984976342d49af4e53718bb5361_RGBA_4;
            float3 _Combine_f2511984976342d49af4e53718bb5361_RGB_5;
            float2 _Combine_f2511984976342d49af4e53718bb5361_RG_6;
            Unity_Combine_float(_Lerp_dadcef85ff3d409d99e21489893493ac_Out_3, _Split_3de17e256df54a5b841367501dc105e0_G_2, _Split_3de17e256df54a5b841367501dc105e0_B_3, 0, _Combine_f2511984976342d49af4e53718bb5361_RGBA_4, _Combine_f2511984976342d49af4e53718bb5361_RGB_5, _Combine_f2511984976342d49af4e53718bb5361_RG_6);
            float3 _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1 = TransformWorldToObject(_Combine_f2511984976342d49af4e53718bb5361_RGB_5.xyz);
            Out_Vector4_1 = _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1;
            }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
            {
                float3 Position;
                half3 Normal;
                half3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                half _Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0 = _WindShiftStrength;
                half _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0 = _WindSpeed;
                half _Property_5beac3890650409fa717a2b959879df4_Out_0 = _WindStrength;
                Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float _GrassWave_861c999f8d524dc08fd61adc330a40e8;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceNormal = IN.WorldSpaceNormal;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceTangent = IN.WorldSpaceTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.uv0 = IN.uv0;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.TimeParameters = IN.TimeParameters;
                float3 _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(_Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0, _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0, _Property_5beac3890650409fa717a2b959879df4_Out_0, IN.WorldSpacePosition, _GrassWave_861c999f8d524dc08fd61adc330a40e8, _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1);
                description.Position = _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
            {
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                return surface;
            }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.WorldSpaceTangent =                          TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent =                       normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent =                        TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition =                        input.positionOS;
                output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                output.uv0 =                                        input.uv0;
                output.TimeParameters =                             _TimeParameters.xyz;
            
                return output;
            }
            
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Geometry"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma vertex vert
            #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma shader_feature _ _SAMPLE_GI
            #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
            #define _FOG_FRAGMENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 positionWS;
                 float3 normalWS;
                 float4 texCoord0;
                 float3 viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 WorldSpaceTangent;
                 float3 ObjectSpaceBiTangent;
                 float3 WorldSpaceBiTangent;
                 float3 ObjectSpacePosition;
                 float3 WorldSpacePosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float3 interp1 : INTERP1;
                 float4 interp2 : INTERP2;
                 float3 interp3 : INTERP3;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
        PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.positionWS;
                output.interp1.xyz =  input.normalWS;
                output.interp2.xyzw =  input.texCoord0;
                output.interp3.xyz =  input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp0.xyz;
                output.normalWS = input.interp1.xyz;
                output.texCoord0 = input.interp2.xyzw;
                output.viewDirectionWS = input.interp3.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTexture_TexelSize;
            half _WindShiftStrength;
            half _WindSpeed;
            half _WindStrength;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void TriangleWave_float(float In, out float Out)
            {
                Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            struct Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float
            {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            half4 uv0;
            float3 TimeParameters;
            };
            
            void SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(float _WindShiftStrength, float _WindSpeed, float _WindStrength, float3 _Position, Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float IN, out float3 Out_Vector4_1)
            {
            float3 _Property_ba69af3795ca452485fcfe9cc304b675_Out_0 = _Position;
            float _Split_3de17e256df54a5b841367501dc105e0_R_1 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[0];
            float _Split_3de17e256df54a5b841367501dc105e0_G_2 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[1];
            float _Split_3de17e256df54a5b841367501dc105e0_B_3 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[2];
            float _Split_3de17e256df54a5b841367501dc105e0_A_4 = 0;
            float _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2;
            Unity_SimpleNoise_float((_Property_ba69af3795ca452485fcfe9cc304b675_Out_0.xy), 500, _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2);
            float _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0 = _WindShiftStrength;
            float _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2;
            Unity_Multiply_float_float(_SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2, _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0, _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2);
            float _Property_c83311d520c04d448c73e13e9052b2cc_Out_0 = _WindSpeed;
            float _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c83311d520c04d448c73e13e9052b2cc_Out_0, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2);
            float _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2;
            Unity_Add_float(_Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2, _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2);
            float _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1;
            TriangleWave_float(_Add_3d041f187ef34d55a625c5bc1d943b79_Out_2, _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1);
            float _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0 = _WindStrength;
            float _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2;
            Unity_Multiply_float_float(_TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1, _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0, _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2);
            float _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2;
            Unity_Add_float(_Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2, _Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2);
            float4 _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0 = IN.uv0;
            float _Split_4ae5fe99a45d499bb8995259f1e45171_R_1 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[0];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_G_2 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[1];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_B_3 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[2];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_A_4 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[3];
            float _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3;
            Unity_Lerp_float(_Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2, _Split_4ae5fe99a45d499bb8995259f1e45171_G_2, _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3);
            float4 _Combine_f2511984976342d49af4e53718bb5361_RGBA_4;
            float3 _Combine_f2511984976342d49af4e53718bb5361_RGB_5;
            float2 _Combine_f2511984976342d49af4e53718bb5361_RG_6;
            Unity_Combine_float(_Lerp_dadcef85ff3d409d99e21489893493ac_Out_3, _Split_3de17e256df54a5b841367501dc105e0_G_2, _Split_3de17e256df54a5b841367501dc105e0_B_3, 0, _Combine_f2511984976342d49af4e53718bb5361_RGBA_4, _Combine_f2511984976342d49af4e53718bb5361_RGB_5, _Combine_f2511984976342d49af4e53718bb5361_RG_6);
            float3 _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1 = TransformWorldToObject(_Combine_f2511984976342d49af4e53718bb5361_RGB_5.xyz);
            Out_Vector4_1 = _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1;
            }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
            {
                float3 Position;
                half3 Normal;
                half3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                half _Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0 = _WindShiftStrength;
                half _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0 = _WindSpeed;
                half _Property_5beac3890650409fa717a2b959879df4_Out_0 = _WindStrength;
                Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float _GrassWave_861c999f8d524dc08fd61adc330a40e8;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceNormal = IN.WorldSpaceNormal;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceTangent = IN.WorldSpaceTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.uv0 = IN.uv0;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.TimeParameters = IN.TimeParameters;
                float3 _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(_Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0, _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0, _Property_5beac3890650409fa717a2b959879df4_Out_0, IN.WorldSpacePosition, _GrassWave_861c999f8d524dc08fd61adc330a40e8, _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1);
                description.Position = _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
            {
                half3 BaseColor;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Property_1379c5cf6aa241f68dba76eb3f0c04b1_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
                half4 _SampleTexture2D_24292768c977440c99e04baff4d312ca_RGBA_0 = SAMPLE_TEXTURE2D(_Property_1379c5cf6aa241f68dba76eb3f0c04b1_Out_0.tex, _Property_1379c5cf6aa241f68dba76eb3f0c04b1_Out_0.samplerstate, _Property_1379c5cf6aa241f68dba76eb3f0c04b1_Out_0.GetTransformedUV(IN.uv0.xy));
                half _SampleTexture2D_24292768c977440c99e04baff4d312ca_R_4 = _SampleTexture2D_24292768c977440c99e04baff4d312ca_RGBA_0.r;
                half _SampleTexture2D_24292768c977440c99e04baff4d312ca_G_5 = _SampleTexture2D_24292768c977440c99e04baff4d312ca_RGBA_0.g;
                half _SampleTexture2D_24292768c977440c99e04baff4d312ca_B_6 = _SampleTexture2D_24292768c977440c99e04baff4d312ca_RGBA_0.b;
                half _SampleTexture2D_24292768c977440c99e04baff4d312ca_A_7 = _SampleTexture2D_24292768c977440c99e04baff4d312ca_RGBA_0.a;
                surface.BaseColor = (_SampleTexture2D_24292768c977440c99e04baff4d312ca_RGBA_0.xyz);
                return surface;
            }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.WorldSpaceTangent =                          TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent =                       normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent =                        TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition =                        input.positionOS;
                output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                output.uv0 =                                        input.uv0;
                output.TimeParameters =                             _TimeParameters.xyz;
            
                return output;
            }
            
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 WorldSpaceTangent;
                 float3 ObjectSpaceBiTangent;
                 float3 WorldSpaceBiTangent;
                 float3 ObjectSpacePosition;
                 float3 WorldSpacePosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
        PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTexture_TexelSize;
            half _WindShiftStrength;
            half _WindSpeed;
            half _WindStrength;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void TriangleWave_float(float In, out float Out)
            {
                Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            struct Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float
            {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            half4 uv0;
            float3 TimeParameters;
            };
            
            void SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(float _WindShiftStrength, float _WindSpeed, float _WindStrength, float3 _Position, Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float IN, out float3 Out_Vector4_1)
            {
            float3 _Property_ba69af3795ca452485fcfe9cc304b675_Out_0 = _Position;
            float _Split_3de17e256df54a5b841367501dc105e0_R_1 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[0];
            float _Split_3de17e256df54a5b841367501dc105e0_G_2 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[1];
            float _Split_3de17e256df54a5b841367501dc105e0_B_3 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[2];
            float _Split_3de17e256df54a5b841367501dc105e0_A_4 = 0;
            float _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2;
            Unity_SimpleNoise_float((_Property_ba69af3795ca452485fcfe9cc304b675_Out_0.xy), 500, _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2);
            float _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0 = _WindShiftStrength;
            float _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2;
            Unity_Multiply_float_float(_SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2, _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0, _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2);
            float _Property_c83311d520c04d448c73e13e9052b2cc_Out_0 = _WindSpeed;
            float _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c83311d520c04d448c73e13e9052b2cc_Out_0, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2);
            float _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2;
            Unity_Add_float(_Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2, _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2);
            float _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1;
            TriangleWave_float(_Add_3d041f187ef34d55a625c5bc1d943b79_Out_2, _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1);
            float _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0 = _WindStrength;
            float _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2;
            Unity_Multiply_float_float(_TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1, _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0, _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2);
            float _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2;
            Unity_Add_float(_Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2, _Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2);
            float4 _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0 = IN.uv0;
            float _Split_4ae5fe99a45d499bb8995259f1e45171_R_1 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[0];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_G_2 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[1];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_B_3 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[2];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_A_4 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[3];
            float _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3;
            Unity_Lerp_float(_Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2, _Split_4ae5fe99a45d499bb8995259f1e45171_G_2, _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3);
            float4 _Combine_f2511984976342d49af4e53718bb5361_RGBA_4;
            float3 _Combine_f2511984976342d49af4e53718bb5361_RGB_5;
            float2 _Combine_f2511984976342d49af4e53718bb5361_RG_6;
            Unity_Combine_float(_Lerp_dadcef85ff3d409d99e21489893493ac_Out_3, _Split_3de17e256df54a5b841367501dc105e0_G_2, _Split_3de17e256df54a5b841367501dc105e0_B_3, 0, _Combine_f2511984976342d49af4e53718bb5361_RGBA_4, _Combine_f2511984976342d49af4e53718bb5361_RGB_5, _Combine_f2511984976342d49af4e53718bb5361_RG_6);
            float3 _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1 = TransformWorldToObject(_Combine_f2511984976342d49af4e53718bb5361_RGB_5.xyz);
            Out_Vector4_1 = _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1;
            }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
            {
                float3 Position;
                half3 Normal;
                half3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                half _Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0 = _WindShiftStrength;
                half _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0 = _WindSpeed;
                half _Property_5beac3890650409fa717a2b959879df4_Out_0 = _WindStrength;
                Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float _GrassWave_861c999f8d524dc08fd61adc330a40e8;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceNormal = IN.WorldSpaceNormal;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceTangent = IN.WorldSpaceTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.uv0 = IN.uv0;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.TimeParameters = IN.TimeParameters;
                float3 _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(_Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0, _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0, _Property_5beac3890650409fa717a2b959879df4_Out_0, IN.WorldSpacePosition, _GrassWave_861c999f8d524dc08fd61adc330a40e8, _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1);
                description.Position = _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
            {
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                return surface;
            }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.WorldSpaceTangent =                          TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent =                       normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent =                        TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition =                        input.positionOS;
                output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                output.uv0 =                                        input.uv0;
                output.TimeParameters =                             _TimeParameters.xyz;
            
                return output;
            }
            
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Back
            ZTest LEqual
            ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                 float4 uv1 : TEXCOORD1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 normalWS;
                 float4 tangentWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 WorldSpaceTangent;
                 float3 ObjectSpaceBiTangent;
                 float3 WorldSpaceBiTangent;
                 float3 ObjectSpacePosition;
                 float3 WorldSpacePosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float4 interp1 : INTERP1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
        PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.normalWS;
                output.interp1.xyzw =  input.tangentWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.normalWS = input.interp0.xyz;
                output.tangentWS = input.interp1.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTexture_TexelSize;
            half _WindShiftStrength;
            half _WindSpeed;
            half _WindStrength;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void TriangleWave_float(float In, out float Out)
            {
                Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            struct Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float
            {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            half4 uv0;
            float3 TimeParameters;
            };
            
            void SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(float _WindShiftStrength, float _WindSpeed, float _WindStrength, float3 _Position, Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float IN, out float3 Out_Vector4_1)
            {
            float3 _Property_ba69af3795ca452485fcfe9cc304b675_Out_0 = _Position;
            float _Split_3de17e256df54a5b841367501dc105e0_R_1 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[0];
            float _Split_3de17e256df54a5b841367501dc105e0_G_2 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[1];
            float _Split_3de17e256df54a5b841367501dc105e0_B_3 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[2];
            float _Split_3de17e256df54a5b841367501dc105e0_A_4 = 0;
            float _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2;
            Unity_SimpleNoise_float((_Property_ba69af3795ca452485fcfe9cc304b675_Out_0.xy), 500, _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2);
            float _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0 = _WindShiftStrength;
            float _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2;
            Unity_Multiply_float_float(_SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2, _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0, _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2);
            float _Property_c83311d520c04d448c73e13e9052b2cc_Out_0 = _WindSpeed;
            float _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c83311d520c04d448c73e13e9052b2cc_Out_0, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2);
            float _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2;
            Unity_Add_float(_Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2, _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2);
            float _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1;
            TriangleWave_float(_Add_3d041f187ef34d55a625c5bc1d943b79_Out_2, _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1);
            float _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0 = _WindStrength;
            float _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2;
            Unity_Multiply_float_float(_TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1, _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0, _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2);
            float _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2;
            Unity_Add_float(_Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2, _Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2);
            float4 _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0 = IN.uv0;
            float _Split_4ae5fe99a45d499bb8995259f1e45171_R_1 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[0];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_G_2 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[1];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_B_3 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[2];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_A_4 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[3];
            float _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3;
            Unity_Lerp_float(_Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2, _Split_4ae5fe99a45d499bb8995259f1e45171_G_2, _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3);
            float4 _Combine_f2511984976342d49af4e53718bb5361_RGBA_4;
            float3 _Combine_f2511984976342d49af4e53718bb5361_RGB_5;
            float2 _Combine_f2511984976342d49af4e53718bb5361_RG_6;
            Unity_Combine_float(_Lerp_dadcef85ff3d409d99e21489893493ac_Out_3, _Split_3de17e256df54a5b841367501dc105e0_G_2, _Split_3de17e256df54a5b841367501dc105e0_B_3, 0, _Combine_f2511984976342d49af4e53718bb5361_RGBA_4, _Combine_f2511984976342d49af4e53718bb5361_RGB_5, _Combine_f2511984976342d49af4e53718bb5361_RG_6);
            float3 _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1 = TransformWorldToObject(_Combine_f2511984976342d49af4e53718bb5361_RGB_5.xyz);
            Out_Vector4_1 = _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1;
            }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
            {
                float3 Position;
                half3 Normal;
                half3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                half _Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0 = _WindShiftStrength;
                half _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0 = _WindSpeed;
                half _Property_5beac3890650409fa717a2b959879df4_Out_0 = _WindStrength;
                Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float _GrassWave_861c999f8d524dc08fd61adc330a40e8;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceNormal = IN.WorldSpaceNormal;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceTangent = IN.WorldSpaceTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.uv0 = IN.uv0;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.TimeParameters = IN.TimeParameters;
                float3 _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(_Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0, _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0, _Property_5beac3890650409fa717a2b959879df4_Out_0, IN.WorldSpacePosition, _GrassWave_861c999f8d524dc08fd61adc330a40e8, _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1);
                description.Position = _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
            {
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                return surface;
            }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.WorldSpaceTangent =                          TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent =                       normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent =                        TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition =                        input.positionOS;
                output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                output.uv0 =                                        input.uv0;
                output.TimeParameters =                             _TimeParameters.xyz;
            
                return output;
            }
            
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
            #define SCENESELECTIONPASS 1
            #define ALPHA_CLIP_THRESHOLD 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 WorldSpaceTangent;
                 float3 ObjectSpaceBiTangent;
                 float3 WorldSpaceBiTangent;
                 float3 ObjectSpacePosition;
                 float3 WorldSpacePosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
        PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTexture_TexelSize;
            half _WindShiftStrength;
            half _WindSpeed;
            half _WindStrength;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void TriangleWave_float(float In, out float Out)
            {
                Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            struct Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float
            {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            half4 uv0;
            float3 TimeParameters;
            };
            
            void SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(float _WindShiftStrength, float _WindSpeed, float _WindStrength, float3 _Position, Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float IN, out float3 Out_Vector4_1)
            {
            float3 _Property_ba69af3795ca452485fcfe9cc304b675_Out_0 = _Position;
            float _Split_3de17e256df54a5b841367501dc105e0_R_1 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[0];
            float _Split_3de17e256df54a5b841367501dc105e0_G_2 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[1];
            float _Split_3de17e256df54a5b841367501dc105e0_B_3 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[2];
            float _Split_3de17e256df54a5b841367501dc105e0_A_4 = 0;
            float _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2;
            Unity_SimpleNoise_float((_Property_ba69af3795ca452485fcfe9cc304b675_Out_0.xy), 500, _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2);
            float _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0 = _WindShiftStrength;
            float _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2;
            Unity_Multiply_float_float(_SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2, _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0, _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2);
            float _Property_c83311d520c04d448c73e13e9052b2cc_Out_0 = _WindSpeed;
            float _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c83311d520c04d448c73e13e9052b2cc_Out_0, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2);
            float _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2;
            Unity_Add_float(_Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2, _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2);
            float _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1;
            TriangleWave_float(_Add_3d041f187ef34d55a625c5bc1d943b79_Out_2, _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1);
            float _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0 = _WindStrength;
            float _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2;
            Unity_Multiply_float_float(_TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1, _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0, _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2);
            float _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2;
            Unity_Add_float(_Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2, _Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2);
            float4 _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0 = IN.uv0;
            float _Split_4ae5fe99a45d499bb8995259f1e45171_R_1 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[0];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_G_2 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[1];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_B_3 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[2];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_A_4 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[3];
            float _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3;
            Unity_Lerp_float(_Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2, _Split_4ae5fe99a45d499bb8995259f1e45171_G_2, _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3);
            float4 _Combine_f2511984976342d49af4e53718bb5361_RGBA_4;
            float3 _Combine_f2511984976342d49af4e53718bb5361_RGB_5;
            float2 _Combine_f2511984976342d49af4e53718bb5361_RG_6;
            Unity_Combine_float(_Lerp_dadcef85ff3d409d99e21489893493ac_Out_3, _Split_3de17e256df54a5b841367501dc105e0_G_2, _Split_3de17e256df54a5b841367501dc105e0_B_3, 0, _Combine_f2511984976342d49af4e53718bb5361_RGBA_4, _Combine_f2511984976342d49af4e53718bb5361_RGB_5, _Combine_f2511984976342d49af4e53718bb5361_RG_6);
            float3 _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1 = TransformWorldToObject(_Combine_f2511984976342d49af4e53718bb5361_RGB_5.xyz);
            Out_Vector4_1 = _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1;
            }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
            {
                float3 Position;
                half3 Normal;
                half3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                half _Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0 = _WindShiftStrength;
                half _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0 = _WindSpeed;
                half _Property_5beac3890650409fa717a2b959879df4_Out_0 = _WindStrength;
                Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float _GrassWave_861c999f8d524dc08fd61adc330a40e8;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceNormal = IN.WorldSpaceNormal;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceTangent = IN.WorldSpaceTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.uv0 = IN.uv0;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.TimeParameters = IN.TimeParameters;
                float3 _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(_Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0, _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0, _Property_5beac3890650409fa717a2b959879df4_Out_0, IN.WorldSpacePosition, _GrassWave_861c999f8d524dc08fd61adc330a40e8, _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1);
                description.Position = _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
            {
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                return surface;
            }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.WorldSpaceTangent =                          TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent =                       normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent =                        TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition =                        input.positionOS;
                output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                output.uv0 =                                        input.uv0;
                output.TimeParameters =                             _TimeParameters.xyz;
            
                return output;
            }
            
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
            #define SCENEPICKINGPASS 1
            #define ALPHA_CLIP_THRESHOLD 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 WorldSpaceTangent;
                 float3 ObjectSpaceBiTangent;
                 float3 WorldSpaceBiTangent;
                 float3 ObjectSpacePosition;
                 float3 WorldSpacePosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
        PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTexture_TexelSize;
            half _WindShiftStrength;
            half _WindSpeed;
            half _WindStrength;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void TriangleWave_float(float In, out float Out)
            {
                Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            struct Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float
            {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            half4 uv0;
            float3 TimeParameters;
            };
            
            void SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(float _WindShiftStrength, float _WindSpeed, float _WindStrength, float3 _Position, Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float IN, out float3 Out_Vector4_1)
            {
            float3 _Property_ba69af3795ca452485fcfe9cc304b675_Out_0 = _Position;
            float _Split_3de17e256df54a5b841367501dc105e0_R_1 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[0];
            float _Split_3de17e256df54a5b841367501dc105e0_G_2 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[1];
            float _Split_3de17e256df54a5b841367501dc105e0_B_3 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[2];
            float _Split_3de17e256df54a5b841367501dc105e0_A_4 = 0;
            float _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2;
            Unity_SimpleNoise_float((_Property_ba69af3795ca452485fcfe9cc304b675_Out_0.xy), 500, _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2);
            float _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0 = _WindShiftStrength;
            float _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2;
            Unity_Multiply_float_float(_SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2, _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0, _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2);
            float _Property_c83311d520c04d448c73e13e9052b2cc_Out_0 = _WindSpeed;
            float _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c83311d520c04d448c73e13e9052b2cc_Out_0, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2);
            float _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2;
            Unity_Add_float(_Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2, _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2);
            float _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1;
            TriangleWave_float(_Add_3d041f187ef34d55a625c5bc1d943b79_Out_2, _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1);
            float _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0 = _WindStrength;
            float _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2;
            Unity_Multiply_float_float(_TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1, _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0, _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2);
            float _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2;
            Unity_Add_float(_Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2, _Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2);
            float4 _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0 = IN.uv0;
            float _Split_4ae5fe99a45d499bb8995259f1e45171_R_1 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[0];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_G_2 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[1];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_B_3 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[2];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_A_4 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[3];
            float _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3;
            Unity_Lerp_float(_Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2, _Split_4ae5fe99a45d499bb8995259f1e45171_G_2, _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3);
            float4 _Combine_f2511984976342d49af4e53718bb5361_RGBA_4;
            float3 _Combine_f2511984976342d49af4e53718bb5361_RGB_5;
            float2 _Combine_f2511984976342d49af4e53718bb5361_RG_6;
            Unity_Combine_float(_Lerp_dadcef85ff3d409d99e21489893493ac_Out_3, _Split_3de17e256df54a5b841367501dc105e0_G_2, _Split_3de17e256df54a5b841367501dc105e0_B_3, 0, _Combine_f2511984976342d49af4e53718bb5361_RGBA_4, _Combine_f2511984976342d49af4e53718bb5361_RGB_5, _Combine_f2511984976342d49af4e53718bb5361_RG_6);
            float3 _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1 = TransformWorldToObject(_Combine_f2511984976342d49af4e53718bb5361_RGB_5.xyz);
            Out_Vector4_1 = _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1;
            }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
            {
                float3 Position;
                half3 Normal;
                half3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                half _Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0 = _WindShiftStrength;
                half _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0 = _WindSpeed;
                half _Property_5beac3890650409fa717a2b959879df4_Out_0 = _WindStrength;
                Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float _GrassWave_861c999f8d524dc08fd61adc330a40e8;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceNormal = IN.WorldSpaceNormal;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceTangent = IN.WorldSpaceTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.uv0 = IN.uv0;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.TimeParameters = IN.TimeParameters;
                float3 _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(_Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0, _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0, _Property_5beac3890650409fa717a2b959879df4_Out_0, IN.WorldSpacePosition, _GrassWave_861c999f8d524dc08fd61adc330a40e8, _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1);
                description.Position = _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
            {
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                return surface;
            }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.WorldSpaceTangent =                          TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent =                       normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent =                        TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition =                        input.positionOS;
                output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                output.uv0 =                                        input.uv0;
                output.TimeParameters =                             _TimeParameters.xyz;
            
                return output;
            }
            
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Back
            ZTest LEqual
            ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma vertex vert
            #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 WorldSpaceTangent;
                 float3 ObjectSpaceBiTangent;
                 float3 WorldSpaceBiTangent;
                 float3 ObjectSpacePosition;
                 float3 WorldSpacePosition;
                 float4 uv0;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
        PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.normalWS = input.interp0.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTexture_TexelSize;
            half _WindShiftStrength;
            half _WindSpeed;
            half _WindStrength;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void TriangleWave_float(float In, out float Out)
            {
                Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            struct Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float
            {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            half4 uv0;
            float3 TimeParameters;
            };
            
            void SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(float _WindShiftStrength, float _WindSpeed, float _WindStrength, float3 _Position, Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float IN, out float3 Out_Vector4_1)
            {
            float3 _Property_ba69af3795ca452485fcfe9cc304b675_Out_0 = _Position;
            float _Split_3de17e256df54a5b841367501dc105e0_R_1 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[0];
            float _Split_3de17e256df54a5b841367501dc105e0_G_2 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[1];
            float _Split_3de17e256df54a5b841367501dc105e0_B_3 = _Property_ba69af3795ca452485fcfe9cc304b675_Out_0[2];
            float _Split_3de17e256df54a5b841367501dc105e0_A_4 = 0;
            float _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2;
            Unity_SimpleNoise_float((_Property_ba69af3795ca452485fcfe9cc304b675_Out_0.xy), 500, _SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2);
            float _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0 = _WindShiftStrength;
            float _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2;
            Unity_Multiply_float_float(_SimpleNoise_05e8a47f66d24bb79f9e5ef2adc96448_Out_2, _Property_bd89f8df2a784cadba7cc37504f0fb04_Out_0, _Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2);
            float _Property_c83311d520c04d448c73e13e9052b2cc_Out_0 = _WindSpeed;
            float _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_c83311d520c04d448c73e13e9052b2cc_Out_0, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2);
            float _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2;
            Unity_Add_float(_Multiply_f879927a9dd24ffa82441fb9f10ad49d_Out_2, _Multiply_8957747348924d0e80bf0c8c5cb30a59_Out_2, _Add_3d041f187ef34d55a625c5bc1d943b79_Out_2);
            float _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1;
            TriangleWave_float(_Add_3d041f187ef34d55a625c5bc1d943b79_Out_2, _TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1);
            float _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0 = _WindStrength;
            float _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2;
            Unity_Multiply_float_float(_TriangleWave_8ea476ed5bd446fb9658b130c3c01848_Out_1, _Property_a7f96a731ab64e138f19c3d885ab5587_Out_0, _Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2);
            float _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2;
            Unity_Add_float(_Multiply_4f52989d2a8b43c5a93936b69ab8cc45_Out_2, _Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2);
            float4 _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0 = IN.uv0;
            float _Split_4ae5fe99a45d499bb8995259f1e45171_R_1 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[0];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_G_2 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[1];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_B_3 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[2];
            float _Split_4ae5fe99a45d499bb8995259f1e45171_A_4 = _UV_c2cdd122f2ad4ba4ac64e95ad10d8e1d_Out_0[3];
            float _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3;
            Unity_Lerp_float(_Split_3de17e256df54a5b841367501dc105e0_R_1, _Add_0428035335454dd0a6e52c1b77b89fb9_Out_2, _Split_4ae5fe99a45d499bb8995259f1e45171_G_2, _Lerp_dadcef85ff3d409d99e21489893493ac_Out_3);
            float4 _Combine_f2511984976342d49af4e53718bb5361_RGBA_4;
            float3 _Combine_f2511984976342d49af4e53718bb5361_RGB_5;
            float2 _Combine_f2511984976342d49af4e53718bb5361_RG_6;
            Unity_Combine_float(_Lerp_dadcef85ff3d409d99e21489893493ac_Out_3, _Split_3de17e256df54a5b841367501dc105e0_G_2, _Split_3de17e256df54a5b841367501dc105e0_B_3, 0, _Combine_f2511984976342d49af4e53718bb5361_RGBA_4, _Combine_f2511984976342d49af4e53718bb5361_RGB_5, _Combine_f2511984976342d49af4e53718bb5361_RG_6);
            float3 _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1 = TransformWorldToObject(_Combine_f2511984976342d49af4e53718bb5361_RGB_5.xyz);
            Out_Vector4_1 = _Transform_96d876ce574b4ebba1767d22bb6b2f32_Out_1;
            }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
            {
                float3 Position;
                half3 Normal;
                half3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                half _Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0 = _WindShiftStrength;
                half _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0 = _WindSpeed;
                half _Property_5beac3890650409fa717a2b959879df4_Out_0 = _WindStrength;
                Bindings_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float _GrassWave_861c999f8d524dc08fd61adc330a40e8;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceNormal = IN.WorldSpaceNormal;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceTangent = IN.WorldSpaceTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.uv0 = IN.uv0;
                _GrassWave_861c999f8d524dc08fd61adc330a40e8.TimeParameters = IN.TimeParameters;
                float3 _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                SG_GrassWave_c2cc4196f4434434dae9ddcb31fc8ace_float(_Property_28ab1ee8d6c94dc9a2d9b6201bce50ee_Out_0, _Property_a238b050f7664487b0e5fa57427e0c9f_Out_0, _Property_5beac3890650409fa717a2b959879df4_Out_0, IN.WorldSpacePosition, _GrassWave_861c999f8d524dc08fd61adc330a40e8, _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1);
                description.Position = _GrassWave_861c999f8d524dc08fd61adc330a40e8_OutVector4_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
            {
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                return surface;
            }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.WorldSpaceTangent =                          TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ObjectSpaceBiTangent =                       normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent =                        TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ObjectSpacePosition =                        input.positionOS;
                output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                output.uv0 =                                        input.uv0;
                output.TimeParameters =                             _TimeParameters.xyz;
            
                return output;
            }
            
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}