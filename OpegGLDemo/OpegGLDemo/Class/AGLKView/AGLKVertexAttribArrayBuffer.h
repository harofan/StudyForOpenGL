//
//  AGLKVertexAttribArrayBuffer.h
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/19.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface AGLKVertexAttribArrayBuffer : NSObject

@property (assign, nonatomic, readonly) GLuint glName;
@property (assign, nonatomic, readonly) GLsizeiptr bufferSizeBytes;
@property (assign, nonatomic, readonly) GLsizeiptr stride;

- (instancetype)initWithAttribStride:(GLsizeiptr)stride
          numberOfVertices:(GLsizei)count
                      data:(const GLvoid *)dataPtr
                     usage:(GLenum)usage;

- (void)prepareToDrawWithAttrib:(GLuint)index
             numberOfCordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable;

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count;

- (void)reinitWithAttribStride:(GLsizeiptr)stride
              numberOfVertices:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr;
@end
