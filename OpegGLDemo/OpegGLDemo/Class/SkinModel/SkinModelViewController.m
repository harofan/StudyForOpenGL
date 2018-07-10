//
//  SkinModelViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/7/10.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "SkinModelViewController.h"
#import "UtilityModelManager+skinning.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModel+skinning.h"
#import "UtilityJoint.h"
#import "UtilityArmatureBaseEffect.h"

@interface SkinModelViewController ()

@property (strong, nonatomic) UtilityModelManager *modelManager;
@property (strong, nonatomic) UtilityArmatureBaseEffect *baseEffect;
@property (strong, nonatomic) UtilityModel *bone0;
@property (strong, nonatomic) UtilityModel *bone1;
@property (strong, nonatomic) UtilityModel *bone2;
@property (strong, nonatomic) UtilityModel *tube;
@property (assign, nonatomic) float joint0AngleRadians;
@property (assign, nonatomic) float joint1AngleRadians;
@property (assign, nonatomic) float joint2AngleRadians;
@property (strong, nonatomic) GLKView *glkView;
@end

@implementation SkinModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self init3Slider];
    
    UISwitch *sender = [[UISwitch alloc] initWithFrame:CGRectMake(0, 400, 100, 50)];
    [self.view addSubview:sender];
    [sender addTarget:self action:@selector(takeRigidSkinFrom:) forControlEvents:UIControlEventValueChanged];
    
    GLKView *glkView = (GLKView *)self.view;
    self.glkView = glkView;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // Make the new context current andenable depth testing
    [EAGLContext setCurrentContext:glkView.context];
    glEnable(GL_DEPTH_TEST);
    
    self.baseEffect = [[UtilityArmatureBaseEffect alloc] init];
    
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
    self.baseEffect.light0Position = GLKVector4Make(1.0f,
                                                    0.8f,
                                                    0.4f,
                                                    0.0f);// Directional light
    
    // Set the background color
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    // The model manager loads models and sends the data to GPU.
    // Each loaded model can be accesssed by name.
    NSString *modelsPath = [[NSBundle mainBundle] pathForResource:@"armatureSkin"
                                                           ofType:@"modelplist"];
    if(nil != modelsPath)
    {
        self.modelManager = [[UtilityModelManager alloc] initWithModelPath:modelsPath];
    }
    
    // Load models used to draw the scene
    self.bone0 = [self.modelManager modelNamed:@"bone0"];
    NSAssert(nil != self.bone0, @"Failed to bone0 model");
    
    self.bone1 = [self.modelManager modelNamed:@"bone1"];
    NSAssert(nil != self.bone1, @"Failed to load bone1 model");
    
    self.bone2 = [self.modelManager modelNamed:@"bone2"];
    NSAssert(nil != self.bone2, @"Failed to load bone2 model");
    
    self.tube = [self.modelManager modelNamed:@"tube"];
    NSAssert(nil != self.tube, @"Failed to load tube model");
    
    // Create collection of joints
    UtilityJoint *bone0Joint = [[UtilityJoint alloc]  initWithDisplacement:GLKVector3Make(0, 0, 0)
                                                                    parent:nil];
    float bone0Length = self.bone0.axisAlignedBoundingBox.max.y - self.bone0.axisAlignedBoundingBox.min.y;
    UtilityJoint *bone1Joint = [[UtilityJoint alloc] initWithDisplacement:GLKVector3Make(0, bone0Length, 0)
                                                                   parent:bone0Joint];
    float bone1Length = self.bone1.axisAlignedBoundingBox.max.y - self.bone1.axisAlignedBoundingBox.min.y;
    UtilityJoint *bone2Joint = [[UtilityJoint alloc] initWithDisplacement:GLKVector3Make(0, bone1Length, 0)
                                                                   parent:bone1Joint];
    
    self.baseEffect.jointsArray = [NSArray arrayWithObjects:bone0Joint, bone1Joint, bone2Joint, nil];
    
    // Automatically skin the model
    [self.tube automaticallySkinRigidWithJoints:self.baseEffect.jointsArray];
    
    // Set initial point of view to reasonable arbitrary values
    // These values make most of the simulated rink visible
    self.baseEffect.transform.modelviewMatrix =GLKMatrix4MakeLookAt(5.0, 10.0, 15.0,// Eye position
                                                                    0.0, 2.0, 0.0,  // Look-at position
                                                                    0.0, 1.0, 0.0); // Up direction
    
    // Start armature joints in default positions
    [self setJoint0AngleRadians:0];
    [self setJoint1AngleRadians:0];
    [self setJoint2AngleRadians:0];
}

- (void)dealloc{
    self.glkView.context = nil;
    [EAGLContext setCurrentContext:nil];
    
    self.baseEffect = nil;
    self.bone0 = nil;
    self.bone1 = nil;
    self.bone2 = nil;
    self.tube = nil;
}

- (void)init3Slider{
    UISlider *angleSlider1 = [[UISlider alloc] initWithFrame:CGRectMake(15, 600, 350, 50)];
    [self.view addSubview:angleSlider1];
    angleSlider1.minimumValue = -1.f;
    angleSlider1.maximumValue = 1.0f;
    angleSlider1.value = 0.0f;
    [angleSlider1 addTarget:self action:@selector(changeFirstAngleWithSlider:) forControlEvents:UIControlEventValueChanged];
    
    UISlider *angleSlider2 = [[UISlider alloc] initWithFrame:CGRectMake(15, 650, 350, 50)];
    [self.view addSubview:angleSlider2];
    angleSlider2.minimumValue = -1.f;
    angleSlider2.maximumValue = 1.0f;
    angleSlider2.value = 0.0f;
    [angleSlider2 addTarget:self action:@selector(changeSecondAngleWithSlider:) forControlEvents:UIControlEventValueChanged];
    
    UISlider *angleSlider3 = [[UISlider alloc] initWithFrame:CGRectMake(15, 700, 350, 50)];
    [self.view addSubview:angleSlider3];
    angleSlider3.minimumValue = -1.f;
    angleSlider3.maximumValue = 1.0f;
    angleSlider3.value = 0.0f;
    [angleSlider3 addTarget:self action:@selector(changeThirdAngleWithSlider:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Clear back frame buffer (erase previous drawing)
    // and depth buffer
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    // Cull back faces: Important! many Sketchup models have back
    // faces that cause Z fighting if back faces are not culled.
    glEnable(GL_CULL_FACE);
    
    // Calculate the aspect ratio for the scene and setup a
    // perspective projection
    const GLfloat  aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f),// Standard field of view
                                                                           aspectRatio,
                                                                           4.0f,   // Don't make near plane too close
                                                                           20.0f); // Far arbitrarily far enough to contain scene
    
    [self.modelManager prepareToDrawWithJointInfluence];
    [self.baseEffect prepareToDrawArmature];
    
    // Draw the skin
    [self.tube draw];
    
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
#pragma mark - target
- (void)changeFirstAngleWithSlider:(UISlider *)slider{
    [self setJoint0AngleRadians:[slider value]];
}

- (void)changeSecondAngleWithSlider:(UISlider *)slider{
    [self setJoint1AngleRadians:[slider value]];
}

- (void)changeThirdAngleWithSlider:(UISlider *)slider{
    [self setJoint2AngleRadians:[slider value]];
}

- (void)takeRigidSkinFrom:(UISwitch *)sender
{
    if([sender isOn]){
        //每个顶点只受到这个顶点下面离他最近的关节的影响,但是每个关节已经包含了父关节对其的影响
        [self.tube automaticallySkinRigidWithJoints:self.baseEffect.jointsArray];
    }
    else{
        //距离远的关节比附近的关节影响小
        [self.tube automaticallySkinSmoothWithJoints:self.baseEffect.jointsArray];
    }
}

#pragma mark - set && get
- (void)setJoint0AngleRadians:(float)joint0AngleRadians{
    _joint0AngleRadians = joint0AngleRadians;
    GLKMatrix4  rotateZMatrix = GLKMatrix4MakeRotation(joint0AngleRadians * M_PI * 0.5, 0, 0, 1);
    
    [(UtilityJoint *)[self.baseEffect.jointsArray objectAtIndex:0] setMatrix:rotateZMatrix];
}

- (void)setJoint1AngleRadians:(float)joint1AngleRadians{
    _joint1AngleRadians = joint1AngleRadians;
    
    GLKMatrix4  rotateZMatrix = GLKMatrix4MakeRotation(joint1AngleRadians * M_PI * 0.5, 0, 0, 1);
    
    [(UtilityJoint *)[self.baseEffect.jointsArray objectAtIndex:1] setMatrix:rotateZMatrix];
}

- (void)setJoint2AngleRadians:(float)joint2AngleRadians{
    _joint2AngleRadians = joint2AngleRadians;
    
    GLKMatrix4  rotateZMatrix = GLKMatrix4MakeRotation(joint2AngleRadians * M_PI * 0.5, 0, 0, 1);
    
    [(UtilityJoint *)[self.baseEffect.jointsArray objectAtIndex:2] setMatrix:rotateZMatrix];
}

@end
