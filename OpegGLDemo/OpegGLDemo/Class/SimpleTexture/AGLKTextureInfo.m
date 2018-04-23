//
//  AGLKTextureInfo.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/20.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "AGLKTextureInfo.h"

@interface AGLKTextureInfo()
@property (assign, nonatomic, readwrite) GLuint name;
@property (assign, nonatomic, readwrite) GLenum target;
@property (assign, nonatomic, readwrite) GLuint width;
@property (assign, nonatomic, readwrite) GLuint height;
@end
@implementation AGLKTextureInfo

- (instancetype)initWithName:(GLuint)name
                      target:(GLenum)target
                       width:(GLuint)width
                      height:(GLuint)height{
    if (self = [super init]) {
        _name = name;
        _target = target;
        _width = width;
        _height = height;
    }
    return self;
}
@end
