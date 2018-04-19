//
//  AGLKVertexAttribArrayBuffer.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/19.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "AGLKVertexAttribArrayBuffer.h"

@interface AGLKVertexAttribArrayBuffer()
@property (assign, nonatomic, readwrite) GLuint glName;
@property (assign, nonatomic, readwrite) GLsizeiptr bufferSizeBytes;
@property (assign, nonatomic, readwrite) GLsizeiptr stride;
@end

@implementation AGLKVertexAttribArrayBuffer

- (instancetype)initWithAttribStride:(GLsizeiptr)stride
          numberOfVertices:(GLsizei)count
                      data:(const GLvoid *)dataPtr
                     usage:(GLenum)usage{
    
    NSParameterAssert(0 < stride);
    NSParameterAssert(0 < count);
    NSParameterAssert(NULL != dataPtr);
    
    if (nil != (self = [super init])) {
        _stride = stride;
        _bufferSizeBytes = stride * count;
        
        glGenBuffers(1, &_glName);
        glBindBuffer(GL_ARRAY_BUFFER, self.glName);
        glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, dataPtr, usage);
        
        NSAssert(0 != _glName, @"生成glname失败");
    }
    return self;
}

- (void)prepareToDrawWithAttrib:(GLuint)index
             numberOfCordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable{
    
    NSParameterAssert((0 < count) && (count < 4));
    NSParameterAssert(offset < self.stride);
    NSAssert(0 != _glName, @"无效glname");
    
    glBindBuffer(GL_ARRAY_BUFFER, self.glName);
    
    if (shouldEnable) {
        glEnableVertexAttribArray(index);
    }
    
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, (GLsizei)self.stride, NULL + offset);
}

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count{
    
    NSAssert(self.bufferSizeBytes >= ((first + count) * self.stride), @"越界");
    glDrawArrays(mode, first, count);
}

- (void)dealloc{
    if (0 != _glName) {
        glDeleteBuffers(1, &_glName);
        _glName = 0;
    }
}
@end
