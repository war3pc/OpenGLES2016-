precision mediump float;

uniform sampler2D U_MainTexture;
varying vec2 V_Texcoord;

void main()
{
    vec4 color=texture2D(U_MainTexture,V_Texcoord);
    float gray=(color.r+color.g+color.b)/3.0;
    gl_FragColor=vec4(gray,gray,gray,1.0);
}
