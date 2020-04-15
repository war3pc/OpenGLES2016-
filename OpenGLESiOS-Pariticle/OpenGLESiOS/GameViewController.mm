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

GLuint vbo,gpuProgram,texture;
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
//x,y,z float *3 *3
float r1=frandom(),r2=frandom(),r3=frandom();
float datas[]=
{
    -0.5f,-0.5f,-4.0f,r1,r1,r1,//position,color
    0.5f,-0.5f,-4.0f,r2,r2,r2,//position,color
    -0.5f,0.5f,-4.0f,r3,r3,r3//position,color
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
    //init data : transform data cpu ram -> gpu vram
    vbo=CreateBufferObject(GL_ARRAY_BUFFER, sizeof(float)*6*3, datas, GL_STATIC_DRAW);
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
    glBindTexture(GL_TEXTURE_2D, 0);
    */
    delete vsCode;
    delete fsCode;
    //delete bmpFile;
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
    float p1=datas[4];
    static bool fadeIn=false;
    if(fadeIn)
    {
        p1-=0.05f;
        if(p1<=0.4f)
        {
            p1=0.4f;
            fadeIn=false;
        }
    }
    else
    {
        p1+=0.05f;
        if(p1>=1.0f)
        {
            p1=1.0f;
            fadeIn=true;
        }
    }
    
    datas[3]=p1;
    datas[4]=p1;
    datas[5]=p1;
    glBindBuffer(GL_ARRAY_BUFFER,vbo);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(float)*6*3, datas);
    glBindBuffer(GL_ARRAY_BUFFER,0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.1f, 0.4f, 0.6f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    //render : render drawable data
    //invoke draw command
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    ////->dc draw call
    //select program
    glUseProgram(gpuProgram);
    glUniform4fv(colorLocation,1, color);
    
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniformMatrix4fv(MLocation, 1, GL_FALSE, identity);
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
    glDrawArrays(GL_POINTS, 0, 3);
    glUseProgram(0);
}
@end
