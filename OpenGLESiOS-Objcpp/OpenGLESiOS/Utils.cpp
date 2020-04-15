//
//  Utils.cpp
//  OpenGLESiOS
//
//  Created by Heck on 2017/2/28.
//  Copyright © 2017年 battlefire. All rights reserved.
//

#include "Utils.hpp"

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

GLuint CreateBufferObject(GLenum objType,int objSize,void*data,GLenum usage)
{
    GLuint bufferObject;
    glGenBuffers(1, &bufferObject);
    glBindBuffer(GL_ARRAY_BUFFER, bufferObject);
    glBufferData(GL_ARRAY_BUFFER, objSize, data, usage);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    return bufferObject;
}
