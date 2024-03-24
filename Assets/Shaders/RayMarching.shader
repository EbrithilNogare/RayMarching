Shader "Unlit/RayMarching"
{
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull front 
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma unroll 1

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float3 position : TEXCOORD1;
            };

            struct ClosestInfo
            {
                float distance;
                float4 color;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }
             
            /////////////////////////////
            //                         //
            //     FRAGMENT SHADER     //
            //                         //
            /////////////////////////////
            
            static const int NUMBER_OF_STEPS = 32;
            static const int MAX_NUMBER_OF_SPHERES = 4;
            static const float WIDTH = 4;
            static const float HEIGHT = 64;
            static const float MINIMUM_HIT_DISTANCE = 0.001;
            static const float MAXIMUM_TRACE_DISTANCE = 100.0;
            
            int SpheresCount;
            sampler2D_float _BufferData;
            float4x4 CameraToWorld;
            float4x4 _CameraInverseProjection;
             
            ClosestInfo DistanceFunction(float3 currentPosition){
                ClosestInfo Ci;
                Ci.distance = MAXIMUM_TRACE_DISTANCE;
                for (int i = 0; i < MAX_NUMBER_OF_SPHERES; i++){
                    float3 position = tex2D(_BufferData, float2(0 / WIDTH, i / HEIGHT)).xyz;
                    float3 rotation = tex2D(_BufferData, float2(1 / WIDTH, i / HEIGHT)).xyz;
                    float3 size = tex2D(_BufferData, float2(2 / WIDTH, i / HEIGHT)).xyz;
                    float4 color = tex2D(_BufferData, float2(3 / WIDTH, i / HEIGHT)).rgba;

                    float currentDistance = length(currentPosition - position) - size.x / 2.0;
                    if(Ci.distance > currentDistance)
                    {
                        Ci.distance = currentDistance;
                        Ci.color = color;
                    }
                }

                return Ci;
            }

            float4 RayMarch(float3 ro, float3 rd)
            {
                float total_distance_traveled = 0.0;
                float ClosestAtAll = MAXIMUM_TRACE_DISTANCE;

                for (int i = 0; i < NUMBER_OF_STEPS; i++)
                {
                    float3 currentPosition = ro + total_distance_traveled * rd;

                    ClosestInfo distance_and_color_to_closest = DistanceFunction(currentPosition);

                    if (distance_and_color_to_closest.distance < MINIMUM_HIT_DISTANCE) 
                    {
                        return distance_and_color_to_closest.color;
                    }

                    if (total_distance_traveled > MAXIMUM_TRACE_DISTANCE)
                    {
                        break;
                    }

                    ClosestAtAll = min(ClosestAtAll, distance_and_color_to_closest.distance);

                    total_distance_traveled += distance_and_color_to_closest.distance;
                }
                return float4(1, 1, 1, min(1, max(0.1, 1 - ClosestAtAll)));
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 uv = i.screenPos.xy / i.screenPos.w * 2.0 - 1.0;
                float3 ro = mul(CameraToWorld, float4(0,0,0,1)).xyz;
                float3 rd = mul(_CameraInverseProjection, float4(uv,0,1)).xyz;
                rd = mul(CameraToWorld, float4(rd,0)).xyz;
                rd = normalize(rd);

                float4 rm = RayMarch(ro, rd);
                return float4(rm);
            }

            ENDCG
        }
    }
}
