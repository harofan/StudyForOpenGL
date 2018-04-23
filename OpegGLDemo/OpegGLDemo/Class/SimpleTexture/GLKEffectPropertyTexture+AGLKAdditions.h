//
//  GLKEffectPropertyTexture+AGLKAdditions.h
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/23.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID
                   value:(GLint)value;
@end
