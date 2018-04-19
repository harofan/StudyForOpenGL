//
//  AGLKView.h
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/19.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EAGLContext;
@class AGLKView;

@protocol AGLViewDelegate <NSObject>
@required
- (void)aglkView:(AGLKView *)view drawInRect:(CGRect)rect;
@end

@interface AGLKView : UIView{
    EAGLContext *_context;
    GLuint _defaultFrameBuffer;
    GLuint _colorRenderBuffer;
}

@property (weak, nonatomic) id <AGLViewDelegate> delegate;
@property (strong, nonatomic) EAGLContext *context;
@property (assign, nonatomic, readonly) GLsizei drawableWidth;
@property (assign, nonatomic, readonly) GLsizei drawableHeight;

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context;
- (void)display;

@end
