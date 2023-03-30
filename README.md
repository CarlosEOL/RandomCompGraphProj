## Deferred and Foward Lightning: 
	
Deferred Lightning is referenced to the lightning model that does not include tracking the lightning dir directly from each light source, it supports using only one pass for the entire texture material. It uses a screen-space rendering technique that usually is incompatible with transparency. The deferred lighting goes through G-Buffer that processes world normal, z-buffer, and color before applying the final combined image.

Forward Lightning supports directional lighting with shadows because it traces the light directly from the source. Hence, a better-looking light. If there are multiple light sources, the pass will run as many times as the number of light sources.


But with enough passes for deferred lightning, it can look like forward lightning, except the shadow will always be less accurately rendered.

	
### Scene:
	
	With a light source, an object, and a camera. Using forward lightning, we can calculate the halfway vector using light direction and object world position, then use this halfway vector to calculate the light that has bounced to the camera - hence, a simple Lambertian diffuse. we can also use a normal map to change the vertex normal and then redirect each light ray.



Then we use diffuse and multiply to our albedo colour to get the shader * Color.

## Task 3 - Recreate the scene:


Not sure how to get square waves but I have something similar: cosine wave.
Gameplay Scene:

Code:
(Properties)


(Second pass): Vertex Manipulation


cos(worldPos.y) is what is used to create waves along the y-axis. This is the second pass.

Third Pass (Outline)


“Cull front” so only the backface is visible.

Get the vertex by calling vertex world pos in VertexInpt v using vertex shader object so it can be initialized, then get vertex normal and normalize it to get a unified direction vector.

“TransformViewToProjection” because on the last line, only MV is used. So the outline can fit with the screen resolution. 





Returns the Vertex Color for Fragment.




Explain Code Snippet: “Colored Shadow”





Lambertian shading returns a maxed (limited from 0 to 1) dot product of normal and lightDir vectors, which are then used to multiply with the albedo color. Attenuation is used to reduce the amount of shadow, in this case, it is reduced by 0.5 and then added by 0.5 so it’s always above 0.5. This is the shading technique that doesn’t use a camera dir and the shadow is applied directly to the object/material.


