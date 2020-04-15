attribute vec3 pos;

varying vec2 V_Texcoord;
void main()
{
    V_Texcoord=vec2(0.5)+pos.xy;
    gl_Position=vec4(pos*2.0,1.0);
}
