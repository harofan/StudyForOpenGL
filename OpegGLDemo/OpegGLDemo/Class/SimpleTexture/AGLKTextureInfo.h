//
//  AGLKTextureInfo.h
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/20.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//


#import <GLKit/GLKit.h>

@interface AGLKTextureInfo : NSObject

@property (assign, nonatomic, readonly) GLuint name;
@property (assign, nonatomic, readonly) GLenum target;
@property (assign, nonatomic, readonly) GLuint width;
@property (assign, nonatomic, readonly) GLuint height;

- (instancetype)initWithName:(GLuint)name
                      target:(GLenum)target
                       width:(GLuint)width
                      height:(GLuint)height;
@end
