//
//  LodeModelFromModelPlistViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/7/9.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "LodeModelFromModelPlistViewController.h"
#import "UtilitySceneCar.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModelManager.h"
#import "UtilityTextureInfo.h"

@interface LodeModelFromModelPlistViewController ()<UtilitySceneCarControllerProtocol>

@property (nonatomic, strong) NSMutableArray<UtilitySceneCar *> *carsArray;
@property (strong, nonatomic) UtilityModelManager *modelManager;
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) UtilityModel *carModel;
@property (strong, nonatomic) UtilityModel *rinkModelFloor;
@property (strong, nonatomic) UtilityModel *rinkModelWalls;
@property (nonatomic, assign) AGLKAxisAllignedBoundingBox rinkBoundingBox;
@property (strong, nonatomic) GLKView *glkView;

@end

@implementation LodeModelFromModelPlistViewController

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
    self.glkView = glkView;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glkView.context];
    glEnable(GL_DEPTH_TEST);
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, 0, 100, 50)];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dissMissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    // Configure a light
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.7f, // Red
                                                         0.7f, // Green
                                                         0.7f, // Blue
                                                         1.0f);// Alpha
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f, // Red
                                                         1.0f, // Green
                                                         1.0f, // Blue
                                                         1.0f);// Alpha
    self.baseEffect.light0.position = GLKVector4Make(1.0f,
                                                     0.8f,
                                                     0.4f,
                                                     0.0f);// Directional light
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    //模型管理器加载模型,然后将模型发送到GPU.可以通过名称访问每个模型
    NSString *modelsPath = [[NSBundle mainBundle] pathForResource:@"bumper"
                                                           ofType:@"modelplist"];
    self.modelManager = [[UtilityModelManager alloc] initWithModelPath:modelsPath];
    
    // 读取模型
    self.carModel = [self.modelManager modelNamed:@"bumperCar"];
    NSAssert(nil != self.carModel,@"Failed to load car model");
    
    self.rinkModelFloor = [self.modelManager modelNamed:@"bumperRinkFloor"];
    NSAssert(nil != self.rinkModelFloor,@"Failed to load rink floor model");
    
    self.rinkModelWalls = [self.modelManager modelNamed:@"bumperRinkWalls"];
    NSAssert(nil != self.rinkModelFloor,@"Failed to load rink walls model");
    
    //边界
    self.rinkBoundingBox = self.rinkModelFloor.axisAlignedBoundingBox;
    NSAssert(0 < (self.rinkBoundingBox.max.x -
                  self.rinkBoundingBox.min.x) &&
             0 < (self.rinkBoundingBox.max.z -
                  self.rinkBoundingBox.min.z),
             @"Rink has no area");
    
    [self.carsArray addObject:[[UtilitySceneCar alloc] initWithModel:self.carModel
                                                            position:GLKVector3Make(1.0, 0.0, 1.0)
                                                            velocity:GLKVector3Make(1.5, 0.0, 1.5)
                                                               color:GLKVector4Make(0.0, 0.5, 0.0, 1.0)]];
    
    [self.carsArray addObject:[[UtilitySceneCar alloc] initWithModel:self.carModel
                                                            position:GLKVector3Make(-1.0, 0.0, 1.0)
                                                            velocity:GLKVector3Make(-1.5, 0.0, 1.5)
                                                               color:GLKVector4Make(0.5, 0.5, 0.0, 1.0)]];
    
    [self.carsArray addObject:[[UtilitySceneCar alloc] initWithModel:self.carModel
                                                            position:GLKVector3Make(1.0, 0.0, -1.0)
                                                            velocity:GLKVector3Make(-1.5, 0.0, -1.5)
                                                               color:GLKVector4Make(0.5, 0.0, 0.0, 1.0)]];
    
    [self.carsArray addObject:[[UtilitySceneCar alloc] initWithModel:self.carModel
                                                            position:GLKVector3Make(2.0, 0.0, -2.0)
                                                            velocity:GLKVector3Make(-1.5, 0.0, -0.5)
                                                               color:GLKVector4Make(0.3, 0.0, 0.3, 1.0)]];
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(10.5, 5.0, 0.0, // Eye position
                                                                     0.0, 0.5, 0.0,  // Look-at position
                                                                     0.0, 1.0, 0.0); // Up direction
    
    self.baseEffect.texture2d0.name = self.modelManager.textureInfo.name;
    self.baseEffect.texture2d0.target = self.modelManager.textureInfo.target;
}

- (void)dealloc{
    
    self.glkView.context = nil;
    [EAGLContext setCurrentContext:nil];
    _baseEffect = nil;
    _carsArray = nil;
    _carModel = nil;
    _rinkModelFloor = nil;
    _rinkModelWalls = nil;
}

- (void)dissMissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - update
- (void)update
{
    // Update the cars
    [self.carsArray makeObjectsPerformSelector:@selector(updateWithController:) withObject:self];
}

#pragma mark - delegate
- (NSArray *)cars {
    return [self.carsArray copy];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    // Cull back faces: Important! many Sketchup models have back
    // faces that cause Z fighting if back faces are not culled.
    //背面剔除,不剔除会产生双面造成z方向冲突
    glEnable(GL_CULL_FACE);
    
    // Calculate the aspect ratio for the scene and setup a
    // perspective projection
    const GLfloat  aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f),// Standard field of view
                                                                           aspectRatio,
                                                                           4.0f,   // Don't make near plane too close
                                                                           20.0f); // Far arbitrarily far enough to contain scene
    
    [self.modelManager prepareToDraw];
    [self.baseEffect prepareToDraw];
    
    // Draw the rink
    [self.rinkModelFloor draw];
    [self.rinkModelWalls draw];
    
    // Draw the cars
    [self.carsArray makeObjectsPerformSelector:@selector(drawWithBaseEffect:)
                                    withObject:self.baseEffect];
}

#pragma mark - set && get
- (NSMutableArray<UtilitySceneCar *> *)carsArray{
    if (!_carsArray) {
        _carsArray = [NSMutableArray array];
    }
    return _carsArray;
}
@end
