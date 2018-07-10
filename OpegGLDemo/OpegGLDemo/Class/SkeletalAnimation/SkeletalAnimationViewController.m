//
//  SkeletalAnimationViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/7/9.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "SkeletalAnimationViewController.h"
#import "UtilityModelManager.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityModel+skinning.h"
#import "UtilityModelManager+skinning.h"
#import "UtilityJoint.h"
#import "UtilityArmatureBaseEffect.h"

@interface SkeletalAnimationViewController ()

@property (strong, nonatomic) UtilityModelManager *modelManager;
@property (strong, nonatomic) UtilityArmatureBaseEffect *baseEffect;
@property (strong, nonatomic) UtilityModel *bone0;
@property (strong, nonatomic) UtilityModel *bone1;
@property (strong, nonatomic) UtilityModel *bone2;
@property (assign, nonatomic) float joint0AngleRadians;
@property (assign, nonatomic) float joint1AngleRadians;
@property (assign, nonatomic) float joint2AngleRadians;

@end

@implementation SkeletalAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self init3Slider];
    
    GLKView *glkView = (GLKView *)self.view;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
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
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    NSString *modelsPath = [[NSBundle mainBundle] pathForResource:@"armature"
                                                           ofType:@"modelplist"];
    if(nil != modelsPath)
    {
        self.modelManager =
        [[UtilityModelManager alloc] initWithModelPath:modelsPath];
    }
    
    // Load models used to draw the Utility
    self.bone0 = [self.modelManager modelNamed:@"bone0"];
    NSAssert(nil != self.bone0,@"Failed to load bone0 model");
    [self.bone0 assignJoint:0];
    
    self.bone1 = [self.modelManager modelNamed:@"bone1"];
    NSAssert(nil != self.bone1,@"Failed to load bone1 model");
    [self.bone1 assignJoint:1];
    
    self.bone2 = [self.modelManager modelNamed:@"bone2"];
    NSAssert(nil != self.bone2,@"Failed to load bone2 model");
    [self.bone2 assignJoint:2];
    
    // 创建三个关节
    UtilityJoint *bone0Joint = [[UtilityJoint alloc] initWithDisplacement:GLKVector3Make(0, 0, 0)
                                                                   parent:nil];
    float bone0Length = self.bone0.axisAlignedBoundingBox.max.y - self.bone0.axisAlignedBoundingBox.min.y;
    
    UtilityJoint *bone1Joint = [[UtilityJoint alloc] initWithDisplacement:GLKVector3Make(0, bone0Length, 0)
                                                                   parent:bone0Joint];
    float bone1Length = self.bone1.axisAlignedBoundingBox.max.y - self.bone1.axisAlignedBoundingBox.min.y;
    
    UtilityJoint *bone2Joint = [[UtilityJoint alloc]initWithDisplacement:GLKVector3Make(0, bone1Length, 0)
                                                                  parent:bone1Joint];
    
    self.baseEffect.jointsArray = [NSArray arrayWithObjects:bone0Joint, bone1Joint, bone2Joint, nil];
    
    // Set initial point of view to reasonable arbitrary values
    // These values make most of the simulated rink visible
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(5.0, 10.0, 15.0,// Eye position
                                                                     0.0, 2.0, 0.0,  // Look-at position
                                                                     0.0, 1.0, 0.0); // Up direction
    
    // Start armature joints in default positions
    [self setJoint0AngleRadians:0];
    [self setJoint1AngleRadians:0];
    [self setJoint2AngleRadians:0];
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
    
    // Calculate the aspect ratio for the Utility and setup a
    // perspective projection
    const GLfloat  aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f),// Standard field of view
                                                                           aspectRatio,
                                                                           4.0f,   // Don't make near plane too close
                                                                           20.0f); // Far arbitrarily far enough to contain Utility
    
    [self.modelManager prepareToDrawWithJointInfluence];
    [self.baseEffect prepareToDrawArmature];
    
    // Draw the bones
    [self.bone0 draw];
    [self.bone1 draw];
    [self.bone2 draw];
    
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











