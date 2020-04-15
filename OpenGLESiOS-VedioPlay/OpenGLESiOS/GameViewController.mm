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

GLuint vbo,gpuProgram,texture;
GLint posLocation,colorLocation,textureLocation,texcoordLocation;
char *frame[2];
int currentFrameIndex=0;
float color[]={0.5,0.3,0.1,1.0};

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
    //x,y,z float *3 *3
    float datas[]={
        -0.5f,-0.5f,0.0f,0.0f,0.0f,//position,texcoord
        0.5f,-0.5f,0.0f,1.0f,0.0f,//position,texcoord
        -0.5f,0.5f,0.0f,0.0f,1.0f,//position,texcoord
        
        0.5f,-0.5f,0.0f,1.0f,0.0f,//position,texcoord
        0.5f,0.5f,0.0f,1.0f,1.0f,//position,texcoord
        -0.5f,0.5f,0.0f,0.0f,1.0f//position,texcoord
    };
    //init data : transform data cpu ram -> gpu vram
    vbo=CreateBufferObject(GL_ARRAY_BUFFER, sizeof(float)*5*6, datas, GL_STATIC_DRAW);
    //init program : shader
    //happens on gpu
    //write source code : run on gpu : done
    char*vsCode=LoadAssetContent("Data/Shader/simple.vs");
    char*fsCode=LoadAssetContent("Data/Shader/simple.fs");
    
    gpuProgram=CreateGPUProgram(vsCode,fsCode);
    posLocation=glGetAttribLocation(gpuProgram, "pos");
    texcoordLocation=glGetAttribLocation(gpuProgram, "texcoord");
    colorLocation=glGetUniformLocation(gpuProgram, "U_Color");
    textureLocation=glGetUniformLocation(gpuProgram, "U_MainTexture");
    
    char*bmpFile=LoadAssetContent("Data/wood.bmp");
    int width=0,height=0;
    char*pixelData=DecodeBMP(bmpFile, width, height);
    frame[0]=pixelData;
    bmpFile=LoadAssetContent("Data/left.bmp");
    frame[1]=DecodeBMP(bmpFile, width, height);
    NSLog(@"texture width %d x %d",width,height);
    
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, pixelData);
    glBindTexture(GL_TEXTURE_2D, 0);
    
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
    static float sTimeSinceStart=0.0f;
    sTimeSinceStart+=0.033f;
    if(sTimeSinceStart>0.5f)
    {
        currentFrameIndex++;
        currentFrameIndex=currentFrameIndex%2;
        sTimeSinceStart=0.0f;
        glBindTexture(GL_TEXTURE_2D, texture);
        //rgb -> gpu
        //decode mp4 -> frames
        // pts
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, frame[currentFrameIndex]);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
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
    glUniform1i(textureLocation, 0);
    
    //set up args
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    //position -> shader
    //[position,color,position,color,position,color] -> attribute
    //int,short,byte -> float
    //0~255 -> 0.0~1.0
    glEnableVertexAttribArray(posLocation);
    glVertexAttribPointer(posLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float)*5, 0);
    
    glEnableVertexAttribArray(texcoordLocation);
    glVertexAttribPointer(texcoordLocation, 2, GL_FLOAT, GL_FALSE, sizeof(float)*5, (void*)(sizeof(float)*3));
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    //invoke
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glUseProgram(0);
}
@end
