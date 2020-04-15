
precision mediump float;

uniform vec4 U_Color;
uniform sampler2D U_MainTexture;

void main()
{
    gl_FragColor=vec4(U_Color.rgb,texture2D(U_MainTexture,gl_PointCoord.xy).a);
}
