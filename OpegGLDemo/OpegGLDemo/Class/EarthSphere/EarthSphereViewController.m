//
//  EarthSphereViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/5/15.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "EarthSphereViewController.h"
#import <GLKit/GLKit.h>
#import "AGLKVertexAttribArrayBuffer.h"
#import "sphere.h"//顶点数据

@interface EarthSphereViewController ()<GLKViewDelegate>
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;
@property (strong, nonatomic) GLKView *glkView;
@end

@implementation EarthSphereViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    GLKView *glkView = [GLKView new];
    self.glkView = glkView;
    glkView.delegate = self;
    glkView.frame = CGRectMake(0, 0, 375, 667);
    [self.view addSubview:glkView];
    
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glkView.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f);
    self.baseEffect.light0.position = GLKVector4Make(1.0f, 0.0f, -0.8f, 0.0f);
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f);
    
    //设置纹理
    CGImageRef imageRef = [[UIImage imageNamed:@"Earth512x256.jpg"] CGImage];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef
                                                               options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil]
                                                                 error:NULL];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat))
                                                                         numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat))
                                                                                     data:sphereVerts
                                                                                    usage:GL_STATIC_DRAW];
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat))
                                                                       numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat))
                                                                                   data:sphereNormals
                                                                                  usage:GL_STATIC_DRAW];
    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(2 * sizeof(GLfloat))
                                                                             numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat))
                                                                                         data:sphereTexCoords
                                                                                        usage:GL_STATIC_DRAW];
    
    glEnable(GL_DEPTH_TEST);

    //不再调一次视图的y坐标就还有问题
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [glkView display];
    });

}

- (void)dealloc{
    self.vertexPositionBuffer = nil;
    self.vertexNormalBuffer = nil;
    self.vertexTextureCoordBuffer = nil;
    
    self.glkView.context = nil;
    [EAGLContext setCurrentContext:nil];
}

#pragma mark - delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    [self.baseEffect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

    [self.vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                                    numberOfCordinates:3
                                          attribOffset:0
                                          shouldEnable:YES];
    [self.vertexNormalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
                                  numberOfCordinates:3
                                        attribOffset:0
                                        shouldEnable:YES];
    [self.vertexTextureCoordBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                                        numberOfCordinates:2
                                              attribOffset:0
                                              shouldEnable:YES];
    
    //缩放y坐标,改变宽高比
    const GLfloat  aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    //X Z方向上为1.0则不变换
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeScale(1.0f, aspectRatio, 1.0f);

    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);

}
@end
