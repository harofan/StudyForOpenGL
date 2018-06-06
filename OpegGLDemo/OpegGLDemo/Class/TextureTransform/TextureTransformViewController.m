//
//  TextureTransformViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/5/18.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "TextureTransformViewController.h"
#import <GLKit/GLKit.h>
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKTextureTransformBaseEffect.h"

@interface TextureTransformViewController ()

@property (strong, nonatomic) AGLKTextureTransformBaseEffect *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (assign, nonatomic) CGFloat textureScaleFactor;
@property (assign, nonatomic) CGFloat textureAngle;
@property (nonatomic) GLKMatrixStackRef textureMatrixStack;

@end

typedef struct {
    GLKVector3  positionCoords;
    GLKVector2  textureCoords;
}SceneVertex;

static const SceneVertex vertices[] =
{
    {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}},  // first triangle
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},  // second triangle
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
};

@implementation TextureTransformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.textureMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
}

- (IBAction)changeScaleSlider:(id)sender {
}
- (IBAction)changeRotateSlider:(id)sender {
}

@end
