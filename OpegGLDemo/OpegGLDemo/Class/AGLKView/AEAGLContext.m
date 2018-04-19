//
//  AEAGLContext.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/19.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "AEAGLContext.h"

@implementation AEAGLContext

- (void)setClearColor:(GLKVector4)clearColor{
    _clearColor = clearColor;
    glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
}

- (void)clearMask:(GLbitfield)mask{
    glClear(mask);
}
@end
