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
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            sampler2D _BufferData;
            float4 _CameraPosition;

            float4 frag (v2f i) : SV_Target
            {
                float4 color = tex2D(_BufferData, float2(3 / 8.0, 0 / 512.0));
                // rd = o.vertex - _CameraPosition;
                return float4(_CameraPosition.x, _CameraPosition.y, _CameraPosition.z, 1.0);
            }
            ENDCG
        }
    }
}
