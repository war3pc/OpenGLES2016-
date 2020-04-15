//
//  Shader.fsh
//  OpenGLESiOS
//
//  Created by Heck on 2017/2/27.
//  Copyright © 2017年 battlefire. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
