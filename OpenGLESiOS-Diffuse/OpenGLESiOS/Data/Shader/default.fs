precision mediump float;

varying vec3 V_Normal;

void main()
{
    //ambient color
    vec4 ambientLight=vec4(0.4,0.4,0.4,1.0);//ambient light
    vec4 ambientMaterial=vec4(0.4,0.4,0.4,1.0);//ambient material
    vec4 diffuseLight=vec4(1.0,1.0,1.0,1.0);//diffuse light
    vec4 diffuseMaterial=vec4(0.4,0.4,0.4,1.0);//diffuse material
    vec4 ambientColor=ambientLight*ambientMaterial;
    //diffuse color
    vec3 L=vec3(0.0,1.0,0.0);
    vec3 n=normalize(V_Normal);
    float diffuseIntensity=max(0.0,dot(L,n));
    
    vec4 diffuseColor=diffuseLight*diffuseMaterial*diffuseIntensity;
    //specular color
    vec4 specularColor=vec4(0.0);
    gl_FragColor=ambientColor+diffuseColor+specularColor;
}
