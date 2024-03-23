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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 screenPos : TEXCOORD0;
                float3 position : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.position = o.vertex;
                return o;
            }
             
            /////////////////////////////
            //                         //
            //     FRAGMENT SHADER     //
            //                         //
            /////////////////////////////
            
            static const int NUMBER_OF_STEPS = 16;
            static const float WIDTH = 8;
            static const float HEIGHT = 512;
            static const float MINIMUM_HIT_DISTANCE = 0.0001;
            static const float MAXIMUM_TRACE_DISTANCE = 1000.0;
            
            int SpheresCount;
            sampler2D_float _BufferData;
            float4 _CameraPosition;
            
            float DistanceFunction(float3 currentPosition){
                float closestDistance = MAXIMUM_TRACE_DISTANCE;

                [unroll(32)] for (int i = 0; i < SpheresCount; i++){
                    float3 position = tex2D(_BufferData, float2(0 / WIDTH, i / HEIGHT)).xyz;
                    float3 rotation = tex2D(_BufferData, float2(1 / WIDTH, i / HEIGHT)).xyz;
                    float3 size = tex2D(_BufferData, float2(2 / WIDTH, i / HEIGHT)).xyz;
                    float4 color = tex2D(_BufferData, float2(3 / WIDTH, i / HEIGHT)).rgba;

                    float currentDistance = length(currentPosition - position) - size.x;
                    closestDistance = min(closestDistance, currentDistance);
                }

                return closestDistance;
            }

            float4 RayMarch(float3 ro, float3 rd)
            {
                float total_distance_traveled = 0.0;
                float ClosestAtAll = MAXIMUM_TRACE_DISTANCE;

                for (int i = 0; i < NUMBER_OF_STEPS; i++)
                {
                    float3 currentPosition = ro + total_distance_traveled * rd;

                    float distance_to_closest = DistanceFunction(currentPosition);

                    if (distance_to_closest < MINIMUM_HIT_DISTANCE) 
                    {
                        return float4(1, 0, 0, 1);
                    }

                    if (total_distance_traveled > MAXIMUM_TRACE_DISTANCE)
                    {
                        break;
                    }

                    ClosestAtAll = min(ClosestAtAll, distance_to_closest);

                    total_distance_traveled += distance_to_closest;
                }
                return float4(1, 1, 1, min(1, max(0.1, 1 - ClosestAtAll)));
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 ro = _CameraPosition.xyz;
                float3 rd = normalize(i.position - ro);
                float4 color = tex2D(_BufferData, float2(3.0 / WIDTH, 0.0 / HEIGHT));
                float4 rm = RayMarch(ro, rd);
                return float4(rm);
            }

            ENDCG
        }
    }
}
