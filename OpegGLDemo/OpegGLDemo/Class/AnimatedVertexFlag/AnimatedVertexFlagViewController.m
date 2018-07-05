//
//  AnimatedVertexFlagViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/7/5.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "AnimatedVertexFlagViewController.h"
#import "SceneAnimatedMesh.h"

@interface AnimatedVertexFlagViewController ()<GLKViewDelegate>
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) SceneAnimatedMesh *animatedMesh;
@property (strong, nonatomic) GLKView *glkView;
@end

@implementation AnimatedVertexFlagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    GLKView *glkView = (GLKView *)self.view;
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    self.glkView = glkView;
    [EAGLContext setCurrentContext:glkView.context];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, 0, 100, 50)];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    // Configure a light
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.6f, // Red
                                                         0.6f, // Green
                                                         0.6f, // Blue
                                                         1.0f);// Alpha
    
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f, // Red
                                                         1.0f, // Green
                                                         1.0f, // Blue
                                                         1.0f);// Alpha
    
    self.baseEffect.light0.position = GLKVector4Make(1.0f,
                                                     0.8f,
                                                     0.4f,
                                                     0.0f);
    
    glClearColor(0.0f, // Red
                 0.0f, // Green
                 0.0f, // Blue
                 1.0f);// Alpha
    
    //创建网格
    _animatedMesh = [[SceneAnimatedMesh alloc] init];
    
    //设置modelview矩阵匹配当前眼睛位置和观察位置
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(20, 25, 5,
                                                                     20, 0, -15,
                                                                     0, 1, 0);
    glEnable(GL_DEPTH_TEST);
}

//支持旋转
-(BOOL)shouldAutorotate{
    return YES;
}
//
//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft;
}

//一开始的方向  很重要
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)update{
//    [self.glkView display];
}
- (void)dealloc{
    
    [EAGLContext setCurrentContext:self.glkView.context];
    self.glkView.context = nil;
    [EAGLContext setCurrentContext:nil];
    
    _animatedMesh = nil;
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    const GLfloat  aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    self.baseEffect.transform.projectionMatrix =GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f),// Standard field of view
                                                                          aspectRatio,
                                                                          0.1f,   // Don't make near plane too close
                                                                          255.0f);// Far is arbitrarily far enough to contain scene
    
    static CGFloat refreshTime = 0;
    refreshTime += 1/60.f;
    //这里本来是使用self.timeSinceLastResume的,但是不知道什么原因xocde9.3环境下一直为0,所以没法更新
    //相同写法xcode7.3.1是没问题的
    [self.animatedMesh updateMeshWithElapsedTime:refreshTime];
    
    // Draw the mesh
    [self.baseEffect prepareToDraw];
    [self.animatedMesh prepareToDraw];
    [self.animatedMesh drawEntireMesh];
    
}

@end
