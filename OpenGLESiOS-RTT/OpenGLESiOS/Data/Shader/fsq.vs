attribute vec3 pos;

void main()
{
    gl_PointSize=200.0;
    gl_Position=vec4(pos,1.0);
}
