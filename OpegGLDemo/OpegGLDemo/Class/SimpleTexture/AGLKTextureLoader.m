//
//  AGLKTextureLoader.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/20.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "AGLKTextureLoader.h"

typedef NS_ENUM(size_t, AGLKPowerOf2){
    AGLK1 = 1,
    AGLK2 = 2,
    AGLK4 = 4,
    AGLK8 = 8,
    AGLK16 = 16,
    AGLK32 = 32,
    AGLK64 = 64,
    AGLK128 = 128,
    AGLK256 = 256,
    AGLK512 = 512,
    AGLK1024 = 1024,
};

@implementation AGLKTextureLoader

+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage
                                options:(NSDictionary *)options
                                  error:(NSError *__autoreleasing *)outError{
    
    size_t width = 0;
    size_t height = 0;
    NSData *imageData = AGLKDataWithResizedCGImageBytes(cgImage, &width, &height);
    
    //创建
    GLuint textureBufferID;
    glGenTextures(1, &textureBufferID);
    
    //绑定
    glBindBuffer(GL_TEXTURE_2D, textureBufferID);
    
    //拷贝数据到纹理缓冲区
    glTexImage2D(GL_TEXTURE_2D,//2D纹理
                 0,//MIP贴图的初始细节级别(没有MIP贴图的话必须为0)
                 GL_RGBA,//指定每个纹素需要保存的信息的数量
                 (GLsizei)width,//指定图像的宽高,必须是2的幂
                 (GLsizei)height,
                 0,//围绕纹素的一个边界的大小,在OpegGL ES中总是设置为0
                 GL_RGBA,//指定初始化缓存所使用图像数据中每个像素索要保存的信息,应与上面的一致
                 GL_UNSIGNED_BYTE,//指定缓存中的纹素数据所使用的位编码类型,使用这个会提供最佳的色彩质量
                 [imageData bytes]);//一个要被复制到绑定的纹理缓存中的图片的像素颜色数据的指针
    
    //设置纹理参数
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    AGLKTextureInfo *result = [[AGLKTextureInfo alloc] initWithName:textureBufferID
                                                             target:GL_TEXTURE_2D
                                                              width:width
                                                             height:height];
    
    return result;
}

static NSData *AGLKDataWithResizedCGImageBytes(CGImageRef cgImage,
                                        size_t *widthPtr,
                                        size_t *heightPtr){
    
    
    NSCParameterAssert(NULL != cgImage);
    NSCParameterAssert(NULL != widthPtr);
    NSCParameterAssert(NULL != heightPtr);
    
    size_t originalWidth = CGImageGetWidth(cgImage);
    size_t originalHeight = CGImageGetHeight(cgImage);
    
    NSCAssert(0 < originalWidth, @"width must > 0");
    NSCAssert(0 < originalHeight, @"height must > 0");
    
    //获得一个最接近2次方的数
    size_t width = AGLKCalculatePowerOf2ForDimension((GLuint)originalWidth);
    size_t height = AGLKCalculatePowerOf2ForDimension((GLuint)originalHeight);
    
    //分配存储空间,一个点的RGBA要占据四个字节
    NSMutableData *imageData = [NSMutableData dataWithLength:height * width * 4];
    
    NSCAssert(nil != imageData, @"Unable to allocate image storage");
    
    //将图像画入新的上下文
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext = CGBitmapContextCreate([imageData mutableBytes], width, height, 8,
                                                   4 * width, colorSpace,
                                                   kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    //翻转Y轴,OpegGL ES的Y轴是向上的,iPhone坐标系是向下的
    CGContextTranslateCTM (cgContext, 0, height);
    CGContextScaleCTM (cgContext, 1.0, -1.0);
    
    //根据需要绘图
    CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height), cgImage);
    
    CGContextRelease(cgContext);
    *widthPtr = width;
    *heightPtr = height;
    
    return [imageData copy];
}

//该函数能将参数最接近的2次方数返回,返回值不大于1024
static AGLKPowerOf2 AGLKCalculatePowerOf2ForDimension(GLuint dimension)
{
    AGLKPowerOf2  result = AGLK1;
    
    if(dimension > (GLuint)AGLK512)
    {
        result = AGLK1024;
    }
    else if(dimension > (GLuint)AGLK256)
    {
        result = AGLK512;
    }
    else if(dimension > (GLuint)AGLK128)
    {
        result = AGLK256;
    }
    else if(dimension > (GLuint)AGLK64)
    {
        result = AGLK128;
    }
    else if(dimension > (GLuint)AGLK32)
    {
        result = AGLK64;
    }
    else if(dimension > (GLuint)AGLK16)
    {
        result = AGLK32;
    }
    else if(dimension > (GLuint)AGLK8)
    {
        result = AGLK16;
    }
    else if(dimension > (GLuint)AGLK4)
    {
        result = AGLK8;
    }
    else if(dimension > (GLuint)AGLK2)
    {
        result = AGLK4;
    }
    else if(dimension > (GLuint)AGLK1)
    {
        result = AGLK2;
    }
    
    return result;
}

@end
