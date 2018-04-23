//
//  GLKEffectPropertyTexture+AGLKAdditions.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/23.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "GLKEffectPropertyTexture+AGLKAdditions.h"

@implementation GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID
                   value:(GLint)value;
{
    glBindTexture(self.target, self.name);
    glTexParameteri(self.target,
                    parameterID,
                    value);
}

@end
