Shader "Unlit/RayMarching"
{
    Properties
    {
        _BufferData ("BufferData", 2D) = "white" {}
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
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_BufferData, float2(0 / 8.0, 0 / 512.0));
                return fixed4(color);
            }
            ENDCG
        }
    }
}
