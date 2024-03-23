Shader "Unlit/RayMarching"
{
    Properties
    {
        _CameraPosition ("CameraPosition", Vector) = (0, 0, 0, 0)
    }
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

            StructuredBuffer<float4> _BufferData;
            float4 _CameraPosition;
            
            float DistanceFunction(float3 currentPosition){
                int i = 0;
                
                float3 position = _BufferData[0 + 8*i].xyz;
                float3 rotation = _BufferData[1 + 8*i].xyz;
                float3 size = _BufferData[2 + 8*i].xyz;
                float4 color = _BufferData[3 + 8*i].rgba;

                return length(currentPosition - position) - size.x;
            }

            float4 RayMarch(float3 ro, float3 rd)
            {
                float total_distance_traveled = 0.0;
                int NUMBER_OF_STEPS = 8; //32
                float MINIMUM_HIT_DISTANCE = 0.001;
                float MAXIMUM_TRACE_DISTANCE = 1000.0;
                float ClosestAtAll = MAXIMUM_TRACE_DISTANCE;

                for (int i = 0; i < NUMBER_OF_STEPS; ++i)
                {
                    float3 currentPosition = ro + total_distance_traveled * rd;

                    float distance_to_closest = DistanceFunction(currentPosition);

                    if (distance_to_closest < MINIMUM_HIT_DISTANCE) 
                    {
                        return float4(1.0, 0, 0, 1);
                    }

                    if (total_distance_traveled > MAXIMUM_TRACE_DISTANCE)
                    {
                        break;
                    }

                    ClosestAtAll = min(ClosestAtAll, distance_to_closest);

                    total_distance_traveled += distance_to_closest;
                }
                return float4(1, 1, 1, min(1, max(0.1, 1-ClosestAtAll)));
            }


            float4 frag (v2f i) : SV_Target
            {
                //float2 uv = (i.screenPos - _CameraPosition.xy) * 2.0 - 1.0;
                float3 ro = _CameraPosition.xyz;
                float3 rd = normalize(i.position - ro);
                float4 color = _BufferData[3 + 0 * 8];
                float4 rm = RayMarch(ro, rd);
                return float4(rm);
            }
            ENDCG
        }
    }
}
