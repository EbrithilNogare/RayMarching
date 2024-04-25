Shader "Unlit/RayMarching"
{
    Properties
    {
        [KeywordEnum(FAST, NORMAL, GOOD, BEST)] _STEPS("Overlay mode", Float) = 0
    }
    SubShader
    {
        Tags { "Queue" = "Geometry-10" "RenderType" = "Transparent" }
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha
        Cull front 
        LOD 100
        // UNITY_SHADER_NO_UPGRADE 

        Pass
        {
            CGPROGRAM
            #pragma multi_compile _STEPS_FAST _STEPS_NORMAL _STEPS_GOOD _STEPS_BEST
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

            struct buferDataFormat
            {
                float3 position;
                float3 rotation;
                float3 size;
                float4 color;
            };
             
            /////////////////////////////
            //                         //
            //     FRAGMENT SHADER     //
            //                         //
            /////////////////////////////
            
            #ifdef _STEPS_FAST
            static const int NUMBER_OF_STEPS = 16;
            #endif
            #ifdef _STEPS_NORMAL
            static const int NUMBER_OF_STEPS = 32;
            #endif
            #ifdef _STEPS_GOOD
            static const int NUMBER_OF_STEPS = 128;
            #endif
            #ifdef _STEPS_BEST
            static const int NUMBER_OF_STEPS = 512;
            #endif
            static const int MAX_NUMBER_OF_SPHERES = 5;
            static const float WIDTH = 4;
            static const float HEIGHT = 16;
            static const float MINIMUM_HIT_DISTANCE = 0.001;
            static const float MAXIMUM_TRACE_DISTANCE = 100.0;
            static const float SMIN_K = 0.5;
            
            int SpheresCount;
            sampler2D_float _BufferData;
            float4x4 CameraToWorld;
            float4x4 _CameraInverseProjection;
            float nearClipPlane;
            float3 LightPosition;
            float3 LightColor;
            buferDataFormat buferData[MAXIMUM_TRACE_DISTANCE];
            

            float4 smin(float distanceA, float dictanceB, float3 colorA, float3 colorB) {
                float h = saturate(0.5 + 0.5*(distanceA-dictanceB)/SMIN_K);
                float distance = lerp(distanceA, dictanceB, h) - SMIN_K*h*(1.0-h);
                float3 color = lerp(colorA, colorB, h);
                return float4(color, distance);
            }
             
            float4 DistanceFunction(float3 currentPosition){
                float4 clocestData = float4(0, 0, 0, MAXIMUM_TRACE_DISTANCE);
                for (int i = 0; i < MAX_NUMBER_OF_SPHERES; i++){
                    float3 position = buferData[i].position;
                    float3 rotation = buferData[i].rotation;
                    float3 size = buferData[i].size;
                    float3 color = buferData[i].color;

                    float currentDistance = length(currentPosition - position) - size.x / 2.0;
                    clocestData = smin(clocestData.w, currentDistance, clocestData.rgb, color);
                }

                return clocestData;
            }

            float3 EstimateNormal(float3 currentPosition){
                float x = DistanceFunction(float3(currentPosition.x+MINIMUM_HIT_DISTANCE,currentPosition.y,currentPosition.z)).w - DistanceFunction(float3(currentPosition.x-MINIMUM_HIT_DISTANCE,currentPosition.y,currentPosition.z)).w;
                float y = DistanceFunction(float3(currentPosition.x,currentPosition.y+MINIMUM_HIT_DISTANCE,currentPosition.z)).w - DistanceFunction(float3(currentPosition.x,currentPosition.y-MINIMUM_HIT_DISTANCE,currentPosition.z)).w;
                float z = DistanceFunction(float3(currentPosition.x,currentPosition.y,currentPosition.z+MINIMUM_HIT_DISTANCE)).w - DistanceFunction(float3(currentPosition.x,currentPosition.y,currentPosition.z-MINIMUM_HIT_DISTANCE)).w;
                return normalize(float3(x,y,z));
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

            void gatherData(){
                 for(int i = 0; i < MAX_NUMBER_OF_SPHERES; i++){
                    buferData[i].position = tex2D(_BufferData, float2(0 / WIDTH, i / HEIGHT)).xyz;
                    buferData[i].rotation = tex2D(_BufferData, float2(1 / WIDTH, i / HEIGHT)).xyz;
                    buferData[i].size = tex2D(_BufferData, float2(2 / WIDTH, i / HEIGHT)).xyz;
                    buferData[i].color = tex2D(_BufferData, float2(3 / WIDTH, i / HEIGHT)).rgba;
                }
            }

            fragOut frag (v2f i)
            {
                // get data from texture buffer once
                gatherData();

                // init ray
                float2 uv = i.screenPos.xy / i.screenPos.w * 2.0 - 1.0;
                float3 ro = mul(CameraToWorld, float4(0,0,0,1)).xyz;
                float3 rd = mul(_CameraInverseProjection, float4(uv,0,1)).xyz;
                rd = mul(CameraToWorld, float4(rd,0)).xyz;
                rd = normalize(rd);

                // raymarch
                float4 rm = RayMarch(ro, rd);
                float3 surfacePoint = ro + rm.w * rd;

                //estimate normal
                float3 normal = EstimateNormal(surfacePoint);

                //light
                float3 directionToLight = normalize(LightPosition - surfacePoint);
                float lighting = saturate(dot(normal, directionToLight));

                // output color and depth
                fragOut output = (fragOut)0;
                
                output.color = float4(rm.rgb * lerp(LightColor * lighting, 1.0, 0.2), rm.w == MAXIMUM_TRACE_DISTANCE? 0.0 : 1.0);

                float4 depth_vec = mul(UNITY_MATRIX_VP, float4(surfacePoint, 1.0));
                float depth = depth_vec.z / depth_vec.w;
                
                #if defined(UNITY_REVERSED_Z)
                output.depth = depth; // Direct3D
                #else
                output.depth = ( depth + 1.0 ) * 0.5; // OpenGL
                #endif

                return output;
            }

            ENDCG
        }
    }
}
