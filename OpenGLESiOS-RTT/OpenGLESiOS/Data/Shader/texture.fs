precision mediump float;

uniform sampler2D U_MainTexture;

void main()
{
    gl_FragColor=texture2D(U_MainTexture,vec2(gl_PointCoord.x,-gl_PointCoord.y));
}
