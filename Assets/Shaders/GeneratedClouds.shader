Shader "Clouds Generated"
    {
        Properties
        {
            Vector4_307253f41ce3471a9e32193ed515a9b1("Rotate Projection", Vector) = (1, 0, 0, 0)
            Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c("Noise Scale", Float) = 10
            Vector1_e76200de1bcf42ceaca17b7f4712245f("Noise Speed", Float) = 0.1
            Vector1_4fc9da11b7b64a4db817b811a850eec6("Noise Height", Float) = 1
            Vector4_42a64ed88b43416c802d07314788b002("Noise Remap", Vector) = (0, 1, -1, 1)
            Color_949c8f2e341b4a78a4c352b0dbf12e4d("Color Peak", Color) = (1, 1, 1, 0)
            Color_64461c265c3d4842ad56ae75d5885d94("Color Valley", Color) = (0, 0, 0, 0)
            Vector1_4a75c1cc02254de8bbcc546e9ff433cc("Noise Edge 1", Float) = 0
            Vector1_3320e339815442fb8fc145207ee548e5("Noise Edge 2", Float) = 1
            Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01("Noise Power", Float) = 2
            Vector1_297cd5d5d7434306aae6cc29794d9b01("Base Scale", Float) = 5
            Vector1_47bb49f0812542fb803d068d5ed05d83("Base Speed", Float) = 0.2
            Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7("Base Strength", Float) = 2
            Vector1_7adeb95c69a94315acd791a690dbb705("Emission Strength", Float) = 1
            Vector1_c967cd99c2774f6e89253a44a0516010("Curvature Radius", Float) = 1
            Vector1_b77f19661c5d4522a944e55d987c67e7("Fresnel Power", Float) = 1
            Vector1_c282f301bcd14b18915b5e00456c0961("Fresnel Opacity", Float) = 1
            Vector1_02911973b4034ae5afcb09f063c1d343("Fade Depth", Float) = 100
            [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Transparent"
                "UniversalMaterialType" = "Unlit"
                "Queue"="Transparent"
            }
            Pass
            {
                Name "Pass"
                Tags
                {
                    // LightMode: <None>
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
    
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
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma shader_feature _ _SAMPLE_GI
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_UNLIT
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
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
                    float3 WorldSpaceNormal;
                    float3 WorldSpaceViewDirection;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float3 WorldSpacePosition;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float3 interp2 : TEXCOORD2;
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
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyz =  input.viewDirectionWS;
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
                    output.viewDirectionWS = input.interp2.xyz;
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
                float4 Vector4_307253f41ce3471a9e32193ed515a9b1;
                float Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                float Vector1_e76200de1bcf42ceaca17b7f4712245f;
                float Vector1_4fc9da11b7b64a4db817b811a850eec6;
                float4 Vector4_42a64ed88b43416c802d07314788b002;
                float4 Color_949c8f2e341b4a78a4c352b0dbf12e4d;
                float4 Color_64461c265c3d4842ad56ae75d5885d94;
                float Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                float Vector1_3320e339815442fb8fc145207ee548e5;
                float Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                float Vector1_297cd5d5d7434306aae6cc29794d9b01;
                float Vector1_47bb49f0812542fb803d068d5ed05d83;
                float Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                float Vector1_7adeb95c69a94315acd791a690dbb705;
                float Vector1_c967cd99c2774f6e89253a44a0516010;
                float Vector1_b77f19661c5d4522a944e55d987c67e7;
                float Vector1_c282f301bcd14b18915b5e00456c0961;
                float Vector1_02911973b4034ae5afcb09f063c1d343;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                    
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
                }
                
                void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                {
                    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2);
                    float _Property_b66e0a1ea32e411bb105aa58ab9c06b7_Out_0 = Vector1_c967cd99c2774f6e89253a44a0516010;
                    float _Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2;
                    Unity_Divide_float(_Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2, _Property_b66e0a1ea32e411bb105aa58ab9c06b7_Out_0, _Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2);
                    float _Power_be9fd859711a4a8a8691631496d671de_Out_2;
                    Unity_Power_float(_Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2, 3, _Power_be9fd859711a4a8a8691631496d671de_Out_2);
                    float3 _Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2;
                    Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_be9fd859711a4a8a8691631496d671de_Out_2.xxx), _Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2);
                    float _Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0 = Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                    float _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0 = Vector1_3320e339815442fb8fc145207ee548e5;
                    float4 _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0 = Vector4_307253f41ce3471a9e32193ed515a9b1;
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_R_1 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[0];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_G_2 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[1];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_B_3 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[2];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[3];
                    float3 _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0.xyz), _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4, _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3);
                    float _Property_373e2111852f404994ed7c8ebb8995a9_Out_0 = Vector1_e76200de1bcf42ceaca17b7f4712245f;
                    float _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_373e2111852f404994ed7c8ebb8995a9_Out_0, _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2);
                    float2 _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2.xx), _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3);
                    float _Property_972ed22572de4446a08c83a4d841beea_Out_0 = Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                    float _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2);
                    float2 _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3);
                    float _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2);
                    float _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2;
                    Unity_Add_float(_GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2, _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2);
                    float _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2;
                    Unity_Divide_float(_Add_8c0a208aa9424feb813fac3884e17e4a_Out_2, 2, _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2);
                    float _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1;
                    Unity_Saturate_float(_Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2, _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1);
                    float _Property_67dec6538a7c46babb0f2249890cd010_Out_0 = Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                    float _Power_15b0c1780b91432cac6da17de088dbc8_Out_2;
                    Unity_Power_float(_Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1, _Property_67dec6538a7c46babb0f2249890cd010_Out_0, _Power_15b0c1780b91432cac6da17de088dbc8_Out_2);
                    float4 _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0 = Vector4_42a64ed88b43416c802d07314788b002;
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[0];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[1];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[2];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[3];
                    float4 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4;
                    float3 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5;
                    float2 _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1, _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2, 0, 0, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6);
                    float4 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4;
                    float3 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5;
                    float2 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3, _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4, 0, 0, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6);
                    float _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3;
                    Unity_Remap_float(_Power_15b0c1780b91432cac6da17de088dbc8_Out_2, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6, _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3);
                    float _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1;
                    Unity_Absolute_float(_Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1);
                    float _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3;
                    Unity_Smoothstep_float(_Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0, _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1, _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3);
                    float _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0 = Vector1_47bb49f0812542fb803d068d5ed05d83;
                    float _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0, _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2);
                    float2 _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2.xx), _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3);
                    float _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0 = Vector1_297cd5d5d7434306aae6cc29794d9b01;
                    float _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3, _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0, _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2);
                    float _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0 = Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                    float _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2;
                    Unity_Multiply_float(_GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2);
                    float _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2;
                    Unity_Add_float(_Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2, _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2);
                    float _Add_93b9b2112ec84c499475520eaa625333_Out_2;
                    Unity_Add_float(0, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Add_93b9b2112ec84c499475520eaa625333_Out_2);
                    float _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2;
                    Unity_Divide_float(_Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2, _Add_93b9b2112ec84c499475520eaa625333_Out_2, _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2);
                    float3 _Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2;
                    Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2.xxx), _Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2);
                    float _Property_0e31dc2a6f754c85aadcf176d4a7a4b9_Out_0 = Vector1_4fc9da11b7b64a4db817b811a850eec6;
                    float3 _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2;
                    Unity_Multiply_float(_Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2, (_Property_0e31dc2a6f754c85aadcf176d4a7a4b9_Out_0.xxx), _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2);
                    float3 _Add_a405210da624459eaf7e6d5571273445_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2, _Add_a405210da624459eaf7e6d5571273445_Out_2);
                    float3 _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2;
                    Unity_Add_float3(_Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2, _Add_a405210da624459eaf7e6d5571273445_Out_2, _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2);
                    description.Position = _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_67eda970913a4d3eab9af6fb9a21a002_Out_0 = Color_64461c265c3d4842ad56ae75d5885d94;
                    float4 _Property_cd7473bef5e34a219a6509b9626addac_Out_0 = Color_949c8f2e341b4a78a4c352b0dbf12e4d;
                    float _Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0 = Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                    float _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0 = Vector1_3320e339815442fb8fc145207ee548e5;
                    float4 _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0 = Vector4_307253f41ce3471a9e32193ed515a9b1;
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_R_1 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[0];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_G_2 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[1];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_B_3 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[2];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[3];
                    float3 _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0.xyz), _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4, _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3);
                    float _Property_373e2111852f404994ed7c8ebb8995a9_Out_0 = Vector1_e76200de1bcf42ceaca17b7f4712245f;
                    float _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_373e2111852f404994ed7c8ebb8995a9_Out_0, _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2);
                    float2 _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2.xx), _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3);
                    float _Property_972ed22572de4446a08c83a4d841beea_Out_0 = Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                    float _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2);
                    float2 _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3);
                    float _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2);
                    float _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2;
                    Unity_Add_float(_GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2, _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2);
                    float _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2;
                    Unity_Divide_float(_Add_8c0a208aa9424feb813fac3884e17e4a_Out_2, 2, _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2);
                    float _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1;
                    Unity_Saturate_float(_Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2, _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1);
                    float _Property_67dec6538a7c46babb0f2249890cd010_Out_0 = Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                    float _Power_15b0c1780b91432cac6da17de088dbc8_Out_2;
                    Unity_Power_float(_Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1, _Property_67dec6538a7c46babb0f2249890cd010_Out_0, _Power_15b0c1780b91432cac6da17de088dbc8_Out_2);
                    float4 _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0 = Vector4_42a64ed88b43416c802d07314788b002;
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[0];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[1];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[2];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[3];
                    float4 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4;
                    float3 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5;
                    float2 _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1, _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2, 0, 0, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6);
                    float4 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4;
                    float3 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5;
                    float2 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3, _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4, 0, 0, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6);
                    float _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3;
                    Unity_Remap_float(_Power_15b0c1780b91432cac6da17de088dbc8_Out_2, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6, _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3);
                    float _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1;
                    Unity_Absolute_float(_Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1);
                    float _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3;
                    Unity_Smoothstep_float(_Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0, _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1, _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3);
                    float _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0 = Vector1_47bb49f0812542fb803d068d5ed05d83;
                    float _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0, _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2);
                    float2 _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2.xx), _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3);
                    float _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0 = Vector1_297cd5d5d7434306aae6cc29794d9b01;
                    float _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3, _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0, _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2);
                    float _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0 = Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                    float _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2;
                    Unity_Multiply_float(_GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2);
                    float _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2;
                    Unity_Add_float(_Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2, _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2);
                    float _Add_93b9b2112ec84c499475520eaa625333_Out_2;
                    Unity_Add_float(0, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Add_93b9b2112ec84c499475520eaa625333_Out_2);
                    float _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2;
                    Unity_Divide_float(_Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2, _Add_93b9b2112ec84c499475520eaa625333_Out_2, _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2);
                    float4 _Lerp_078e16e03c784c639aa7360b31190d1b_Out_3;
                    Unity_Lerp_float4(_Property_67eda970913a4d3eab9af6fb9a21a002_Out_0, _Property_cd7473bef5e34a219a6509b9626addac_Out_0, (_Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2.xxxx), _Lerp_078e16e03c784c639aa7360b31190d1b_Out_3);
                    float _Property_2d143cb5fc644dd9a6af46b5a30a4e27_Out_0 = Vector1_7adeb95c69a94315acd791a690dbb705;
                    float4 _Multiply_a85a22ebcc0d44dfb65570c78ffa2095_Out_2;
                    Unity_Multiply_float(_Lerp_078e16e03c784c639aa7360b31190d1b_Out_3, (_Property_2d143cb5fc644dd9a6af46b5a30a4e27_Out_0.xxxx), _Multiply_a85a22ebcc0d44dfb65570c78ffa2095_Out_2);
                    float _Property_0b7d530bf8f24d279c253199c00e0be0_Out_0 = Vector1_b77f19661c5d4522a944e55d987c67e7;
                    float _FresnelEffect_933493e83ccd43f8a3630fa4e607ed91_Out_3;
                    Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_0b7d530bf8f24d279c253199c00e0be0_Out_0, _FresnelEffect_933493e83ccd43f8a3630fa4e607ed91_Out_3);
                    float _Multiply_d18f765b7a6c4a128f27a6cc2792e3cc_Out_2;
                    Unity_Multiply_float(_Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2, _FresnelEffect_933493e83ccd43f8a3630fa4e607ed91_Out_3, _Multiply_d18f765b7a6c4a128f27a6cc2792e3cc_Out_2);
                    float _Property_2dd108d0549f48b4bb8d4acac5bd98ed_Out_0 = Vector1_c282f301bcd14b18915b5e00456c0961;
                    float _Multiply_75da6b7d9dbd49eca6f12d08b2ccbd0b_Out_2;
                    Unity_Multiply_float(_Multiply_d18f765b7a6c4a128f27a6cc2792e3cc_Out_2, _Property_2dd108d0549f48b4bb8d4acac5bd98ed_Out_0, _Multiply_75da6b7d9dbd49eca6f12d08b2ccbd0b_Out_2);
                    float4 _Add_d01dde9f480140d988faff6606566375_Out_2;
                    Unity_Add_float4(_Multiply_a85a22ebcc0d44dfb65570c78ffa2095_Out_2, (_Multiply_75da6b7d9dbd49eca6f12d08b2ccbd0b_Out_2.xxxx), _Add_d01dde9f480140d988faff6606566375_Out_2);
                    float _SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1);
                    float4 _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0 = IN.ScreenPosition;
                    float _Split_81145428320848b38c0179b335a6d364_R_1 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[0];
                    float _Split_81145428320848b38c0179b335a6d364_G_2 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[1];
                    float _Split_81145428320848b38c0179b335a6d364_B_3 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[2];
                    float _Split_81145428320848b38c0179b335a6d364_A_4 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[3];
                    float _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2;
                    Unity_Subtract_float(_Split_81145428320848b38c0179b335a6d364_A_4, 1, _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2);
                    float _Subtract_a7154844e80244d5953191d1982ec5ed_Out_2;
                    Unity_Subtract_float(_SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1, _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2, _Subtract_a7154844e80244d5953191d1982ec5ed_Out_2);
                    float _Property_42ff734ae1974c348205157ec49d927b_Out_0 = Vector1_02911973b4034ae5afcb09f063c1d343;
                    float _Divide_e396f840dddd4b0bb61838598aa08344_Out_2;
                    Unity_Divide_float(_Subtract_a7154844e80244d5953191d1982ec5ed_Out_2, _Property_42ff734ae1974c348205157ec49d927b_Out_0, _Divide_e396f840dddd4b0bb61838598aa08344_Out_2);
                    float _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1;
                    Unity_Saturate_float(_Divide_e396f840dddd4b0bb61838598aa08344_Out_2, _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1);
                    float _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3;
                    Unity_Smoothstep_float(0, 1, _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1, _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3);
                    surface.BaseColor = (_Add_d01dde9f480140d988faff6606566375_Out_2.xyz);
                    surface.Alpha = _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                
                
                    output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_SHADOWCASTER
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
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
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float3 WorldSpacePosition;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
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
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
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
                float4 Vector4_307253f41ce3471a9e32193ed515a9b1;
                float Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                float Vector1_e76200de1bcf42ceaca17b7f4712245f;
                float Vector1_4fc9da11b7b64a4db817b811a850eec6;
                float4 Vector4_42a64ed88b43416c802d07314788b002;
                float4 Color_949c8f2e341b4a78a4c352b0dbf12e4d;
                float4 Color_64461c265c3d4842ad56ae75d5885d94;
                float Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                float Vector1_3320e339815442fb8fc145207ee548e5;
                float Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                float Vector1_297cd5d5d7434306aae6cc29794d9b01;
                float Vector1_47bb49f0812542fb803d068d5ed05d83;
                float Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                float Vector1_7adeb95c69a94315acd791a690dbb705;
                float Vector1_c967cd99c2774f6e89253a44a0516010;
                float Vector1_b77f19661c5d4522a944e55d987c67e7;
                float Vector1_c282f301bcd14b18915b5e00456c0961;
                float Vector1_02911973b4034ae5afcb09f063c1d343;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                    
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2);
                    float _Property_b66e0a1ea32e411bb105aa58ab9c06b7_Out_0 = Vector1_c967cd99c2774f6e89253a44a0516010;
                    float _Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2;
                    Unity_Divide_float(_Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2, _Property_b66e0a1ea32e411bb105aa58ab9c06b7_Out_0, _Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2);
                    float _Power_be9fd859711a4a8a8691631496d671de_Out_2;
                    Unity_Power_float(_Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2, 3, _Power_be9fd859711a4a8a8691631496d671de_Out_2);
                    float3 _Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2;
                    Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_be9fd859711a4a8a8691631496d671de_Out_2.xxx), _Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2);
                    float _Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0 = Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                    float _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0 = Vector1_3320e339815442fb8fc145207ee548e5;
                    float4 _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0 = Vector4_307253f41ce3471a9e32193ed515a9b1;
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_R_1 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[0];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_G_2 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[1];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_B_3 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[2];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[3];
                    float3 _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0.xyz), _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4, _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3);
                    float _Property_373e2111852f404994ed7c8ebb8995a9_Out_0 = Vector1_e76200de1bcf42ceaca17b7f4712245f;
                    float _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_373e2111852f404994ed7c8ebb8995a9_Out_0, _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2);
                    float2 _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2.xx), _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3);
                    float _Property_972ed22572de4446a08c83a4d841beea_Out_0 = Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                    float _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2);
                    float2 _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3);
                    float _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2);
                    float _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2;
                    Unity_Add_float(_GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2, _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2);
                    float _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2;
                    Unity_Divide_float(_Add_8c0a208aa9424feb813fac3884e17e4a_Out_2, 2, _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2);
                    float _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1;
                    Unity_Saturate_float(_Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2, _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1);
                    float _Property_67dec6538a7c46babb0f2249890cd010_Out_0 = Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                    float _Power_15b0c1780b91432cac6da17de088dbc8_Out_2;
                    Unity_Power_float(_Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1, _Property_67dec6538a7c46babb0f2249890cd010_Out_0, _Power_15b0c1780b91432cac6da17de088dbc8_Out_2);
                    float4 _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0 = Vector4_42a64ed88b43416c802d07314788b002;
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[0];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[1];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[2];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[3];
                    float4 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4;
                    float3 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5;
                    float2 _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1, _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2, 0, 0, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6);
                    float4 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4;
                    float3 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5;
                    float2 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3, _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4, 0, 0, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6);
                    float _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3;
                    Unity_Remap_float(_Power_15b0c1780b91432cac6da17de088dbc8_Out_2, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6, _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3);
                    float _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1;
                    Unity_Absolute_float(_Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1);
                    float _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3;
                    Unity_Smoothstep_float(_Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0, _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1, _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3);
                    float _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0 = Vector1_47bb49f0812542fb803d068d5ed05d83;
                    float _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0, _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2);
                    float2 _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2.xx), _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3);
                    float _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0 = Vector1_297cd5d5d7434306aae6cc29794d9b01;
                    float _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3, _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0, _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2);
                    float _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0 = Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                    float _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2;
                    Unity_Multiply_float(_GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2);
                    float _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2;
                    Unity_Add_float(_Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2, _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2);
                    float _Add_93b9b2112ec84c499475520eaa625333_Out_2;
                    Unity_Add_float(0, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Add_93b9b2112ec84c499475520eaa625333_Out_2);
                    float _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2;
                    Unity_Divide_float(_Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2, _Add_93b9b2112ec84c499475520eaa625333_Out_2, _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2);
                    float3 _Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2;
                    Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2.xxx), _Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2);
                    float _Property_0e31dc2a6f754c85aadcf176d4a7a4b9_Out_0 = Vector1_4fc9da11b7b64a4db817b811a850eec6;
                    float3 _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2;
                    Unity_Multiply_float(_Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2, (_Property_0e31dc2a6f754c85aadcf176d4a7a4b9_Out_0.xxx), _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2);
                    float3 _Add_a405210da624459eaf7e6d5571273445_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2, _Add_a405210da624459eaf7e6d5571273445_Out_2);
                    float3 _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2;
                    Unity_Add_float3(_Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2, _Add_a405210da624459eaf7e6d5571273445_Out_2, _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2);
                    description.Position = _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1);
                    float4 _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0 = IN.ScreenPosition;
                    float _Split_81145428320848b38c0179b335a6d364_R_1 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[0];
                    float _Split_81145428320848b38c0179b335a6d364_G_2 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[1];
                    float _Split_81145428320848b38c0179b335a6d364_B_3 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[2];
                    float _Split_81145428320848b38c0179b335a6d364_A_4 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[3];
                    float _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2;
                    Unity_Subtract_float(_Split_81145428320848b38c0179b335a6d364_A_4, 1, _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2);
                    float _Subtract_a7154844e80244d5953191d1982ec5ed_Out_2;
                    Unity_Subtract_float(_SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1, _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2, _Subtract_a7154844e80244d5953191d1982ec5ed_Out_2);
                    float _Property_42ff734ae1974c348205157ec49d927b_Out_0 = Vector1_02911973b4034ae5afcb09f063c1d343;
                    float _Divide_e396f840dddd4b0bb61838598aa08344_Out_2;
                    Unity_Divide_float(_Subtract_a7154844e80244d5953191d1982ec5ed_Out_2, _Property_42ff734ae1974c348205157ec49d927b_Out_0, _Divide_e396f840dddd4b0bb61838598aa08344_Out_2);
                    float _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1;
                    Unity_Saturate_float(_Divide_e396f840dddd4b0bb61838598aa08344_Out_2, _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1);
                    float _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3;
                    Unity_Smoothstep_float(0, 1, _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1, _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3);
                    surface.Alpha = _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
    
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
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHONLY
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
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
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float3 WorldSpacePosition;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
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
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
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
                float4 Vector4_307253f41ce3471a9e32193ed515a9b1;
                float Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                float Vector1_e76200de1bcf42ceaca17b7f4712245f;
                float Vector1_4fc9da11b7b64a4db817b811a850eec6;
                float4 Vector4_42a64ed88b43416c802d07314788b002;
                float4 Color_949c8f2e341b4a78a4c352b0dbf12e4d;
                float4 Color_64461c265c3d4842ad56ae75d5885d94;
                float Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                float Vector1_3320e339815442fb8fc145207ee548e5;
                float Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                float Vector1_297cd5d5d7434306aae6cc29794d9b01;
                float Vector1_47bb49f0812542fb803d068d5ed05d83;
                float Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                float Vector1_7adeb95c69a94315acd791a690dbb705;
                float Vector1_c967cd99c2774f6e89253a44a0516010;
                float Vector1_b77f19661c5d4522a944e55d987c67e7;
                float Vector1_c282f301bcd14b18915b5e00456c0961;
                float Vector1_02911973b4034ae5afcb09f063c1d343;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                    
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2);
                    float _Property_b66e0a1ea32e411bb105aa58ab9c06b7_Out_0 = Vector1_c967cd99c2774f6e89253a44a0516010;
                    float _Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2;
                    Unity_Divide_float(_Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2, _Property_b66e0a1ea32e411bb105aa58ab9c06b7_Out_0, _Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2);
                    float _Power_be9fd859711a4a8a8691631496d671de_Out_2;
                    Unity_Power_float(_Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2, 3, _Power_be9fd859711a4a8a8691631496d671de_Out_2);
                    float3 _Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2;
                    Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_be9fd859711a4a8a8691631496d671de_Out_2.xxx), _Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2);
                    float _Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0 = Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                    float _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0 = Vector1_3320e339815442fb8fc145207ee548e5;
                    float4 _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0 = Vector4_307253f41ce3471a9e32193ed515a9b1;
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_R_1 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[0];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_G_2 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[1];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_B_3 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[2];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[3];
                    float3 _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0.xyz), _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4, _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3);
                    float _Property_373e2111852f404994ed7c8ebb8995a9_Out_0 = Vector1_e76200de1bcf42ceaca17b7f4712245f;
                    float _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_373e2111852f404994ed7c8ebb8995a9_Out_0, _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2);
                    float2 _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2.xx), _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3);
                    float _Property_972ed22572de4446a08c83a4d841beea_Out_0 = Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                    float _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2);
                    float2 _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3);
                    float _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2);
                    float _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2;
                    Unity_Add_float(_GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2, _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2);
                    float _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2;
                    Unity_Divide_float(_Add_8c0a208aa9424feb813fac3884e17e4a_Out_2, 2, _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2);
                    float _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1;
                    Unity_Saturate_float(_Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2, _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1);
                    float _Property_67dec6538a7c46babb0f2249890cd010_Out_0 = Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                    float _Power_15b0c1780b91432cac6da17de088dbc8_Out_2;
                    Unity_Power_float(_Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1, _Property_67dec6538a7c46babb0f2249890cd010_Out_0, _Power_15b0c1780b91432cac6da17de088dbc8_Out_2);
                    float4 _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0 = Vector4_42a64ed88b43416c802d07314788b002;
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[0];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[1];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[2];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[3];
                    float4 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4;
                    float3 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5;
                    float2 _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1, _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2, 0, 0, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6);
                    float4 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4;
                    float3 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5;
                    float2 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3, _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4, 0, 0, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6);
                    float _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3;
                    Unity_Remap_float(_Power_15b0c1780b91432cac6da17de088dbc8_Out_2, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6, _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3);
                    float _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1;
                    Unity_Absolute_float(_Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1);
                    float _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3;
                    Unity_Smoothstep_float(_Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0, _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1, _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3);
                    float _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0 = Vector1_47bb49f0812542fb803d068d5ed05d83;
                    float _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0, _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2);
                    float2 _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2.xx), _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3);
                    float _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0 = Vector1_297cd5d5d7434306aae6cc29794d9b01;
                    float _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3, _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0, _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2);
                    float _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0 = Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                    float _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2;
                    Unity_Multiply_float(_GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2);
                    float _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2;
                    Unity_Add_float(_Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2, _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2);
                    float _Add_93b9b2112ec84c499475520eaa625333_Out_2;
                    Unity_Add_float(0, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Add_93b9b2112ec84c499475520eaa625333_Out_2);
                    float _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2;
                    Unity_Divide_float(_Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2, _Add_93b9b2112ec84c499475520eaa625333_Out_2, _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2);
                    float3 _Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2;
                    Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2.xxx), _Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2);
                    float _Property_0e31dc2a6f754c85aadcf176d4a7a4b9_Out_0 = Vector1_4fc9da11b7b64a4db817b811a850eec6;
                    float3 _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2;
                    Unity_Multiply_float(_Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2, (_Property_0e31dc2a6f754c85aadcf176d4a7a4b9_Out_0.xxx), _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2);
                    float3 _Add_a405210da624459eaf7e6d5571273445_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2, _Add_a405210da624459eaf7e6d5571273445_Out_2);
                    float3 _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2;
                    Unity_Add_float3(_Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2, _Add_a405210da624459eaf7e6d5571273445_Out_2, _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2);
                    description.Position = _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1);
                    float4 _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0 = IN.ScreenPosition;
                    float _Split_81145428320848b38c0179b335a6d364_R_1 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[0];
                    float _Split_81145428320848b38c0179b335a6d364_G_2 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[1];
                    float _Split_81145428320848b38c0179b335a6d364_B_3 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[2];
                    float _Split_81145428320848b38c0179b335a6d364_A_4 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[3];
                    float _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2;
                    Unity_Subtract_float(_Split_81145428320848b38c0179b335a6d364_A_4, 1, _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2);
                    float _Subtract_a7154844e80244d5953191d1982ec5ed_Out_2;
                    Unity_Subtract_float(_SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1, _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2, _Subtract_a7154844e80244d5953191d1982ec5ed_Out_2);
                    float _Property_42ff734ae1974c348205157ec49d927b_Out_0 = Vector1_02911973b4034ae5afcb09f063c1d343;
                    float _Divide_e396f840dddd4b0bb61838598aa08344_Out_2;
                    Unity_Divide_float(_Subtract_a7154844e80244d5953191d1982ec5ed_Out_2, _Property_42ff734ae1974c348205157ec49d927b_Out_0, _Divide_e396f840dddd4b0bb61838598aa08344_Out_2);
                    float _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1;
                    Unity_Saturate_float(_Divide_e396f840dddd4b0bb61838598aa08344_Out_2, _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1);
                    float _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3;
                    Unity_Smoothstep_float(0, 1, _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1, _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3);
                    surface.Alpha = _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
    
                ENDHLSL
            }
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Transparent"
                "UniversalMaterialType" = "Unlit"
                "Queue"="Transparent"
            }
            Pass
            {
                Name "Pass"
                Tags
                {
                    // LightMode: <None>
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                // ZWrite Off
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
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma shader_feature _ _SAMPLE_GI
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_UNLIT
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
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
                    float3 WorldSpaceNormal;
                    float3 WorldSpaceViewDirection;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float3 WorldSpacePosition;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float3 interp2 : TEXCOORD2;
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
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyz =  input.viewDirectionWS;
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
                    output.viewDirectionWS = input.interp2.xyz;
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
                float4 Vector4_307253f41ce3471a9e32193ed515a9b1;
                float Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                float Vector1_e76200de1bcf42ceaca17b7f4712245f;
                float Vector1_4fc9da11b7b64a4db817b811a850eec6;
                float4 Vector4_42a64ed88b43416c802d07314788b002;
                float4 Color_949c8f2e341b4a78a4c352b0dbf12e4d;
                float4 Color_64461c265c3d4842ad56ae75d5885d94;
                float Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                float Vector1_3320e339815442fb8fc145207ee548e5;
                float Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                float Vector1_297cd5d5d7434306aae6cc29794d9b01;
                float Vector1_47bb49f0812542fb803d068d5ed05d83;
                float Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                float Vector1_7adeb95c69a94315acd791a690dbb705;
                float Vector1_c967cd99c2774f6e89253a44a0516010;
                float Vector1_b77f19661c5d4522a944e55d987c67e7;
                float Vector1_c282f301bcd14b18915b5e00456c0961;
                float Vector1_02911973b4034ae5afcb09f063c1d343;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                    
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
                }
                
                void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                {
                    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2);
                    float _Property_b66e0a1ea32e411bb105aa58ab9c06b7_Out_0 = Vector1_c967cd99c2774f6e89253a44a0516010;
                    float _Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2;
                    Unity_Divide_float(_Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2, _Property_b66e0a1ea32e411bb105aa58ab9c06b7_Out_0, _Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2);
                    float _Power_be9fd859711a4a8a8691631496d671de_Out_2;
                    Unity_Power_float(_Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2, 3, _Power_be9fd859711a4a8a8691631496d671de_Out_2);
                    float3 _Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2;
                    Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_be9fd859711a4a8a8691631496d671de_Out_2.xxx), _Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2);
                    float _Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0 = Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                    float _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0 = Vector1_3320e339815442fb8fc145207ee548e5;
                    float4 _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0 = Vector4_307253f41ce3471a9e32193ed515a9b1;
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_R_1 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[0];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_G_2 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[1];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_B_3 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[2];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[3];
                    float3 _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0.xyz), _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4, _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3);
                    float _Property_373e2111852f404994ed7c8ebb8995a9_Out_0 = Vector1_e76200de1bcf42ceaca17b7f4712245f;
                    float _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_373e2111852f404994ed7c8ebb8995a9_Out_0, _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2);
                    float2 _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2.xx), _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3);
                    float _Property_972ed22572de4446a08c83a4d841beea_Out_0 = Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                    float _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2);
                    float2 _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3);
                    float _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2);
                    float _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2;
                    Unity_Add_float(_GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2, _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2);
                    float _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2;
                    Unity_Divide_float(_Add_8c0a208aa9424feb813fac3884e17e4a_Out_2, 2, _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2);
                    float _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1;
                    Unity_Saturate_float(_Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2, _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1);
                    float _Property_67dec6538a7c46babb0f2249890cd010_Out_0 = Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                    float _Power_15b0c1780b91432cac6da17de088dbc8_Out_2;
                    Unity_Power_float(_Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1, _Property_67dec6538a7c46babb0f2249890cd010_Out_0, _Power_15b0c1780b91432cac6da17de088dbc8_Out_2);
                    float4 _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0 = Vector4_42a64ed88b43416c802d07314788b002;
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[0];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[1];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[2];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[3];
                    float4 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4;
                    float3 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5;
                    float2 _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1, _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2, 0, 0, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6);
                    float4 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4;
                    float3 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5;
                    float2 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3, _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4, 0, 0, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6);
                    float _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3;
                    Unity_Remap_float(_Power_15b0c1780b91432cac6da17de088dbc8_Out_2, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6, _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3);
                    float _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1;
                    Unity_Absolute_float(_Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1);
                    float _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3;
                    Unity_Smoothstep_float(_Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0, _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1, _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3);
                    float _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0 = Vector1_47bb49f0812542fb803d068d5ed05d83;
                    float _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0, _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2);
                    float2 _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2.xx), _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3);
                    float _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0 = Vector1_297cd5d5d7434306aae6cc29794d9b01;
                    float _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3, _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0, _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2);
                    float _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0 = Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                    float _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2;
                    Unity_Multiply_float(_GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2);
                    float _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2;
                    Unity_Add_float(_Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2, _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2);
                    float _Add_93b9b2112ec84c499475520eaa625333_Out_2;
                    Unity_Add_float(0, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Add_93b9b2112ec84c499475520eaa625333_Out_2);
                    float _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2;
                    Unity_Divide_float(_Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2, _Add_93b9b2112ec84c499475520eaa625333_Out_2, _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2);
                    float3 _Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2;
                    Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2.xxx), _Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2);
                    float _Property_0e31dc2a6f754c85aadcf176d4a7a4b9_Out_0 = Vector1_4fc9da11b7b64a4db817b811a850eec6;
                    float3 _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2;
                    Unity_Multiply_float(_Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2, (_Property_0e31dc2a6f754c85aadcf176d4a7a4b9_Out_0.xxx), _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2);
                    float3 _Add_a405210da624459eaf7e6d5571273445_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2, _Add_a405210da624459eaf7e6d5571273445_Out_2);
                    float3 _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2;
                    Unity_Add_float3(_Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2, _Add_a405210da624459eaf7e6d5571273445_Out_2, _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2);
                    description.Position = _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_67eda970913a4d3eab9af6fb9a21a002_Out_0 = Color_64461c265c3d4842ad56ae75d5885d94;
                    float4 _Property_cd7473bef5e34a219a6509b9626addac_Out_0 = Color_949c8f2e341b4a78a4c352b0dbf12e4d;
                    float _Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0 = Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                    float _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0 = Vector1_3320e339815442fb8fc145207ee548e5;
                    float4 _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0 = Vector4_307253f41ce3471a9e32193ed515a9b1;
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_R_1 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[0];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_G_2 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[1];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_B_3 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[2];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[3];
                    float3 _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0.xyz), _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4, _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3);
                    float _Property_373e2111852f404994ed7c8ebb8995a9_Out_0 = Vector1_e76200de1bcf42ceaca17b7f4712245f;
                    float _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_373e2111852f404994ed7c8ebb8995a9_Out_0, _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2);
                    float2 _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2.xx), _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3);
                    float _Property_972ed22572de4446a08c83a4d841beea_Out_0 = Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                    float _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2);
                    float2 _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3);
                    float _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2);
                    float _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2;
                    Unity_Add_float(_GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2, _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2);
                    float _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2;
                    Unity_Divide_float(_Add_8c0a208aa9424feb813fac3884e17e4a_Out_2, 2, _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2);
                    float _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1;
                    Unity_Saturate_float(_Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2, _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1);
                    float _Property_67dec6538a7c46babb0f2249890cd010_Out_0 = Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                    float _Power_15b0c1780b91432cac6da17de088dbc8_Out_2;
                    Unity_Power_float(_Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1, _Property_67dec6538a7c46babb0f2249890cd010_Out_0, _Power_15b0c1780b91432cac6da17de088dbc8_Out_2);
                    float4 _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0 = Vector4_42a64ed88b43416c802d07314788b002;
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[0];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[1];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[2];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[3];
                    float4 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4;
                    float3 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5;
                    float2 _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1, _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2, 0, 0, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6);
                    float4 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4;
                    float3 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5;
                    float2 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3, _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4, 0, 0, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6);
                    float _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3;
                    Unity_Remap_float(_Power_15b0c1780b91432cac6da17de088dbc8_Out_2, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6, _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3);
                    float _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1;
                    Unity_Absolute_float(_Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1);
                    float _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3;
                    Unity_Smoothstep_float(_Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0, _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1, _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3);
                    float _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0 = Vector1_47bb49f0812542fb803d068d5ed05d83;
                    float _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0, _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2);
                    float2 _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2.xx), _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3);
                    float _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0 = Vector1_297cd5d5d7434306aae6cc29794d9b01;
                    float _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3, _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0, _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2);
                    float _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0 = Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                    float _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2;
                    Unity_Multiply_float(_GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2);
                    float _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2;
                    Unity_Add_float(_Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2, _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2);
                    float _Add_93b9b2112ec84c499475520eaa625333_Out_2;
                    Unity_Add_float(0, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Add_93b9b2112ec84c499475520eaa625333_Out_2);
                    float _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2;
                    Unity_Divide_float(_Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2, _Add_93b9b2112ec84c499475520eaa625333_Out_2, _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2);
                    float4 _Lerp_078e16e03c784c639aa7360b31190d1b_Out_3;
                    Unity_Lerp_float4(_Property_67eda970913a4d3eab9af6fb9a21a002_Out_0, _Property_cd7473bef5e34a219a6509b9626addac_Out_0, (_Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2.xxxx), _Lerp_078e16e03c784c639aa7360b31190d1b_Out_3);
                    float _Property_2d143cb5fc644dd9a6af46b5a30a4e27_Out_0 = Vector1_7adeb95c69a94315acd791a690dbb705;
                    float4 _Multiply_a85a22ebcc0d44dfb65570c78ffa2095_Out_2;
                    Unity_Multiply_float(_Lerp_078e16e03c784c639aa7360b31190d1b_Out_3, (_Property_2d143cb5fc644dd9a6af46b5a30a4e27_Out_0.xxxx), _Multiply_a85a22ebcc0d44dfb65570c78ffa2095_Out_2);
                    float _Property_0b7d530bf8f24d279c253199c00e0be0_Out_0 = Vector1_b77f19661c5d4522a944e55d987c67e7;
                    float _FresnelEffect_933493e83ccd43f8a3630fa4e607ed91_Out_3;
                    Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_0b7d530bf8f24d279c253199c00e0be0_Out_0, _FresnelEffect_933493e83ccd43f8a3630fa4e607ed91_Out_3);
                    float _Multiply_d18f765b7a6c4a128f27a6cc2792e3cc_Out_2;
                    Unity_Multiply_float(_Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2, _FresnelEffect_933493e83ccd43f8a3630fa4e607ed91_Out_3, _Multiply_d18f765b7a6c4a128f27a6cc2792e3cc_Out_2);
                    float _Property_2dd108d0549f48b4bb8d4acac5bd98ed_Out_0 = Vector1_c282f301bcd14b18915b5e00456c0961;
                    float _Multiply_75da6b7d9dbd49eca6f12d08b2ccbd0b_Out_2;
                    Unity_Multiply_float(_Multiply_d18f765b7a6c4a128f27a6cc2792e3cc_Out_2, _Property_2dd108d0549f48b4bb8d4acac5bd98ed_Out_0, _Multiply_75da6b7d9dbd49eca6f12d08b2ccbd0b_Out_2);
                    float4 _Add_d01dde9f480140d988faff6606566375_Out_2;
                    Unity_Add_float4(_Multiply_a85a22ebcc0d44dfb65570c78ffa2095_Out_2, (_Multiply_75da6b7d9dbd49eca6f12d08b2ccbd0b_Out_2.xxxx), _Add_d01dde9f480140d988faff6606566375_Out_2);
                    float _SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1);
                    float4 _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0 = IN.ScreenPosition;
                    float _Split_81145428320848b38c0179b335a6d364_R_1 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[0];
                    float _Split_81145428320848b38c0179b335a6d364_G_2 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[1];
                    float _Split_81145428320848b38c0179b335a6d364_B_3 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[2];
                    float _Split_81145428320848b38c0179b335a6d364_A_4 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[3];
                    float _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2;
                    Unity_Subtract_float(_Split_81145428320848b38c0179b335a6d364_A_4, 1, _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2);
                    float _Subtract_a7154844e80244d5953191d1982ec5ed_Out_2;
                    Unity_Subtract_float(_SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1, _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2, _Subtract_a7154844e80244d5953191d1982ec5ed_Out_2);
                    float _Property_42ff734ae1974c348205157ec49d927b_Out_0 = Vector1_02911973b4034ae5afcb09f063c1d343;
                    float _Divide_e396f840dddd4b0bb61838598aa08344_Out_2;
                    Unity_Divide_float(_Subtract_a7154844e80244d5953191d1982ec5ed_Out_2, _Property_42ff734ae1974c348205157ec49d927b_Out_0, _Divide_e396f840dddd4b0bb61838598aa08344_Out_2);
                    float _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1;
                    Unity_Saturate_float(_Divide_e396f840dddd4b0bb61838598aa08344_Out_2, _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1);
                    float _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3;
                    Unity_Smoothstep_float(0, 1, _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1, _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3);
                    surface.BaseColor = (_Add_d01dde9f480140d988faff6606566375_Out_2.xyz);
                    surface.Alpha = _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                
                
                    output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_SHADOWCASTER
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
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
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float3 WorldSpacePosition;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
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
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
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
                float4 Vector4_307253f41ce3471a9e32193ed515a9b1;
                float Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                float Vector1_e76200de1bcf42ceaca17b7f4712245f;
                float Vector1_4fc9da11b7b64a4db817b811a850eec6;
                float4 Vector4_42a64ed88b43416c802d07314788b002;
                float4 Color_949c8f2e341b4a78a4c352b0dbf12e4d;
                float4 Color_64461c265c3d4842ad56ae75d5885d94;
                float Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                float Vector1_3320e339815442fb8fc145207ee548e5;
                float Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                float Vector1_297cd5d5d7434306aae6cc29794d9b01;
                float Vector1_47bb49f0812542fb803d068d5ed05d83;
                float Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                float Vector1_7adeb95c69a94315acd791a690dbb705;
                float Vector1_c967cd99c2774f6e89253a44a0516010;
                float Vector1_b77f19661c5d4522a944e55d987c67e7;
                float Vector1_c282f301bcd14b18915b5e00456c0961;
                float Vector1_02911973b4034ae5afcb09f063c1d343;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                    
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2);
                    float _Property_b66e0a1ea32e411bb105aa58ab9c06b7_Out_0 = Vector1_c967cd99c2774f6e89253a44a0516010;
                    float _Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2;
                    Unity_Divide_float(_Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2, _Property_b66e0a1ea32e411bb105aa58ab9c06b7_Out_0, _Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2);
                    float _Power_be9fd859711a4a8a8691631496d671de_Out_2;
                    Unity_Power_float(_Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2, 3, _Power_be9fd859711a4a8a8691631496d671de_Out_2);
                    float3 _Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2;
                    Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_be9fd859711a4a8a8691631496d671de_Out_2.xxx), _Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2);
                    float _Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0 = Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                    float _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0 = Vector1_3320e339815442fb8fc145207ee548e5;
                    float4 _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0 = Vector4_307253f41ce3471a9e32193ed515a9b1;
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_R_1 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[0];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_G_2 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[1];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_B_3 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[2];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[3];
                    float3 _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0.xyz), _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4, _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3);
                    float _Property_373e2111852f404994ed7c8ebb8995a9_Out_0 = Vector1_e76200de1bcf42ceaca17b7f4712245f;
                    float _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_373e2111852f404994ed7c8ebb8995a9_Out_0, _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2);
                    float2 _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2.xx), _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3);
                    float _Property_972ed22572de4446a08c83a4d841beea_Out_0 = Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                    float _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2);
                    float2 _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3);
                    float _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2);
                    float _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2;
                    Unity_Add_float(_GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2, _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2);
                    float _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2;
                    Unity_Divide_float(_Add_8c0a208aa9424feb813fac3884e17e4a_Out_2, 2, _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2);
                    float _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1;
                    Unity_Saturate_float(_Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2, _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1);
                    float _Property_67dec6538a7c46babb0f2249890cd010_Out_0 = Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                    float _Power_15b0c1780b91432cac6da17de088dbc8_Out_2;
                    Unity_Power_float(_Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1, _Property_67dec6538a7c46babb0f2249890cd010_Out_0, _Power_15b0c1780b91432cac6da17de088dbc8_Out_2);
                    float4 _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0 = Vector4_42a64ed88b43416c802d07314788b002;
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[0];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[1];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[2];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[3];
                    float4 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4;
                    float3 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5;
                    float2 _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1, _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2, 0, 0, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6);
                    float4 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4;
                    float3 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5;
                    float2 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3, _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4, 0, 0, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6);
                    float _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3;
                    Unity_Remap_float(_Power_15b0c1780b91432cac6da17de088dbc8_Out_2, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6, _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3);
                    float _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1;
                    Unity_Absolute_float(_Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1);
                    float _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3;
                    Unity_Smoothstep_float(_Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0, _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1, _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3);
                    float _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0 = Vector1_47bb49f0812542fb803d068d5ed05d83;
                    float _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0, _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2);
                    float2 _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2.xx), _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3);
                    float _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0 = Vector1_297cd5d5d7434306aae6cc29794d9b01;
                    float _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3, _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0, _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2);
                    float _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0 = Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                    float _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2;
                    Unity_Multiply_float(_GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2);
                    float _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2;
                    Unity_Add_float(_Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2, _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2);
                    float _Add_93b9b2112ec84c499475520eaa625333_Out_2;
                    Unity_Add_float(0, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Add_93b9b2112ec84c499475520eaa625333_Out_2);
                    float _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2;
                    Unity_Divide_float(_Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2, _Add_93b9b2112ec84c499475520eaa625333_Out_2, _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2);
                    float3 _Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2;
                    Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2.xxx), _Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2);
                    float _Property_0e31dc2a6f754c85aadcf176d4a7a4b9_Out_0 = Vector1_4fc9da11b7b64a4db817b811a850eec6;
                    float3 _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2;
                    Unity_Multiply_float(_Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2, (_Property_0e31dc2a6f754c85aadcf176d4a7a4b9_Out_0.xxx), _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2);
                    float3 _Add_a405210da624459eaf7e6d5571273445_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2, _Add_a405210da624459eaf7e6d5571273445_Out_2);
                    float3 _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2;
                    Unity_Add_float3(_Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2, _Add_a405210da624459eaf7e6d5571273445_Out_2, _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2);
                    description.Position = _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1);
                    float4 _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0 = IN.ScreenPosition;
                    float _Split_81145428320848b38c0179b335a6d364_R_1 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[0];
                    float _Split_81145428320848b38c0179b335a6d364_G_2 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[1];
                    float _Split_81145428320848b38c0179b335a6d364_B_3 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[2];
                    float _Split_81145428320848b38c0179b335a6d364_A_4 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[3];
                    float _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2;
                    Unity_Subtract_float(_Split_81145428320848b38c0179b335a6d364_A_4, 1, _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2);
                    float _Subtract_a7154844e80244d5953191d1982ec5ed_Out_2;
                    Unity_Subtract_float(_SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1, _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2, _Subtract_a7154844e80244d5953191d1982ec5ed_Out_2);
                    float _Property_42ff734ae1974c348205157ec49d927b_Out_0 = Vector1_02911973b4034ae5afcb09f063c1d343;
                    float _Divide_e396f840dddd4b0bb61838598aa08344_Out_2;
                    Unity_Divide_float(_Subtract_a7154844e80244d5953191d1982ec5ed_Out_2, _Property_42ff734ae1974c348205157ec49d927b_Out_0, _Divide_e396f840dddd4b0bb61838598aa08344_Out_2);
                    float _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1;
                    Unity_Saturate_float(_Divide_e396f840dddd4b0bb61838598aa08344_Out_2, _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1);
                    float _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3;
                    Unity_Smoothstep_float(0, 1, _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1, _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3);
                    surface.Alpha = _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
    
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
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHONLY
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
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
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 WorldSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float3 WorldSpacePosition;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
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
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
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
                float4 Vector4_307253f41ce3471a9e32193ed515a9b1;
                float Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                float Vector1_e76200de1bcf42ceaca17b7f4712245f;
                float Vector1_4fc9da11b7b64a4db817b811a850eec6;
                float4 Vector4_42a64ed88b43416c802d07314788b002;
                float4 Color_949c8f2e341b4a78a4c352b0dbf12e4d;
                float4 Color_64461c265c3d4842ad56ae75d5885d94;
                float Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                float Vector1_3320e339815442fb8fc145207ee548e5;
                float Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                float Vector1_297cd5d5d7434306aae6cc29794d9b01;
                float Vector1_47bb49f0812542fb803d068d5ed05d83;
                float Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                float Vector1_7adeb95c69a94315acd791a690dbb705;
                float Vector1_c967cd99c2774f6e89253a44a0516010;
                float Vector1_b77f19661c5d4522a944e55d987c67e7;
                float Vector1_c282f301bcd14b18915b5e00456c0961;
                float Vector1_02911973b4034ae5afcb09f063c1d343;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                    
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2);
                    float _Property_b66e0a1ea32e411bb105aa58ab9c06b7_Out_0 = Vector1_c967cd99c2774f6e89253a44a0516010;
                    float _Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2;
                    Unity_Divide_float(_Distance_4d2c004a13804ed0bc0cccb80db5be4f_Out_2, _Property_b66e0a1ea32e411bb105aa58ab9c06b7_Out_0, _Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2);
                    float _Power_be9fd859711a4a8a8691631496d671de_Out_2;
                    Unity_Power_float(_Divide_d334b46af2eb4095b279ce1d5bb68dda_Out_2, 3, _Power_be9fd859711a4a8a8691631496d671de_Out_2);
                    float3 _Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2;
                    Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_be9fd859711a4a8a8691631496d671de_Out_2.xxx), _Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2);
                    float _Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0 = Vector1_4a75c1cc02254de8bbcc546e9ff433cc;
                    float _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0 = Vector1_3320e339815442fb8fc145207ee548e5;
                    float4 _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0 = Vector4_307253f41ce3471a9e32193ed515a9b1;
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_R_1 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[0];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_G_2 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[1];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_B_3 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[2];
                    float _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4 = _Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0[3];
                    float3 _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_caff64fe8a534c54b0eb224eaae4bb0c_Out_0.xyz), _Split_11f9c8d1af2b403ab4a199061ace7f73_A_4, _RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3);
                    float _Property_373e2111852f404994ed7c8ebb8995a9_Out_0 = Vector1_e76200de1bcf42ceaca17b7f4712245f;
                    float _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_373e2111852f404994ed7c8ebb8995a9_Out_0, _Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2);
                    float2 _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_76bf9cc6595e4fbfb06d716839b62ffd_Out_2.xx), _TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3);
                    float _Property_972ed22572de4446a08c83a4d841beea_Out_0 = Vector1_87ee4d1a8c9d41308bb48ed1f7c5e86c;
                    float _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_93033c88a7974c6fb3e42944f97be6f1_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2);
                    float2 _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3);
                    float _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_410efb9bb11143b08318cef81dd59192_Out_3, _Property_972ed22572de4446a08c83a4d841beea_Out_0, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2);
                    float _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2;
                    Unity_Add_float(_GradientNoise_c4d5c847190c4154b1e5c3eac9c89433_Out_2, _GradientNoise_4b16a8c31dae411198e439d52f44b47d_Out_2, _Add_8c0a208aa9424feb813fac3884e17e4a_Out_2);
                    float _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2;
                    Unity_Divide_float(_Add_8c0a208aa9424feb813fac3884e17e4a_Out_2, 2, _Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2);
                    float _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1;
                    Unity_Saturate_float(_Divide_6cb72dbf8a7542198c6b145cc9747b88_Out_2, _Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1);
                    float _Property_67dec6538a7c46babb0f2249890cd010_Out_0 = Vector1_ebd83993d6ce4e1e8fc5f4a66f98de01;
                    float _Power_15b0c1780b91432cac6da17de088dbc8_Out_2;
                    Unity_Power_float(_Saturate_3fed3724dfd74d2d9f67874d1127f92c_Out_1, _Property_67dec6538a7c46babb0f2249890cd010_Out_0, _Power_15b0c1780b91432cac6da17de088dbc8_Out_2);
                    float4 _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0 = Vector4_42a64ed88b43416c802d07314788b002;
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[0];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[1];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[2];
                    float _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4 = _Property_44c2b9dc034441e890c38c94dbe4b6ff_Out_0[3];
                    float4 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4;
                    float3 _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5;
                    float2 _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_R_1, _Split_cb30d7b61b5047b09b92a06f447c5fd6_G_2, 0, 0, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGBA_4, _Combine_962c2ef37c4e4107ad2b7562f866c536_RGB_5, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6);
                    float4 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4;
                    float3 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5;
                    float2 _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6;
                    Unity_Combine_float(_Split_cb30d7b61b5047b09b92a06f447c5fd6_B_3, _Split_cb30d7b61b5047b09b92a06f447c5fd6_A_4, 0, 0, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGBA_4, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RGB_5, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6);
                    float _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3;
                    Unity_Remap_float(_Power_15b0c1780b91432cac6da17de088dbc8_Out_2, _Combine_962c2ef37c4e4107ad2b7562f866c536_RG_6, _Combine_bb0db42ef8334f059d3eecddee6cf45e_RG_6, _Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3);
                    float _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1;
                    Unity_Absolute_float(_Remap_f58cfe49e0984db5af488c5a4ac5d796_Out_3, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1);
                    float _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3;
                    Unity_Smoothstep_float(_Property_e724d3fc7a1c42ef859f872737a29bc2_Out_0, _Property_3259416b5fc04790a33aee9d4f10af0f_Out_0, _Absolute_d55b326e110645e59fae72cf57fc2abe_Out_1, _Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3);
                    float _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0 = Vector1_47bb49f0812542fb803d068d5ed05d83;
                    float _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_fa78d0cd09c147dba70bd9a8bcbd8560_Out_0, _Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2);
                    float2 _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_738224221b4b44219935b6530ffcc6e6_Out_3.xy), float2 (1, 1), (_Multiply_bc21d6b924a341eab1d3051f8cf40b08_Out_2.xx), _TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3);
                    float _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0 = Vector1_297cd5d5d7434306aae6cc29794d9b01;
                    float _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_d4abf832f64a4e4c900ab111cca0bf1b_Out_3, _Property_8e546b9355fc4efa8cf167b6abf20c42_Out_0, _GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2);
                    float _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0 = Vector1_bc730c3e0e9a4ebb9adb0aabb95eb8b7;
                    float _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2;
                    Unity_Multiply_float(_GradientNoise_0877be9e63434504820fb4f0e5745f0e_Out_2, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2);
                    float _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2;
                    Unity_Add_float(_Smoothstep_0870fa91ba94402ab2c846ec4628765b_Out_3, _Multiply_791fb6dc6cfd4f039de0c7f6622898d8_Out_2, _Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2);
                    float _Add_93b9b2112ec84c499475520eaa625333_Out_2;
                    Unity_Add_float(0, _Property_1e813c63d08646d29c05bc14b03b15d0_Out_0, _Add_93b9b2112ec84c499475520eaa625333_Out_2);
                    float _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2;
                    Unity_Divide_float(_Add_4e859f62dce6473d9ea9bdc6462f15d9_Out_2, _Add_93b9b2112ec84c499475520eaa625333_Out_2, _Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2);
                    float3 _Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2;
                    Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_69ab1bc21fcf413b9777f98b837bf678_Out_2.xxx), _Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2);
                    float _Property_0e31dc2a6f754c85aadcf176d4a7a4b9_Out_0 = Vector1_4fc9da11b7b64a4db817b811a850eec6;
                    float3 _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2;
                    Unity_Multiply_float(_Multiply_0c7b0ecfabc248108fcfaa6555a5de39_Out_2, (_Property_0e31dc2a6f754c85aadcf176d4a7a4b9_Out_0.xxx), _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2);
                    float3 _Add_a405210da624459eaf7e6d5571273445_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a083149d82a8480aac7a651ce3230f01_Out_2, _Add_a405210da624459eaf7e6d5571273445_Out_2);
                    float3 _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2;
                    Unity_Add_float3(_Multiply_821ee0ff96ba4fcb912056d9e67a1fc7_Out_2, _Add_a405210da624459eaf7e6d5571273445_Out_2, _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2);
                    description.Position = _Add_2b8e609a8c8b43e3bf78f6e9258afa10_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1);
                    float4 _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0 = IN.ScreenPosition;
                    float _Split_81145428320848b38c0179b335a6d364_R_1 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[0];
                    float _Split_81145428320848b38c0179b335a6d364_G_2 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[1];
                    float _Split_81145428320848b38c0179b335a6d364_B_3 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[2];
                    float _Split_81145428320848b38c0179b335a6d364_A_4 = _ScreenPosition_46096d17cabb409cbe9eff037b2e494b_Out_0[3];
                    float _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2;
                    Unity_Subtract_float(_Split_81145428320848b38c0179b335a6d364_A_4, 1, _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2);
                    float _Subtract_a7154844e80244d5953191d1982ec5ed_Out_2;
                    Unity_Subtract_float(_SceneDepth_b6ff28a3031842e686c146d8f899c526_Out_1, _Subtract_c4667afa5f1a44c98224eb454e16734a_Out_2, _Subtract_a7154844e80244d5953191d1982ec5ed_Out_2);
                    float _Property_42ff734ae1974c348205157ec49d927b_Out_0 = Vector1_02911973b4034ae5afcb09f063c1d343;
                    float _Divide_e396f840dddd4b0bb61838598aa08344_Out_2;
                    Unity_Divide_float(_Subtract_a7154844e80244d5953191d1982ec5ed_Out_2, _Property_42ff734ae1974c348205157ec49d927b_Out_0, _Divide_e396f840dddd4b0bb61838598aa08344_Out_2);
                    float _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1;
                    Unity_Saturate_float(_Divide_e396f840dddd4b0bb61838598aa08344_Out_2, _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1);
                    float _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3;
                    Unity_Smoothstep_float(0, 1, _Saturate_7658996c28844fc2a76a89ec80cf1681_Out_1, _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3);
                    surface.Alpha = _Smoothstep_7f6bce674aa94b0593b10b199ed7c2a9_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
    
                ENDHLSL
            }
        }
        FallBack "Hidden/Shader Graph/FallbackError"
    }