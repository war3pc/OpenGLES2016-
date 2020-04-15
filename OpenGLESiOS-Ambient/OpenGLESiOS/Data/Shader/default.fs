precision mediump float;


void main()
{
    //ambient color
    vec4 ambientLight=vec4(0.4,0.4,0.4,1.0);//ambient light
    vec4 ambientMaterial=vec4(0.4,0.4,0.4,1.0);//ambient material
    vec4 ambientColor=ambientLight*ambientMaterial;
    //diffuse color
    vec4 diffuseColor=vec4(0.0);
    //specular color
    vec4 specularColor=vec4(0.0);
    gl_FragColor=ambientColor+diffuseColor+specularColor;
}
