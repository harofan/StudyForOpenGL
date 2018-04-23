//
//  AGLKTextureLoader.h
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/20.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGLKTextureInfo.h"

@interface AGLKTextureLoader : NSObject

+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage
                                options:(NSDictionary *)options
                                  error:(NSError **)outError;
@end
