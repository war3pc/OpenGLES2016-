precision mediump float;

uniform sampler2D U_MainTexture;
varying vec2 V_Texcoord;

void main()
{
    float offsetUnitX=1.0/640.0;
    float offsetUnitY=1.0/1136.0;
    vec2 offsets[9];
    // 1 2 1 (? ~ ?)
    // 2 *(4) 2 (3~5)
    // 1 2 1 (0~2)
    offsets[0]=vec2(-offsetUnitX,-offsetUnitY);
    offsets[1]=vec2(0,-offsetUnitY);
    offsets[2]=vec2(offsetUnitX,-offsetUnitY);
    
    offsets[3]=vec2(-offsetUnitX,0);
    offsets[4]=vec2(0,0);
    offsets[5]=vec2(offsetUnitX,0);
    
    offsets[6]=vec2(-offsetUnitX,offsetUnitY);
    offsets[7]=vec2(0,offsetUnitY);
    offsets[8]=vec2(offsetUnitX,offsetUnitY);
    float weight[9];
    weight[6]=1.0;weight[7]=2.0;weight[8]=1.0;
    weight[3]=2.0;weight[4]=4.0;weight[5]=2.0;
    weight[0]=1.0;weight[1]=2.0;weight[2]=1.0;
    vec3 color=vec3(0.0);
    for (int i=0; i<9; i++) {
        color+=texture2D(U_MainTexture,V_Texcoord+offsets[i]).xyz*weight[i];
    }
    color/=16.0;
    gl_FragColor=vec4(color,1.0);
}
