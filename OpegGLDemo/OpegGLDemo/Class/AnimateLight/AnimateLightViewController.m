//
//  AnimateLightViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/7/5.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "AnimateLightViewController.h"
#import "AGLKTextureTransformBaseEffect.h"
#import "SceneAnimatedMesh.h"
#import "SceneCanLightModel.h"

static const GLKVector4 kSpotLight0Position = {10.0f, 18.0f, -10.0f, 1.0f};
static const GLKVector4 kSpotLight1Position = {30.0f, 18.0f, -10.0f, 1.0f};
static const GLKVector4 kLight2Position = {1.0f, 0.5f, 0.0f, 0.0f};

@interface AnimateLightViewController ()

@property (strong, nonatomic) AGLKTextureTransformBaseEffect *baseEffect;
@property (strong, nonatomic) SceneAnimatedMesh *animatedMesh;
@property (strong, nonatomic) SceneCanLightModel *canLightModel;
@property (nonatomic, assign) GLfloat spotLight0TiltAboutXAngleDeg;
@property (nonatomic, assign) GLfloat spotLight0TiltAboutZAngleDeg;
@property (nonatomic, assign) GLfloat spotLight1TiltAboutXAngleDeg;
@property (nonatomic, assign) GLfloat spotLight1TiltAboutZAngleDeg;
@property (strong, nonatomic) GLKView *glkView;

@end

@implementation AnimateLightViewController
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    self.baseEffect = [[AGLKTextureTransformBaseEffect alloc] init];
    
    //高质量照明(对聚光灯很重要)
    self.baseEffect.lightingType = GLKLightingTypePerPixel;
    self.baseEffect.lightModelTwoSided = GL_FALSE;
    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.6f, // Red
                                                            0.6f, // Green
                                                            0.6f, // Blue
                                                            1.0f);// Alpha
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    _animatedMesh = [[SceneAnimatedMesh alloc] init];
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(20, 25, 5,
                                                                     20, 0, -15,
                                                                     0, 1, 0);
    glEnable(GL_DEPTH_TEST);
    
    //为聚光灯加载模型
    self.canLightModel = [[SceneCanLightModel alloc] init];
    
    //环境光
    self.baseEffect.material.ambientColor = GLKVector4Make(0.4f, 0.4f, 0.4f, 1.0f);
    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.4f, 0.4f, 0.4f, 1.0f);
    
    //light0 聚光灯
    [self configLight0];
    
    //light1 聚光灯
    [self configLight1];
    
    //light2 方向光
    [self configLight2];
    
    //材料颜色
    self.baseEffect.material.diffuseColor = GLKVector4Make(1.0f, // Red
                                                           1.0f, // Green
                                                           1.0f, // Blue
                                                           1.0f);// Alpha
    self.baseEffect.material.specularColor = GLKVector4Make(0.0f, // Red
                                                            0.0f, // Green
                                                            0.0f, // Blue
                                                            1.0f);// Alpha
}

- (void)dealloc{
    [EAGLContext setCurrentContext:self.glkView.context];
    
    // Stop using the context created in -viewDidLoad
    self.glkView.context = nil;
    [EAGLContext setCurrentContext:nil];
    
    _animatedMesh = nil;
    _canLightModel = nil;
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - update
- (void)updateSpotLightDirections
{
    static CGFloat refreshTime = 0;
    refreshTime += 10 * 1/60.f;
    
    //使用周期函数倾斜聚光灯进行简单的平滑动画(常量是任意的，为视觉上有趣的聚光灯方向选择)
    _spotLight0TiltAboutXAngleDeg = -20.0f + 30.0f * sinf(refreshTime);
    _spotLight0TiltAboutZAngleDeg = 30.0f * cosf(refreshTime);
    _spotLight1TiltAboutXAngleDeg = 20.0f + 30.0f * cosf(refreshTime);
    _spotLight1TiltAboutZAngleDeg = 30.0f * sinf(refreshTime);
}

- (void)update
{
    [self updateSpotLightDirections];
}

#pragma mark - config light
- (void)configLight0{
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.spotExponent = 20.0f;
    self.baseEffect.light0.spotCutoff = 30.0f;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f, // Red
                                                         1.0f, // Green
                                                         0.0f, // Blue
                                                         1.0f);// Alpha
    self.baseEffect.light0.specularColor = GLKVector4Make(0.0f, // Red
                                                          0.0f, // Green
                                                          0.0f, // Blue
                                                          1.0f);// Alpha
}

- (void)configLight1{
    self.baseEffect.light1.enabled = GL_TRUE;
    self.baseEffect.light1.spotExponent = 20.0f;
    self.baseEffect.light1.spotCutoff = 30.0f;
    self.baseEffect.light1.diffuseColor = GLKVector4Make(0.0f, // Red
                                                         1.0f, // Green
                                                         1.0f, // Blue
                                                         1.0f);// Alpha
    self.baseEffect.light1.specularColor = GLKVector4Make(0.0f, // Red
                                                          0.0f, // Green
                                                          0.0f, // Blue
                                                          1.0f);// Alpha
}

- (void)configLight2{
    self.baseEffect.light2.enabled = GL_TRUE;
    self.baseEffect.light2Position = kLight2Position;
    self.baseEffect.light2.diffuseColor = GLKVector4Make(0.5f, // Red
                                                         0.5f, // Green
                                                         0.5f, // Blue
                                                         1.0f);// Alpha
}

#pragma mark - draw

- (void)drawLight0
{
    // Save effect attributes that will be changed
    GLKMatrix4  savedModelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    
    // Translate to the model's position
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Translate(savedModelviewMatrix,
                                                                    kSpotLight0Position.x,
                                                                    kSpotLight0Position.y,
                                                                    kSpotLight0Position.z);
    self.baseEffect.transform.modelviewMatrix =GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                GLKMathDegreesToRadians(self.spotLight0TiltAboutXAngleDeg),
                                                                1,
                                                                0,
                                                                0);
    self.baseEffect.transform.modelviewMatrix =GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                GLKMathDegreesToRadians(self.spotLight0TiltAboutZAngleDeg),
                                                                0,
                                                                0,
                                                                1);
    
    // 配置灯光坐标
    self.baseEffect.light0Position = GLKVector4Make(0, 0, 0, 1);
    self.baseEffect.light0SpotDirection = GLKVector3Make(0, -1, 0);
    
    [self.baseEffect prepareToDraw];
    [self.canLightModel draw];
    
    // 恢复保存的矩阵
    self.baseEffect.transform.modelviewMatrix = savedModelviewMatrix;
}

- (void)drawLight1
{
    // Save effect attributes that will be changed
    GLKMatrix4  savedModelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    
    // Translate to the model's position
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Translate(savedModelviewMatrix,
                                                                    kSpotLight1Position.x,
                                                                    kSpotLight1Position.y,
                                                                    kSpotLight1Position.z);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                 GLKMathDegreesToRadians(self.spotLight1TiltAboutXAngleDeg),
                                                                 1,
                                                                 0,
                                                                 0);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                 GLKMathDegreesToRadians(self.spotLight1TiltAboutZAngleDeg),
                                                                 0,
                                                                 0,
                                                                 1);
    
    // Configure light in current coordinate system
    self.baseEffect.light1Position = GLKVector4Make(0, 0, 0, 1);
    self.baseEffect.light1SpotDirection = GLKVector3Make(0, -1, 0);
    
    [self.baseEffect prepareToDraw];
    [self.canLightModel draw];
    
    // Restore saved attributes
    self.baseEffect.transform.modelviewMatrix = savedModelviewMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    // Calculate the aspect ratio for the scene and setup a
    // perspective projection
    const GLfloat  aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f),// Standard field of view
                                                                           aspectRatio,
                                                                           0.1f,   // Don't make near plane too close
                                                                           255.0f);// Far is arbitrarily far enough to contain scene
    
    // Draw lights
    [self drawLight0];
    [self drawLight1];
    
    static CGFloat refreshTime = 0;
    refreshTime += 1/60.f;
    [self.animatedMesh updateMeshWithElapsedTime:refreshTime];
    
    // Draw the mesh
    [self.baseEffect prepareToDraw];
    [self.animatedMesh prepareToDraw];
    [self.animatedMesh drawEntireMesh];
}


@end
