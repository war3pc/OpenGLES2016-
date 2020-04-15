//
//  GameViewController.m
//  OpenGLESiOS
//
//  Created by Heck on 2017/2/27.
//  Copyright © 2017年 battlefire. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#include "Utils.hpp"
#include "Glm/glm.hpp"
#include "Glm/ext.hpp"

GLuint vbo,gpuProgram,texture,ebo;
GLint posLocation,colorLocation,textureLocation,colorAttriLocation,MLocation,VLocation,PLocation;
float color[]={0.5,0.3,0.1,1.0};
float identity[]=
{
    1.0f,0.0f,0.0f,0.0f,
    0.0f,1.0f,0.0f,0.0f,
    0.0f,0.0f,1.0f,0.0f,
    0.0f,0.0f,0.0f,1.0f
};
glm::mat4 projection=glm::perspective(50.0f,640.0f/1136.0f,0.1f,100.0f);
glm::mat4 modelMatrix;
//x,y,z float *3 *3
struct Vertex
{
    float pos[3];
    float color[3];
};


char* LoadAssetContent(const char*path)
{
    char*assetContent=nullptr;
    NSString*nsPath=[[[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:path] ofType:nil]retain];
    NSData *data=[[NSData dataWithContentsOfFile:nsPath]retain];
    assetContent=new char[[data length]+1];
    memcpy(assetContent, [data bytes], [data length]);
    assetContent[[data length]]='\0';
    [nsPath release];
    [data release];
    return assetContent;
}

@interface GameViewController ()
{
}
@property (strong, nonatomic) EAGLContext *context;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //init opengl begin
    //init opengl render context
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];//3.0
    if(!self.context)
    {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];//2.0
    }
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    //
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;//24 bit depth buffer
    [EAGLContext setCurrentContext:self.context];//wglMakeCurrent
    
    //init opengl end
    
    //init scene data
    [self initScene];
}

-(void)initScene
{
    //init program : shader
    //happens on gpu
    //write source code : run on gpu : done
    char*vsCode=LoadAssetContent("Data/Shader/simple.vs");
    char*fsCode=LoadAssetContent("Data/Shader/simple.fs");
    
    gpuProgram=CreateGPUProgram(vsCode,fsCode);
    posLocation=glGetAttribLocation(gpuProgram, "pos");
    colorAttriLocation=glGetAttribLocation(gpuProgram, "color");
    colorLocation=glGetUniformLocation(gpuProgram, "U_Color");
    textureLocation=glGetUniformLocation(gpuProgram, "U_MainTexture");
    MLocation=glGetUniformLocation(gpuProgram, "M");
    VLocation=glGetUniformLocation(gpuProgram, "V");
    PLocation=glGetUniformLocation(gpuProgram, "P");
    
    texture=GenerateAlphaTexture(256);
    /*char*bmpFile=LoadAssetContent("Data/wood.bmp");
    int width=0,height=0;
    char*pixelData=DecodeBMP(bmpFile, width, height);
    
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, pixelData);
    glBindTexture(GL_TEXTURE_2D, 0);*/
    
    delete vsCode;
    delete fsCode;
    //delete bmpFile;
    Vertex vertexes[3];
    
    // : generate particle
    vertexes[0].pos[0]=-0.5f;
    vertexes[0].pos[1]=-0.5f;
    vertexes[0].pos[2]=-4.0f;
    vertexes[0].color[0]=0.5f;
    vertexes[0].color[1]=0.0f;
    vertexes[0].color[2]=0.0f;
    
    
    vertexes[1].pos[0]=0.5f;
    vertexes[1].pos[1]=-0.5f;
    vertexes[1].pos[2]=-4.0f;
    vertexes[1].color[0]=0.0f;
    vertexes[1].color[1]=0.5f;
    vertexes[1].color[2]=0.0f;
    
    
    vertexes[2].pos[0]=0.0f;
    vertexes[2].pos[1]=0.5f;
    vertexes[2].pos[2]=-4.0f;
    vertexes[2].color[0]=0.0f;
    vertexes[2].color[1]=0.0f;
    vertexes[2].color[2]=0.5f;
    //init data : transform data cpu ram -> gpu vram
    vbo=CreateBufferObject(GL_ARRAY_BUFFER, sizeof(Vertex)*3, vertexes, GL_STATIC_DRAW);
    unsigned short indexes[]={0,1,2};
    ebo=CreateBufferObject(GL_ELEMENT_ARRAY_BUFFER,sizeof(unsigned short)*3,indexes,GL_STATIC_DRAW);
}

- (void)dealloc
{
    [super dealloc];
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    //update : update drawable data
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.1f, 0.4f, 0.6f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    //render : render drawable data
    //invoke draw command
    ////->dc draw call
    //select program
    glUseProgram(gpuProgram);
    glUniform4fv(colorLocation,1, color);
    
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniformMatrix4fv(MLocation, 1, GL_FALSE, glm::value_ptr(modelMatrix));
    glUniformMatrix4fv(VLocation, 1, GL_FALSE, identity);
    glUniformMatrix4fv(PLocation, 1, GL_FALSE, glm::value_ptr(projection));
    glUniform1i(textureLocation, 0);
    
    //set up args
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    //position -> shader
    //[position,color,position,color,position,color] -> attribute
    //int,short,byte -> float
    //0~255 -> 0.0~1.0
    glEnableVertexAttribArray(posLocation);
    glVertexAttribPointer(posLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float)*6, 0);
    
    glEnableVertexAttribArray(colorAttriLocation);
    glVertexAttribPointer(colorAttriLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float)*6, (void*)(sizeof(float)*3));
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    //invoke
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,ebo);
    glDrawElements(GL_TRIANGLES,3,GL_UNSIGNED_SHORT,0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    //glDrawArrays(GL_TRIANGLES, 0, 3);
    glUseProgram(0);
}
@end
