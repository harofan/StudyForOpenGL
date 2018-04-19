//
//  AEAGLContext.h
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/19.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <GLKit/GLKit.h>
@interface AEAGLContext : EAGLContext

@property (assign, nonatomic) GLKVector4 clearColor;
- (void)clearMask:(GLbitfield)mask;
@end
