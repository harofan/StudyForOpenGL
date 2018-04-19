//
//  AGLKView.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/19.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "AGLKView.h"
#import <QuartzCore/QuartzCore.h>

@interface AGLKView()
@property (assign, nonatomic, readwrite) GLsizei drawableWidth;
@property (assign, nonatomic, readwrite) GLsizei drawableHeight;
@end
@implementation AGLKView

#pragma mark - system
+ (Class)layerClass{
    //重写替换系统默认提供的layer,CAEAGLLayer会与一个
    //OpenGL ES的帧缓存共享他的像素颜色仓库
    return [CAEAGLLayer class];
}

- (void)drawRect:(CGRect)rect{
    if (_delegate && [_delegate respondsToSelector:@selector(aglkView:drawInRect:)]) {
        [_delegate aglkView:self drawInRect:rect];
    }
}

- (void)layoutSubviews{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
    //显示
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    
    //检查错误
    GLenum state = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    
    if (state != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"渲染失败,错误码:%d",state);
    }
}

- (void)dealloc{
    if (_context == [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:nil];
    }
    _context = nil;
}

#pragma mark - public
- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context{
    if (self = [super initWithFrame:frame]) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],
                                        //不使用保留背景,不要试图保留以前的用来重用
                                        kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8,
                                        //用8位保存每个像素的颜色
                                        kEAGLDrawablePropertyColorFormat,
                                        nil];
        self.context = context;
        
    }
    return self;
}

- (void)display{
    
    [EAGLContext setCurrentContext:self.context];
    //控制渲染至帧缓存的子集,这里是用的是整个帧缓存
    glViewport(0, 0, _drawableWidth, _drawableHeight);
    [self drawRect:[self bounds]];
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - set && get
- (void)setContext:(EAGLContext *)context{
    if (_context != context) {
        //删掉以前的
        [EAGLContext setCurrentContext:context];
        
        if (0 != _defaultFrameBuffer) {
            glDeleteFramebuffers(1, &_defaultFrameBuffer);
            _defaultFrameBuffer = 0;
        }
        
        if (0 != _colorRenderBuffer) {
            glDeleteRenderbuffers(1, &_colorRenderBuffer);
            _colorRenderBuffer = 0;
        }
        
        _context = context;
        
        if (nil != _context) {
            glGenFramebuffers(1, &_defaultFrameBuffer);
            glBindFramebuffer(GL_FRAMEBUFFER, _defaultFrameBuffer);
            
            glGenRenderbuffers(1, &_colorRenderBuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
            
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
        }
    }
}

- (GLsizei)drawableWidth{
    GLint backingWith;
    //返回当前上下文帧缓存的像素颜色渲染的缓存尺寸
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWith);
    return (GLsizei)backingWith;
}

- (GLsizei)drawableHeight{
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return (GLsizei)backingHeight;
}
@end
