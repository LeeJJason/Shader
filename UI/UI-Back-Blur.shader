// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/UI/BlackBlur" {
	Properties{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1.000000,1.000000,1.000000,1.000000)
		_Size("Size", Range(0, 20)) = 1
	}

		Category
		{

			// We must be transparent, so other objects are drawn before this one.
			Tags { "Queue" = "Transparent" "IgnoreProjector" = "False" "RenderType" = "Opaque" }


		SubShader
		{

				// Horizontal blur
				GrabPass
				{
					Tags { "LightMode" = "Always" }
				}
				Pass
				{
					Tags { "LightMode" = "Always" }

					CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#pragma fragmentoption ARB_precision_hint_fastest
					#include "UnityCG.cginc"

					struct appdata_t {
						float4 vertex : POSITION;
						fixed4 color    : COLOR;
						float2 texcoord: TEXCOORD0;
					};

					struct v2f {
						float4 vertex : POSITION;
						fixed4 color    : COLOR;
						float4 uvgrab : TEXCOORD0;
					};

					v2f vert(appdata_t v)
					{
						v2f o;
						o.vertex = UnityObjectToClipPos(v.vertex);
						#if UNITY_UV_STARTS_AT_TOP
						float scale = -1.0;
						#else
						float scale = 1.0;
						#endif

						o.uvgrab = ComputeScreenPos(o.vertex);
						o.color = v.color;
						//o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y * scale) + o.vertex.w) * 0.5;
						//o.uvgrab.zw = o.vertex.zw;
						return o;
					}

					sampler2D _MainTex;
					sampler2D _GrabTexture;
					float4 _GrabTexture_TexelSize;
					half4 _Color;
					float _Size;

					half4 frag(v2f i) : COLOR
					{
						half4 sum = half4(0,0,0,0);

						#define GRABPIXEL(weight,kernelx) tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(float4(i.uvgrab.x + _GrabTexture_TexelSize.x * kernelx*_Size * i.uvgrab.w, i.uvgrab.y, i.uvgrab.z, i.uvgrab.w))) * weight

						/*sum += GRABPIXEL(0.05, -4.0);
						sum += GRABPIXEL(0.09, -3.0);
						sum += GRABPIXEL(0.12, -2.0);
						sum += GRABPIXEL(0.15, -1.0);
						sum += GRABPIXEL(0.18,  0.0);
						sum += GRABPIXEL(0.15, +1.0);
						sum += GRABPIXEL(0.12, +2.0);
						sum += GRABPIXEL(0.09, +3.0);
						sum += GRABPIXEL(0.05, +4.0);*/
						sum += GRABPIXEL(0.01, -9.0);
						sum += GRABPIXEL(0.02, -8.0);
						sum += GRABPIXEL(0.03, -7.0);
						sum += GRABPIXEL(0.04, -6.0);
						sum += GRABPIXEL(0.05, -5.0);
						sum += GRABPIXEL(0.06, -4.0);
						sum += GRABPIXEL(0.07, -3.0);
						sum += GRABPIXEL(0.08, -2.0);
						sum += GRABPIXEL(0.09, -1.0);
						sum += GRABPIXEL(0.10, 0.0);
						sum += GRABPIXEL(0.09, +1.0);
						sum += GRABPIXEL(0.08, +2.0);
						sum += GRABPIXEL(0.07, +3.0);
						sum += GRABPIXEL(0.06, +4.0);
						sum += GRABPIXEL(0.05, +5.0);
						sum += GRABPIXEL(0.04, +6.0);
						sum += GRABPIXEL(0.03, +7.0);
						sum += GRABPIXEL(0.02, +8.0);
						sum += GRABPIXEL(0.01, +9.0);

						return sum * i.color;
					}
					ENDCG
				}
			// Vertical blur
			GrabPass
			{
				Tags { "LightMode" = "Always" }
			}
			Pass
			{
				Tags { "LightMode" = "Always" }

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"

				struct appdata_t {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord: TEXCOORD0;
				};

				struct v2f {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float4 uvgrab : TEXCOORD0;
				};

				v2f vert(appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					#if UNITY_UV_STARTS_AT_TOP
					float scale = -1.0;
					#else
					float scale = 1.0;
					#endif
					o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y * scale) + o.vertex.w) * 0.5;
					o.uvgrab.zw = o.vertex.zw;
					o.color = v.color;
					return o;
				}

				sampler2D _GrabTexture;
				float4 _GrabTexture_TexelSize;
				half4 _Color;
				float _Size;

				half4 frag(v2f i) : COLOR
				{
					half4 sum = half4(0,0,0,0);

					#define GRABPIXEL(weight,kernely) tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(float4(i.uvgrab.x, i.uvgrab.y + _GrabTexture_TexelSize.y * kernely* _Size * i.uvgrab.w, i.uvgrab.z, i.uvgrab.w))) * weight


					/*sum += GRABPIXEL(0.05, -4.0);
					sum += GRABPIXEL(0.09, -3.0);
					sum += GRABPIXEL(0.12, -2.0);
					sum += GRABPIXEL(0.15, -1.0);
					sum += GRABPIXEL(0.18,  0.0);
					sum += GRABPIXEL(0.15, +1.0);
					sum += GRABPIXEL(0.12, +2.0);
					sum += GRABPIXEL(0.09, +3.0);
					sum += GRABPIXEL(0.05, +4.0);*/
					sum += GRABPIXEL(0.01, -9.0);
					sum += GRABPIXEL(0.02, -8.0);
					sum += GRABPIXEL(0.03, -7.0);
					sum += GRABPIXEL(0.04, -6.0);
					sum += GRABPIXEL(0.05, -5.0);
					sum += GRABPIXEL(0.06, -4.0);
					sum += GRABPIXEL(0.07, -3.0);
					sum += GRABPIXEL(0.08, -2.0);
					sum += GRABPIXEL(0.09, -1.0);
					sum += GRABPIXEL(0.10, 0.0);
					sum += GRABPIXEL(0.09, +1.0);
					sum += GRABPIXEL(0.08, +2.0);
					sum += GRABPIXEL(0.07, +3.0);
					sum += GRABPIXEL(0.06, +4.0);
					sum += GRABPIXEL(0.05, +5.0);
					sum += GRABPIXEL(0.04, +6.0);
					sum += GRABPIXEL(0.03, +7.0);
					sum += GRABPIXEL(0.02, +8.0);
					sum += GRABPIXEL(0.01, +9.0);

					return sum * i.color;
				}
				ENDCG
			}
		}
		}
}
