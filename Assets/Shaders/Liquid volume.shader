Shader "Unlit/LiquidVolume"
{
    Properties {
        _Absorption("Absorption", Range(0, .2)) = .01
        _Color("Color", Color) = (1,1,1,1)
    }
   
    SubShader {
        Tags { "Queue" = "Geometry+10" "RenderType" = "Transparent" }
       
        Pass {
            Cull back
            Blend SrcAlpha OneMinusSrcAlpha
           
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 
            #include "UnityCG.cginc"
 
            struct a2v {
                float4 vertex : POSITION;
            };
 
            struct v2f {
                float4 pos : SV_POSITION;
                half dist : TEXCOORD0;
            };
 
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                COMPUTE_EYEDEPTH(o.dist);
                return o;
            }
 
            float _Absorption;
            float4 _Color;

            fixed4 frag(v2f i, fixed facing : VFACE) : COLOR {
                float depth = _Absorption * sign(facing) * i.dist;
                return half4(_Color.r, _Color.g, _Color.b, depth);
            }
            ENDCG
        }
    }
}