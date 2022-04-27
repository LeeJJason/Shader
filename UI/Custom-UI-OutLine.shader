Shader "Custom/UI/OutLine"
{
    Properties
    {
        [PerRendererData]
        _MainTex("Texture", 2D) = "white" {}
        _LightColor("Light Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Size("Size", Int) = 1
        _Threshold("Threshold", Range(0, 1)) = 0.5
        _Weight("Weight", Range(0, 1)) = 0.5
    }

        SubShader{

            Tags
            {
                "Queue" = "Transparent"
                "IgnoreProjector" = "True"
                "RenderType" = "Transparent"
                "PreviewType" = "Plane"
                "CanUseSpriteAtlas" = "True"
            }
            Blend SrcAlpha OneMinusSrcAlpha

            Pass {

                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "UnityUI.cginc"

                #pragma multi_compile __ UNITY_UI_CLIP_RECT
                #pragma multi_compile __ UNITY_UI_ALPHACLIP

                struct appdata
                {
                    float4 vertex   : POSITION;
                    float2 texcoord : TEXCOORD0;
                    float4 color    : COLOR;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                struct v2f {
                    float4 pos : SV_POSITION;
                    float2 uv: TEXCOORD0;
                    float4 color    : COLOR;
                    UNITY_VERTEX_OUTPUT_STEREO
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                half4 _MainTex_TexelSize;
                float4 _LightColor;
                int _Size;
                float _Threshold;
                float _Weight;
                float4 _ClipRect;

                v2f vert(appdata IN)
                {
                    v2f OUT;
                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                    OUT.pos = UnityObjectToClipPos(IN.vertex);
                    OUT.uv = TRANSFORM_TEX(IN.texcoord, _MainTex);
                    OUT.color = IN.color;
                    return OUT;
                }

                fixed4 frag(v2f IN) : SV_TARGET
                {
#ifdef UNITY_UI_CLIP_RECT
                    clip(UnityGet2DClipping(IN.worldPosition.xy, _ClipRect));

#endif

                    fixed4 color = tex2D(_MainTex, IN.uv);

                    fixed4 c = _LightColor;
                    int count = 0;
                    float sum = tex2D(_MainTex, IN.uv).a;
                    for (int i = -_Size; i <= _Size; i++) {
                        for (int j = -_Size; j <= _Size; j++) {
                            sum += i == j & i == 0 ? color.a : tex2D(_MainTex, IN.uv + _MainTex_TexelSize.xy * half2(i, j)).a;
                            count += 1;
                        }
                    }

                    c.a = (_Weight < 0.025 || sum < 0.011) ? sum : (sum / (count * _Weight));

                    color = color.a > _Threshold ? color * IN.color : c;
#ifdef UNITY_UI_CLIP_RECT
                    color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
#endif

#ifdef UNITY_UI_ALPHACLIP
                    clip(color.a - 0.001);
#endif

                    return color.a > _Threshold ? color * IN.color : c;
                }

                ENDCG
            }
        }
}