Shader "Unlit/RayMarching"
{
    Properties
    {
        _BufferData ("BufferData", 2D) = "white" {}
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

            sampler2D _BufferData;
            float4 _CameraPosition;
            
            float3 RayMarch(float3 ro, float3 rd)
            {
                float total_distance_traveled = 0.0;
                int NUMBER_OF_STEPS = 32; //32
                float MINIMUM_HIT_DISTANCE = 0.1; //0.001
                float MAXIMUM_TRACE_DISTANCE = 1000.0;

                for (int i = 0; i < NUMBER_OF_STEPS; ++i)
                {
                    float3 current_position = ro + total_distance_traveled * rd;

                    float distance_to_closest = length(current_position - float3(0,0,0)) - 2.0;

                    if (distance_to_closest < MINIMUM_HIT_DISTANCE) 
                    {
                        return float3(1.0, 0.0, 0.0);
                    }

                    if (total_distance_traveled > MAXIMUM_TRACE_DISTANCE)
                    {
                        break;
                    }
                    total_distance_traveled += distance_to_closest;
                }
                return float3(0,0,0);
            }


            float4 frag (v2f i) : SV_Target
            {
                //float2 uv = (i.screenPos - _CameraPosition.xy) * 2.0 - 1.0;
                float3 ro = _CameraPosition.xyz;
                float3 rd = normalize(i.position - ro);
                float4 color = tex2D(_BufferData, float2(3 / 8.0, 0 / 512.0));
                float3 rm = RayMarch(ro, rd);
                return float4(rm.xyz, 1.0);
            }
            ENDCG
        }
    }
}
