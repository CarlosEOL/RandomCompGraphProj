Shader "Custom/Toon"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Bump Texture", 2D) = "bump" {}
        _RampTex ("Ramp Texture (RGB)", 2D) = "white" {}
        _BumpAmount ("Bump Amount", Range(0,10)) = 1
        
        _Strength ("Wave Strength", Range(0, 100)) = 1
        _Speed ("Wave Speed", Range(0, 100)) = 1
        _SplashTex ("Splash Texture (RGB)", 2D) = "white" {}
        
        _OutlineWidth ("Outline Width", Range(0.0, 10)) = 0.005
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
    }
    SubShader // Base Albedo
    {
        Tags {"RenderType" = "Transparent"}
        
        Cull off
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf ToonRamp

        sampler2D _MainTex;
        sampler2D _RampTex;
        sampler2D _BumpMap;
        sampler2D _SplashTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        float4 LightingToonRamp (SurfaceOutput s, fixed3 lightDir, fixed atten){

            float diff = dot (s.Normal, lightDir);
            float h = diff * 0.5 + 0.5;
            float2 rh = h;

            // Add Ramp texture
            float3 ramp = tex2D(_RampTex, rh).rgb;

            float4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * (ramp);
            c.a = s.Alpha;
            return c;
        }

        half _BumpAmount;
        fixed4 _Color;
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Normal *= float3(_BumpAmount, _BumpAmount,1);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
        
        Pass // Vertex Editor - Waves
        {
            Cull off // Cull Everyface
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float _Strength;
            float _Speed;
            float4 _Color;
            sampler2D _MainTex;

            struct Input
            {
                float2 uv_MainTex;
            };
            
            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            

            v2f vert (VertexInput v)
            {
                v2f o;

                // THIS DOESN'T WORK BECAUSE _SinTime doesn't have "SINCESTARTUP".

                /* 
                float sinToSquare;
                
                if (_SinTime < 0)
                {
                    sinToSquare = 0;
                }
                else
                {
                    sinToSquare = 1; 
                }

                if (v.vertex.x % 2 == 0)
                {
                    sinToSquare = -sinToSquare;
                }
                
                v.vertex.x *= sinToSquare;

                */

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                float displacement = cos(worldPos.y) + cos(worldPos.x + (_Speed * _Time));

                worldPos.y = worldPos.y + (displacement * _Strength);

                o.vertex = mul(UNITY_MATRIX_VP, worldPos); //Now the displacement effect the vertex.
                //o.vertex = UnityObjectToClipPos(v.vertex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                
                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                // just invert the colors
                //col.rgb = 1 - col.rgb;
                return col;
            }
            
            ENDCG
        }
        
        Pass // Outline Cull
        {
            Cull front  

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                //float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                //float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 color : COLOR;
            };

            float _OutlineWidth;
            float4 _OutlineColor;

                v2f vert (appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);

                    float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
                    float2 offset = TransformViewToProjection(norm.xy);
                    
                    o.pos.xy += offset * o.pos.z * _OutlineWidth;
                    o.color = _OutlineColor;
                    //o.uv = v.uv;
                    return o;
                }

                //sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                //fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                //col.rgb = 1 - col.rgb;
                return i.color;
            }
            
            ENDCG
            }
        }
    FallBack "Diffuse"
}
