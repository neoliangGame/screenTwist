Shader "neo/screenWave"
{
	Properties
	{
		_MainTex ("Noise Texture", 2D) = "white" {}
		_MaskTex("Mask Texture", 2D) = "white" {}
		_Strength("Strength", Range(0,100)) = 10
	}
	SubShader
	{
		Tags{
			"RenderType" = "Transparent"
			"Queue" = "Transparent+1"
			"LightMode" = "ForwardBase"
		}
		LOD 100
		Cull Off
		Lighting Off
		ZWrite Off

		GrabPass{
			"waveTexture"
		}

		Pass
		{
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 maskUV : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float2 maskUV : TEXCOORD1;
				float4 grabUV : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _MaskTex;
			float4 _MaskTex_ST;

			sampler2D waveTexture;
			float4 waveTexture_ST;
			float4 waveTexture_TexelSize;

			float _Strength;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.maskUV = TRANSFORM_TEX(v.maskUV, _MaskTex);
				o.grabUV = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 maskCol = tex2D(_MaskTex, i.maskUV);
				fixed4 noiseCol = tex2D(_MainTex, i.uv);
				i.grabUV.xy += waveTexture_TexelSize.xy * noiseCol.rg * _Strength * maskCol.r;
				float4 grabColor = tex2Dproj(waveTexture, i.grabUV);
				return grabColor;
			}
			ENDCG
		}
	}
}
