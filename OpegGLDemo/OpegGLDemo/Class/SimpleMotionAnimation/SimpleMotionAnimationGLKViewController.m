//
//  SimpleMotionAnimationGLKViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/7/3.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "SimpleMotionAnimationGLKViewController.h"
#import "SceneCar.h"
#import "SceneCarModel.h"
#import "SceneRinkModel.h"



@interface SimpleMotionAnimationGLKViewController ()<SceneCarControllerProtocol, GLKViewDelegate>

@property (nonatomic, strong) NSMutableArray<SceneCar *> *carsArray;
@property (nonatomic, assign) SceneAxisAllignedBoundingBox rinkBoundingBox;
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) SceneModel *carModel;
@property (strong, nonatomic) SceneModel *rinkModel;
@property (nonatomic, assign) BOOL shouldUseFirstPersonPOV;
@property (nonatomic, assign) GLfloat pointOfViewAnimationCountdown;
@property (nonatomic, assign) GLKVector3 eyePosition;
@property (nonatomic, assign) GLKVector3 lookAtPosition;
@property (nonatomic, assign) GLKVector3 targetEyePosition;
@property (nonatomic, assign) GLKVector3 targetLookAtPosition;
@property (strong, nonatomic) GLKView *glkView;
@end

@implementation SimpleMotionAnimationGLKViewController

//这个值设小了,第一人称会花屏
static const int kSceneNumberOfPOVAnimationSeconds = 100.0;

- (void)viewDidLoad {
    [super viewDidLoad];

    UISwitch *sender = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [self.view addSubview:sender];
    [sender addTarget:self action:@selector(changePOVSwitch:) forControlEvents:UIControlEventValueChanged];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, 0, 100, 50)];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dissMissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];

    GLKView *glkView = (GLKView *)self.view;
    self.glkView = glkView;
    glkView.delegate = self;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glkView.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.6f, // Red
                                                         0.6f, // Green
                                                         0.6f, // Blue
                                                         1.0f);// Alpha
    self.baseEffect.light0.position = GLKVector4Make(1.0f,
                                                     0.8f,
                                                     0.4f,
                                                     0.0f);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    
    //加载模型
    self.carModel = [[SceneCarModel alloc] init];
    self.rinkModel = [[SceneRinkModel alloc] init];
    
    //溜冰场边界包围盒子
    self.rinkBoundingBox = self.rinkModel.axisAlignedBoundingBox;
    
    //设置视点
    self.eyePosition = GLKVector3Make(10.5, 5.0, 0.0);
    self.lookAtPosition = GLKVector3Make(0.0, 0.5, 0.0);
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

- (void)dealloc{
    [EAGLContext setCurrentContext:self.glkView.context];
    self.glkView.context = nil;
    [EAGLContext setCurrentContext:nil];
    
    _baseEffect = nil;
    _carsArray = nil;
    _carModel = nil;
    _rinkModel = nil;
}

/**
 绘制前必须调用一次这个方法,该方法会根据用户选择的视角更新目标
 */
- (void)updatePointOfView
{
    if(!self.shouldUseFirstPersonPOV)
    {
        //第三人称视角
        self.eyePosition = GLKVector3Make(10.5, 5.0, 0.0);
        self.lookAtPosition = GLKVector3Make(0.0, 0.5, 0.0);
    }
    else
    {
        //将视角设置为最后一辆车的方向盘上
        SceneCar *viewerCar = [self.cars lastObject];
        self.targetEyePosition = GLKVector3Make(viewerCar.position.x,
                                                viewerCar.position.y + 0.45f,
                                                viewerCar.position.z);
        self.targetLookAtPosition = GLKVector3Add(_eyePosition,
                                                  viewerCar.velocity);
    }
}

/**
 在GLKViewController子类中会以30hz的频率被调用,详情见 https://developer.apple.com/documentation/glkit/glkviewcontroller?language=objc
 重新计算当前的眼睛和注视的位置,并且支持模拟碰撞检测和汽车行驶
 */
- (void)update{
    
    if(0 < self.pointOfViewAnimationCountdown)
    {
        self.pointOfViewAnimationCountdown -= self.timeSinceLastUpdate;
        
        //慢速更新第一人称动画
        //低通滤波,会让动画更流畅
        self.eyePosition = SceneVector3SlowLowPassFilter(self.timeSinceLastUpdate,
                                                         self.targetEyePosition,
                                                         self.eyePosition);
        self.lookAtPosition = SceneVector3SlowLowPassFilter(self.timeSinceLastUpdate,
                                                            self.targetLookAtPosition,
                                                            self.lookAtPosition);
    }else
    {
        //快速更新画面
        self.eyePosition = SceneVector3FastLowPassFilter(self.timeSinceLastUpdate,
                                                         self.targetEyePosition,
                                                         self.eyePosition);
        self.lookAtPosition = SceneVector3FastLowPassFilter(self.timeSinceLastUpdate,
                                                            self.targetLookAtPosition,
                                                            self.lookAtPosition);
    }
    
    // Update the cars
    [self.cars makeObjectsPerformSelector:@selector(updateWithController:)
                               withObject:self];
    
    // Update the target positions
    [self updatePointOfView];
    
    [self.glkView display];
}

#pragma mark - delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f, // Red
                                                         1.0f, // Green
                                                         1.0f, // Blue
                                                         1.0f);// Alpha
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix =GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f),//垂直观察区域的角度
                                                                          aspectRatio,//水平和垂直可视区域之间的比例
                                                                          0.1f,   // Don't make near plane too close
                                                                          25.0f); // Far is aritrarily far enough to contain scene
    
    //设置模型视图矩阵以匹配当前眼睛和观察位置
    //如果眼睛位置与看的点位置相同,那么这个函数就不会生效
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x,//眼睛位置
                                                                     self.eyePosition.y,
                                                                     self.eyePosition.z,
                                                                     self.lookAtPosition.x,//查看的点的位置
                                                                     self.lookAtPosition.y,
                                                                     self.lookAtPosition.z,
                                                                     0, 1, 0);//可以起到倾斜头部的效果
    
    // Draw the rink
    [self.baseEffect prepareToDraw];
    [self.rinkModel draw];
    
    // Draw the cars
    [self.carsArray makeObjectsPerformSelector:@selector(drawWithBaseEffect:)
                                    withObject:self.baseEffect];
    
}

- (NSArray *)cars{
    return [self.carsArray copy];
}

#pragma mark - target

- (void)changePOVSwitch:(UISwitch *)sender {
    
    self.shouldUseFirstPersonPOV = [sender isOn];
    _pointOfViewAnimationCountdown = kSceneNumberOfPOVAnimationSeconds;
}

- (void)dissMissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - set && get
/**
 四个汽车模型数据
 */
- (NSMutableArray<SceneCar *> *)carsArray{
    if (!_carsArray) {
        _carsArray = [NSMutableArray array];
        
        SceneCar *newCar1 = [[SceneCar alloc] initWithModel:self.carModel
                                                   position:GLKVector3Make(1.0, 0.0, 1.0)
                                                   velocity:GLKVector3Make(1.5, 0.0, 1.5)
                                                      color:GLKVector4Make(0.0, 0.5, 0.0, 1.0)];
        [_carsArray addObject:newCar1];
        
        SceneCar *newCar2 = [[SceneCar alloc] initWithModel:self.carModel
                                                   position:GLKVector3Make(-1.0, 0.0, 1.0)
                                                   velocity:GLKVector3Make(-1.5, 0.0, 1.5)
                                                      color:GLKVector4Make(0.5, 0.5, 0.0, 1.0)];
        [_carsArray addObject:newCar2];
        
        SceneCar *newCar3 = [[SceneCar alloc] initWithModel:self.carModel
                                                   position:GLKVector3Make(1.0, 0.0, -1.0)
                                                   velocity:GLKVector3Make(-1.5, 0.0, -1.5)
                                                      color:GLKVector4Make(0.5, 0.0, 0.0, 1.0)];
        [_carsArray addObject:newCar3];
        
        SceneCar *newCar4 = [[SceneCar alloc] initWithModel:self.carModel
                                                   position:GLKVector3Make(2.0, 0.0, -2.0)
                                                   velocity:GLKVector3Make(-1.5, 0.0, -0.5)
                                                      color:GLKVector4Make(0.3, 0.0, 0.3, 1.0)];
        [_carsArray addObject:newCar4];
    }
    return _carsArray;
}
@end
