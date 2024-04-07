Shader "Unlit/RayMarching"
{
    SubShader
    {
        Tags { "Queue" = "Geometry-1900" "RenderType" = "Transparent" }
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha
        Cull front 
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            struct fragOut
            {
                float4 color : SV_Target;
                float depth : SV_Depth;
            };
             
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
            static const float SMIN_K = 0.5;
            
            int SpheresCount;
            sampler2D_float _BufferData;
            float4x4 CameraToWorld;
            float4x4 _CameraInverseProjection;

            float4 smin(float distanceA, float dictanceB, float3 colorA, float3 colorB) {
                float h = saturate(0.5 + 0.5*(distanceA-dictanceB)/SMIN_K);
                float distance = lerp(distanceA, dictanceB, h) - SMIN_K*h*(1.0-h);
                float3 color = lerp(colorA, colorB, h);
                return float4(color, distance);
            }
             
            float4 DistanceFunction(float3 currentPosition){
                float4 clocestData = (0,0,0,MAXIMUM_TRACE_DISTANCE);
                for (int i = 0; i < MAX_NUMBER_OF_SPHERES; i++){
                    float3 position = tex2D(_BufferData, float2(0 / WIDTH, i / HEIGHT)).xyz;
                    float3 rotation = tex2D(_BufferData, float2(1 / WIDTH, i / HEIGHT)).xyz;
                    float3 size = tex2D(_BufferData, float2(2 / WIDTH, i / HEIGHT)).xyz;
                    float4 color = tex2D(_BufferData, float2(3 / WIDTH, i / HEIGHT)).rgba;

                    float currentDistance = length(currentPosition - position) - size.x / 2.0;
                    clocestData = smin(clocestData.w, currentDistance, clocestData.rgb, color);
                }

                return clocestData;
            }

            float4 RayMarch(float3 ro, float3 rd)
            {
                float total_distance_traveled = 0.0;
                float4 ClosestAtAll = MAXIMUM_TRACE_DISTANCE;

                for (int i = 0; i < NUMBER_OF_STEPS; i++)
                {
                    float3 currentPosition = ro + total_distance_traveled * rd;

                    float4 distance_and_color_to_closest = DistanceFunction(currentPosition);
                    total_distance_traveled += distance_and_color_to_closest.w;

                    if (total_distance_traveled > MAXIMUM_TRACE_DISTANCE)
                    {
                        return float4(0,0,0,MAXIMUM_TRACE_DISTANCE);
                    }

                    if(ClosestAtAll.w > distance_and_color_to_closest.w){
                        ClosestAtAll = distance_and_color_to_closest;
                    }
                    
                    if (distance_and_color_to_closest.w < MINIMUM_HIT_DISTANCE) 
                    {
                        break;
                    }
                }
                return float4(ClosestAtAll.rgb, total_distance_traveled);
            }

            fragOut frag (v2f i)
            {
                fragOut output = (fragOut)0;

                float2 uv = i.screenPos.xy / i.screenPos.w * 2.0 - 1.0;
                float3 ro = mul(CameraToWorld, float4(0,0,0,1)).xyz;
                float3 rd = mul(_CameraInverseProjection, float4(uv,0,1)).xyz;
                rd = mul(CameraToWorld, float4(rd,0)).xyz;
                rd = normalize(rd);

                float4 rm = RayMarch(ro, rd);
                
                float linearDepth = max(rm.w, MINIMUM_HIT_DISTANCE) * 2.0 - 1.0;
                float nonLinearDepth = 2 * _ProjectionParams.x * _ProjectionParams.y / (_ProjectionParams.x + _ProjectionParams .y - (_ProjectionParams.y - _ProjectionParams.x) * linearDepth);
                // todo make depth count with fish eye effect
                output.color = float4(rm.rgb, rm.w == MAXIMUM_TRACE_DISTANCE? 0.0 : 1.0);
                output.depth = nonLinearDepth;
                return output;
            }

            ENDCG
        }
    }
}
