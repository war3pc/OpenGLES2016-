//
//  GameViewController.m
//  OpenGLESiOS
//
//  Created by Heck on 2017/2/27.
//  Copyright © 2017年 battlefire. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES3/glext.h>
#include "Utils.hpp"
#include "Glm/glm.hpp"
#include "Glm/ext.hpp"

GLuint vbo,gpuProgram,texture,tfoProgram,tfoVBO;
GLint posLocation,colorLocation,textureLocation,posLocationTFO,MLocation,VLocation,PLocation;
float color[]={0.5,0.3,0.1,1.0};
float identity[]=
{
    1.0f,0.0f,0.0f,0.0f,
    0.0f,1.0f,0.0f,0.0f,
    0.0f,0.0f,1.0f,0.0f,
    0.0f,0.0f,0.0f,1.0f
};
glm::mat4 projection=glm::perspective(50.0f,640.0f/1136.0f,0.1f,100.0f);
glm::mat4 modelMatrix=glm::rotate(45.0f,0.0f,0.0f,1.0f);

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

void InitTFOProgram()
{
    char*vsCode=LoadAssetContent("Data/Shader/feedback.vs");
    char*fsCode=LoadAssetContent("Data/Shader/feedback.fs");
    GLuint vsShader=CompileShader(GL_VERTEX_SHADER, vsCode);
    GLuint fsShader=CompileShader(GL_FRAGMENT_SHADER, fsCode);
    //
    //link .o -> executable file
    tfoProgram=glCreateProgram();
    glAttachShader(tfoProgram, vsShader);
    glAttachShader(tfoProgram, fsShader);
    const char*valueToCapture[]={"gl_Position"};
    glTransformFeedbackVaryings(tfoProgram, 1, valueToCapture, GL_INTERLEAVED_ATTRIBS);
    
    glLinkProgram(tfoProgram);
    glDetachShader(tfoProgram, vsShader);
    glDetachShader(tfoProgram, fsShader);
    glDeleteShader(vsShader);
    glDeleteShader(fsShader);
    GLint programStatus=GL_TRUE;
    glGetProgramiv(tfoProgram, GL_LINK_STATUS, &programStatus);
    if(GL_FALSE==programStatus)
    {
        printf("link program error!");
        char szBuffer[1024]={0};
        GLsizei logLen=0;
        glGetProgramInfoLog(tfoProgram, 1024, &logLen, szBuffer);
        printf("link error : %s\n",szBuffer);
        glDeleteProgram(tfoProgram);
        tfoProgram=0;
    }
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
    float datas[]=
    {
        -0.5f,-0.5f,-4.0f,1.0f,//position
        0.5f,-0.5f,-4.0f,1.0f,//position
        -0.5f,0.5f,-4.0f,1.0f//position
    };
    //init data : transform data cpu ram -> gpu vram
    vbo=CreateBufferObject(GL_ARRAY_BUFFER, sizeof(float)*4*3, datas, GL_STATIC_DRAW);
    tfoVBO=CreateBufferObject(GL_ARRAY_BUFFER, sizeof(float)*4*3, nullptr, GL_STATIC_DRAW);
    //init program : shader
    //happens on gpu
    //write source code : run on gpu : done
    char*vsCode=LoadAssetContent("Data/Shader/simple.vs");
    char*fsCode=LoadAssetContent("Data/Shader/simple.fs");
    
    gpuProgram=CreateGPUProgram(vsCode,fsCode);
    posLocation=glGetAttribLocation(gpuProgram, "pos");
    colorLocation=glGetUniformLocation(gpuProgram, "U_Color");
    textureLocation=glGetUniformLocation(gpuProgram, "U_MainTexture");
    VLocation=glGetUniformLocation(gpuProgram, "V");
    PLocation=glGetUniformLocation(gpuProgram, "P");
    
    texture=GenerateAlphaTexture(256);
    delete vsCode;
    delete fsCode;
    //delete bmpFile;
    InitTFOProgram();
    MLocation=glGetUniformLocation(tfoProgram, "M");
    posLocationTFO=glGetAttribLocation(tfoProgram, "pos");
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
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //render vbo data -> tfo vbo , model matrix
    glEnable(GL_RASTERIZER_DISCARD);
    glUseProgram(tfoProgram);
    glUniformMatrix4fv(MLocation, 1, GL_FALSE, glm::value_ptr(modelMatrix));
    //set up args
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glEnableVertexAttribArray(posLocationTFO);
    glVertexAttribPointer(posLocationTFO, 4, GL_FLOAT, GL_FALSE, sizeof(float)*4, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER,0,tfoVBO);
    glBeginTransformFeedback(GL_POINTS);
    glDrawArrays(GL_POINTS, 0, 3);
    glEndTransformFeedback();
    
    glUseProgram(0);
    glDisable(GL_RASTERIZER_DISCARD);
    
    //render tfo vbo -> screen : view matrix projection matrix
    //select program
    glUseProgram(gpuProgram);
    glUniform4fv(colorLocation,1, color);
    
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniformMatrix4fv(VLocation, 1, GL_FALSE, identity);
    glUniformMatrix4fv(PLocation, 1, GL_FALSE, glm::value_ptr(projection));
    glUniform1i(textureLocation, 0);
    
    //set up args
    glBindBuffer(GL_ARRAY_BUFFER, tfoVBO);
    glEnableVertexAttribArray(posLocation);
    glVertexAttribPointer(posLocation, 4, GL_FLOAT, GL_FALSE, sizeof(float)*4, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    //invoke
    glDrawArrays(GL_POINTS, 0, 3);
    glUseProgram(0);
}
@end
