Shader "Nyxis/URP_Grass"
{
    Properties
    {
        [Header(Blade Texture)]
        [MainTexture] _MainTex("Alpha Texture (RGB = tint, A = shape cutout)", 2D) = "white" {}

        [Header(Anime Colors)]
        _TopColor("Top (Sun) Color", Color) = (0.8, 0.9, 0.4, 1)
        _BottomColor("Root (Shadow) Color", Color) = (0.0, 0.4, 0.35, 1)
        _ShadowTint("Shadow Tint", Color) = (0.0, 0.2, 0.2, 1)

        [Header(Shape)]
        _BladeHeight("Blade Height", Float) = 1.0
        [Range(0,1)]
        _FlattenNormals("Flatten Normals", Float) = 1.0

        [Header(Wind)]
        _WindSpeed("Wind Speed", Float) = 1.0
        _WindStrength("Wind Strength", Float) = 0.2

        [Header(Player Interaction)]
        _PushStrength("Interaction Power", Float) = 3.0
        _BendDownStrength("Bend Down Strength", Range(0,1)) = 0.5
        [Range(1,4)]
        _FalloffSoftness("Falloff Softness", Float) = 2.0

        [Header(Alpha)]
        _Cutoff("Alpha Cutoff", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "TransparentCutout"
            "Queue" = "AlphaTest"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        LOD 300
        Cull Off
        ZWrite On

        HLSLINCLUDE

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);

        CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _TopColor;
            half4 _BottomColor;
            half4 _ShadowTint;

            half _BladeHeight;
            half _FlattenNormals;

            half _WindSpeed;
            half _WindStrength;
            half _PushStrength;
            half _BendDownStrength;
            half _FalloffSoftness;

            half _Cutoff;
        CBUFFER_END

        float3 _GlobalPlayerPos;
        float _GlobalPlayerRadius;

        half3 ApplyMovementOpt(float3 worldPos, half heightFactor)
        {
            half time = (half)_Time.y * _WindSpeed;
            half windWave = sin((half)((worldPos.x + worldPos.z) * 0.5) + time);
            half3 offset = half3(windWave, 0.0h, windWave) * (0.1h * _WindStrength * heightFactor);

            float2 dirXZ = worldPos.xz - _GlobalPlayerPos.xz;
            float distSqr = dot(dirXZ, dirXZ);
            float radius = max(_GlobalPlayerRadius, 0.001);
            float radiusSqr = radius * radius;

            if (distSqr < radiusSqr)
            {
                float safeDistSqr = max(distSqr, 0.0001);
                half interaction = (half)saturate(1.0 - (safeDistSqr / radiusSqr));
                interaction = pow(max(interaction, 0.0001h), max(_FalloffSoftness, 0.001h));

                float invDist = rsqrt(safeDistSqr);
                half2 pushDirXZ = (half2)(dirXZ * invDist);

                half3 pushDir = half3(pushDirXZ.x, -_BendDownStrength, pushDirXZ.y);
                offset += pushDir * (interaction * _PushStrength * heightFactor);
            }

            return offset;
        }

        struct GrassAttributes
        {
            float4 positionOS : POSITION;
            float3 normalOS   : NORMAL;
            float2 uv         : TEXCOORD0;

            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct GrassVaryings
        {
            float4 positionCS : SV_POSITION;
            half3 normalWS    : TEXCOORD0;
            half height       : TEXCOORD1;
            float2 uv         : TEXCOORD2;
            half3 ambient     : TEXCOORD3;
            half fogFactor    : TEXCOORD4;

            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        GrassVaryings GrassVertex(GrassAttributes IN)
        {
            GrassVaryings OUT = (GrassVaryings)0;

            UNITY_SETUP_INSTANCE_ID(IN);
            UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

            float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
            half height = (half)saturate(IN.positionOS.y / max(_BladeHeight, 0.001h));

            worldPos += ApplyMovementOpt(worldPos, height);

            OUT.height = height;
            OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

            float3 originalNormal = TransformObjectToWorldNormal(IN.normalOS);
            half3 normalWS = (half3)normalize(lerp(originalNormal, float3(0.0, 1.0, 0.0), _FlattenNormals));
            OUT.normalWS = normalWS;

            OUT.ambient = (half3)SampleSHVertex(normalWS);

            float4 posCS = TransformWorldToHClip(worldPos);
            OUT.positionCS = posCS;
            OUT.fogFactor = (half)ComputeFogFactor(posCS.z);

            return OUT;
        }

        ENDHLSL

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode" = "UniversalForward" }

            Cull Off
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma target 3.5

            #pragma vertex Vert
            #pragma fragment Frag

            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile_fog

            GrassVaryings Vert(GrassAttributes IN)
            {
                return GrassVertex(IN);
            }

            half4 Frag(GrassVaryings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);

                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                clip(texColor.a - _Cutoff);

                Light mainLight = GetMainLight();

                half3 grassColor = lerp(_BottomColor.rgb, _TopColor.rgb, IN.height) * texColor.rgb;
                half3 normal = normalize(IN.normalWS);
                half3 lightDirection = (half3)mainLight.direction;

                half NdotL = saturate(dot(normal, lightDirection));
                half lighting = smoothstep(-0.1h, 0.5h, NdotL);

                half3 shadowColor = grassColor * _ShadowTint.rgb;
                half3 finalColor = lerp(shadowColor, grassColor, lighting) * (half3)mainLight.color;

                finalColor += IN.ambient * grassColor * 0.1h;
                finalColor = MixFog(finalColor, IN.fogFactor);

                return half4(finalColor, 1.0h);
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            Cull Off
            ZWrite On
            ZTest LEqual
            ColorMask R

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex DepthVert
            #pragma fragment DepthFrag
            #pragma multi_compile_instancing

            struct DepthAttributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct DepthVaryings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            DepthVaryings DepthVert(DepthAttributes IN)
            {
                DepthVaryings OUT = (DepthVaryings)0;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
                half height = (half)saturate(IN.positionOS.y / max(_BladeHeight, 0.001h));

                worldPos += ApplyMovementOpt(worldPos, height);

                OUT.positionCS = TransformWorldToHClip(worldPos);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

                return OUT;
            }

            half4 DepthFrag(DepthVaryings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                half alpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).a;
                clip(alpha - _Cutoff);
                return 0;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthNormals"
            Tags { "LightMode" = "DepthNormals" }

            Cull Off
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex DepthNormalsVert
            #pragma fragment DepthNormalsFrag
            #pragma multi_compile_instancing

            struct DN_Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct DN_Varyings
            {
                float4 positionCS : SV_POSITION;
                half3 normalWS    : TEXCOORD0;
                float2 uv         : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            DN_Varyings DepthNormalsVert(DN_Attributes IN)
            {
                DN_Varyings OUT = (DN_Varyings)0;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
                half height = (half)saturate(IN.positionOS.y / max(_BladeHeight, 0.001h));

                worldPos += ApplyMovementOpt(worldPos, height);

                float3 originalNormal = TransformObjectToWorldNormal(IN.normalOS);
                OUT.normalWS = (half3)normalize(lerp(originalNormal, float3(0.0, 1.0, 0.0), _FlattenNormals));
                OUT.positionCS = TransformWorldToHClip(worldPos);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

                return OUT;
            }

            half4 DepthNormalsFrag(DN_Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                half alpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).a;
                clip(alpha - _Cutoff);
                return half4(NormalizeNormalPerPixel(IN.normalWS), 0.0h);
            }
            ENDHLSL
        }
    }
}
