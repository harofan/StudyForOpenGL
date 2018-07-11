//
//  SkyBoxViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/7/11.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "SkyBoxViewController.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModelManager.h"
#import "UtilityTextureInfo+viewAdditions.h"
#import <OpenGLES/ES2/glext.h>

@interface SkyBoxViewController ()
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) GLKSkyboxEffect *skyboxEffect;
@property (strong, nonatomic) GLKTextureInfo *textureInfo;
@property (assign, nonatomic, readwrite) GLKVector3 eyePosition;
@property (assign, nonatomic) GLKVector3 lookAtPosition;
@property (assign, nonatomic) GLKVector3 upVector;
@property (assign, nonatomic) float angle;
@property (strong, nonatomic) UtilityModelManager *modelManager;
@property (strong, nonatomic, strong) UtilityModel *boatModel;
@end

@implementation SkyBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    GLKView *glkView = (GLKView *)self.view;
    NSAssert([glkView isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glkView.context];
    
    // Create and configure base effect
    self.baseEffect = [[GLKBaseEffect alloc] init];
    // Configure a light
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.9f, // Red
                                                         0.9f, // Green
                                                         0.9f, // Blue
                                                         1.0f);// Alpha
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f, // Red
                                                         1.0f, // Green
                                                         1.0f, // Blue
                                                         1.0f);// Alpha
    
    // Set initial point of view
    self.eyePosition = GLKVector3Make(0.0, 3.0, 3.0);
    self.lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
    self.upVector = GLKVector3Make(0.0, 1.0, 0.0);
    
    //天空盒立方体纹理加载
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"skybox0"
                                                                      ofType:@"png"];
    NSAssert(nil != path, @"Path to skybox image not found");
    NSError *error = nil;
    self.textureInfo = [GLKTextureLoader cubeMapWithContentsOfFile:path
                                                           options:nil
                                                             error:&error];
    
    // Create and configure skybox
    self.skyboxEffect = [[GLKSkyboxEffect alloc] init];
    self.skyboxEffect.textureCubeMap.name = self.textureInfo.name;
    self.skyboxEffect.textureCubeMap.target =
    self.textureInfo.target;
    //天空盒是立方体,长宽高要相等
    self.skyboxEffect.xSize = 6.0f;
    self.skyboxEffect.ySize = 6.0f;
    self.skyboxEffect.zSize = 6.0f;
    
    //模型管理器加载模型并将数据发送到GPU。
    //可以通过名称访问每个加载的模型。
    NSString *modelsPath = [[NSBundle mainBundle] pathForResource:@"boat"
                                                           ofType:@"modelplist"];
    self.modelManager = [[UtilityModelManager alloc] initWithModelPath:modelsPath];
    
    // Load models used to draw the scene
    self.boatModel = [self.modelManager modelNamed:@"boat"];
    NSAssert(nil != self.boatModel, @"Failed to load boat model");
    
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
}

- (void)dealloc{
    self.baseEffect = nil;
    self.skyboxEffect = nil;
    self.textureInfo = nil;
}

// Configure self.baseEffect's projection and modelview
// matrix for cinematic orbit around ship model.
- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio
{
    // Do this here instead of -viewDidLoad because we don't
    // yet know aspectRatio in -viewDidLoad.
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(85.0f),// Standard field of view
                              aspectRatio,
                              0.1f,   // Don't make near plane too close
                              20.0f); // Far arbitrarily far enough to contain scene
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x,      // Eye position
                         self.eyePosition.y,
                         self.eyePosition.z,
                         self.lookAtPosition.x,   // Look-at position
                         self.lookAtPosition.y,
                         self.lookAtPosition.z,
                         self.upVector.x,         // Up direction
                         self.upVector.y,
                         self.upVector.z);
    
    //绕着船慢慢旋转
    self.angle += 0.01;
    self.eyePosition = GLKVector3Make(3.0f * sinf(_angle),
                                      3.0f,
                                      3.0f * cosf(_angle));
    
    // Pitch up and down slowly to marvel at the sky and water
    self.lookAtPosition = GLKVector3Make(0.0,
                                         1.5 + 3.0f * sinf(0.3 * _angle),
                                         0.0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{

    const GLfloat  aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    // Configure the point of view including animation
    [self preparePointOfViewWithAspectRatio:aspectRatio];
    
    // Set light position after change to point of view so that
    // light uses correct coordinate system.
    self.baseEffect.light0.position = GLKVector4Make(0.4f,
                                                     0.4f,
                                                     -0.3f,
                                                     0.0f);// Directional light
    
    //要让天空盒的中心与眼睛的位置相同,否则会产生纹理拉伸损坏最终的渲染效果
    self.skyboxEffect.center = self.eyePosition;
    self.skyboxEffect.transform.projectionMatrix = self.baseEffect.transform.projectionMatrix;
    self.skyboxEffect.transform.modelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    [self.skyboxEffect prepareToDraw];
    glDepthMask(false);
    [self.skyboxEffect draw];
    glBindVertexArrayOES(0);
    
    // Draw boat model
    [self.modelManager prepareToDraw];
    [self.baseEffect prepareToDraw];
    glDepthMask(true);
    [self.boatModel draw];
    
#ifdef DEBUG
    {  // Report any errors
        GLenum error = glGetError();
        if(GL_NO_ERROR != error)
        {
            NSLog(@"GL Error: 0x%x", error);
        }
    }
#endif
}

@end
