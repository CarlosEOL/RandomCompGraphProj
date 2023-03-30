Shader "ColoredShadow" //Shader Name/class
{
    Properties{ // Material Properties that can be viewed on the editor, and can be called from different passes
    _Color("Main Color", Color) = (1,1,1,1) // float4 Color
    _MainTex("Base (RGB)", 2D) = "white" {} // Texture2D, float4 color
    _ShadowColor("Shadow Color", Color) = (1,1,1,1) //float4 Color
    }
    SubShader{ 
        
        //Main Pass
        
    Tags { "RenderType" = "Opaque" } // used to change the tag of render queue
    LOD 200 //Level of detail
        
    CGPROGRAM // Start
    
    #pragma surface surf CSLambert // Define surface name and shading method
    
    sampler2D _MainTex;
    fixed4 _Color; 
    fixed4 _ShadowColor;
    
    struct Input {
    float2 uv_MainTex; // Use to hold U.V Coord
    };
    
    half4 LightingCSLambert(SurfaceOutput s, half3 lightDir, half atten) { // Casting shadow on the object from directional light to camera
        
        fixed diff = max(0, dot(s.Normal, lightDir)); // Diffuse using light direction and vertex normal dir
        
        half4 c; // same as float4 but half is a smaller type that can hold number to 255.
        c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 0.5);
        // Light color is default black, so half4 (1,1,1,1), multiplied be albedo colour and diffuse shading color to get final shading.
        
        //shadow color
        c.rgb += _ShadowColor.xyz * (1.0 - atten);
        c.a = s.Alpha;
        return c;
    }
    
    void surf(Input IN, inout SurfaceOutput o) { // Outputs material properties
        half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
        o.Albedo = c.rgb;
        o.Alpha = c.a;
    }
    ENDCG
    }
    Fallback "Diffuse" // if CG fails, use the default pink diffuse color
    }