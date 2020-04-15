//
//  GameViewController.m
//  OpenGLESiOS
//
//  Created by Heck on 2017/2/27.
//  Copyright © 2017年 battlefire. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>

GLuint vbo,gpuProgram;

char*vertexShader="attribute vec3 pos;\n"
"void main()\n"
"{\n"
"gl_Position=vec4(pos,1.0);\n"
"}\n";
char*fragmentShader="void main()\n"
"{\n"
"gl_FragColor=vec4(1.0);\n"
"}\n";

//vertex shdader,fragment shader
GLuint CompileShader(GLenum shaderType,const char*code)
{
    //create shader object in gpu
    GLuint shader=glCreateShader(shaderType);
    //transform src to gpu & asign to the shader object
    glShaderSource(shader, 1, &code, NULL);
    glCompileShader(shader);
    GLint compileStatus=GL_TRUE;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    if(compileStatus==GL_FALSE)
    {
        printf("compile shader error,shader code is : %s\n",code);
        char szBuffer[1024]={0};
        GLsizei logLen=0;
        glGetShaderInfoLog(shader, 1024, &logLen, szBuffer);
        printf("error log : %s\n",szBuffer);
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

GLuint CreateGPUProgram(const char*vsCode,const char*fscode)
{
    GLuint program;
    //compile source code
    //.cpp .mm .m -> .o
    GLuint vsShader=CompileShader(GL_VERTEX_SHADER, vsCode);
    GLuint fsShader=CompileShader(GL_FRAGMENT_SHADER, fscode);
    //link .o -> executable file
    program=glCreateProgram();
    glAttachShader(program, vsShader);
    glAttachShader(program, fsShader);
    glLinkProgram(program);
    GLint programStatus=GL_TRUE;
    glGetProgramiv(program, GL_LINK_STATUS, &programStatus);
    if(GL_FALSE==programStatus)
    {
        printf("link program error!");
        char szBuffer[1024]={0};
        GLsizei logLen=0;
        glGetProgramInfoLog(program, 1024, &logLen, szBuffer);
        printf("link error : %s\n",szBuffer);
        glDeleteProgram(program);
        return 0;
    }
    return program;
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
    float positions[]={
        -0.5f,0.0f,0.0f,
        0.5f,0.0f,0.0f,
        0.0f,0.5f,0.0f
    };
    //init data : transform data cpu ram -> gpu vram
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(float)*9, positions, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    //init program : shader
    //happens on gpu
    //write source code : run on gpu : done
    gpuProgram=CreateGPUProgram(vertexShader,fragmentShader);
    //render command
}

- (void)dealloc
{    
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
    //set up args
    //invoke
}
@end
