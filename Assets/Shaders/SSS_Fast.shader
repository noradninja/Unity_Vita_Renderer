﻿Shader "Vita/SSS Fast" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap ("Normal (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Distortion ("Distortion", Range(0,1)) = 0.5
		_Power ("Power", Range(0,5)) = 1.0
		_Scale ("Scale", Range(0,5)) = 1.0
	}
	SubShader {
		Tags {"Queue"="Geometry" "RenderType"="Opaque"}
		ZWrite On
		Blend One Zero

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf SSSTranslucent fullforwardshadows 
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D_half _MainTex;
		sampler2D_half _BumpMap;

		struct Input {
			half2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		half4 _Color;
		half _Distortion;
		half _Power;
		half _Scale;

		#include "UnityPBSLighting.cginc"
		inline half4 LightingSSSTranslucent(SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
		{
			// original color 
			half4 c = LightingStandard(s, viewDir, gi);

			half3 lightDir = gi.light.dir;
			half3 normal = s.Normal;

			half3 H = lightDir + _Distortion * normal;
			half VdotH = pow(saturate(dot(viewDir, -H)), _Power) * _Scale;
 
			c.rgb += gi.light.color * VdotH;
			return c;
		}
 
		void LightingSSSTranslucent_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
		{
			LightingStandard_GI(s, data, gi); 
		}
 
		


		// the following are in the standard surface shader

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex)); //unpack and scale normal map- we have to do this first so reflections get per pixel normals
			//o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}