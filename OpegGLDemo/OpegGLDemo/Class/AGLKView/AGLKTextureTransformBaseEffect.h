//
//  AGLKTextureTransformBaseEffect.h
//  OpegGLDemo
//
//  Created by 范杨 on 2018/5/18.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface AGLKTextureTransformBaseEffect : GLKBaseEffect

@property (assign) GLKVector4 light0Position;
@property (assign) GLKVector3 light0SpotDirection;
@property (assign) GLKVector4 light1Position;
@property (assign) GLKVector3 light1SpotDirection;
@property (assign) GLKVector4 light2Position;
@property (nonatomic, assign) GLKMatrix4 textureMatrix2d0;
@property (nonatomic, assign) GLKMatrix4 textureMatrix2d1;

- (void)prepareToDrawMultitextures;

@end

@interface GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID
                   value:(GLint)value;

@end
