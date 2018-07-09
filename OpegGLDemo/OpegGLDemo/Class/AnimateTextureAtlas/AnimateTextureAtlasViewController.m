//
//  AnimateTextureAtlasViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/7/6.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "AnimateTextureAtlasViewController.h"
#import "AGLKTextureTransformBaseEffect.h"
#import "SceneAnimatedMesh.h"
#import "SceneCanLightModel.h"

static const GLKVector4 kSpotLight0Position = {10.0f, 18.0f, -10.0f, 1.0f};
static const GLKVector4 kSpotLight1Position = {30.0f, 18.0f, -10.0f, 1.0f};
static const GLKVector4 kLight2Position = {1.0f, 0.5f, 0.0f, 0.0f};

static const int kNumberOfMovieFrames = 51;
static const int kNumberOfMovieFramesPerRow = 8;
static const int kNumberOfMovieFramesPerColumn = 8;
static const int kNumberOfFramesPerSecond = 15;

@interface AnimateTextureAtlasViewController ()

@property (strong, nonatomic) AGLKTextureTransformBaseEffect *baseEffect;
@property (strong, nonatomic) SceneAnimatedMesh *animatedMesh;
@property (strong, nonatomic) SceneCanLightModel *canLightModel;
@property (nonatomic, assign) GLfloat spotLight0TiltAboutXAngleDeg;
@property (nonatomic, assign) GLfloat spotLight0TiltAboutZAngleDeg;
@property (nonatomic, assign) GLfloat spotLight1TiltAboutXAngleDeg;
@property (nonatomic, assign) GLfloat spotLight1TiltAboutZAngleDeg;
@property (nonatomic, assign) BOOL shouldRipple;
@property (strong, nonatomic) GLKView *glkView;

@end

@implementation AnimateTextureAtlasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *glkView = (GLKView *)self.view;
    self.glkView = glkView;
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    [EAGLContext setCurrentContext:glkView.context];
    
    UISwitch *sender = [[UISwitch alloc] initWithFrame:CGRectMake(0, 400, 100, 50)];
    [self.view addSubview:sender];
    [sender addTarget:self action:@selector(changePOVSwitch:) forControlEvents:UIControlEventValueChanged];
    
    self.baseEffect = [[AGLKTextureTransformBaseEffect alloc] init];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    _animatedMesh = [[SceneAnimatedMesh alloc] init];
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(20, 25, 5,
                                                                     20, 0, -15,
                                                                     0, 1, 0);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    
    self.canLightModel = [[SceneCanLightModel alloc] init];
    
    self.baseEffect.material.ambientColor = GLKVector4Make(0.8f, 0.8f, 0.8f, 1.0f);
    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.8f, 0.8f, 0.8f, 1.0f);
    
    //light0
    self.baseEffect.lightingType = GLKLightingTypePerVertex;
    self.baseEffect.lightModelTwoSided = GL_FALSE;
    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.6f, // Red
                                                            0.6f, // Green
                                                            0.6f, // Blue
                                                            1.0f);// Alpha
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
    
    //light1
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
    
    //light2
    self.baseEffect.light2.enabled = GL_TRUE;
    self.baseEffect.light2Position = kLight2Position;
    self.baseEffect.light2.diffuseColor = GLKVector4Make(0.5f, // Red
                                                         0.5f, // Green
                                                         0.5f, // Blue
                                                         1.0f);// Alpha
    
    // Material colors
    self.baseEffect.material.diffuseColor = GLKVector4Make(1.0f, // Red
                                                           1.0f, // Green
                                                           1.0f, // Blue
                                                           1.0f);// Alpha
    self.baseEffect.material.specularColor = GLKVector4Make(0.0f, // Red
                                                            0.0f, // Green
                                                            0.0f, // Blue
                                                            1.0f);// Alpha
    
    //设置纹理
    CGImageRef imageRef0 = [[UIImage imageNamed:@"RabbitTextureAtlas.png"] CGImage];
    GLKTextureInfo *textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0
                                                                options:nil
                                                                  error:NULL];
    self.baseEffect.texture2d0.name = textureInfo0.name;
    self.baseEffect.texture2d0.target = textureInfo0.target;
}

- (void)dealloc{
    
    self.glkView.context = nil;
    [EAGLContext setCurrentContext:nil];
}
#pragma mark - update
- (void)updateSpotLightDirections
{
    static CGFloat lightRefreshTime = 0;
    lightRefreshTime += 10 * 1/60.f;
    
    _spotLight0TiltAboutXAngleDeg = -20.0f + 30.0f * sinf(lightRefreshTime);
    _spotLight0TiltAboutZAngleDeg = 30.0f * cosf(lightRefreshTime);
    _spotLight1TiltAboutXAngleDeg = 20.0f + 30.0f * cosf(lightRefreshTime);
    _spotLight1TiltAboutZAngleDeg = 30.0f * sinf(lightRefreshTime);
}

- (void)updateTextureTransform
{
    static CGFloat textureRefreshTime = 0;
    textureRefreshTime += 2 * 1/60.f;
    
    // Calculate which sub-image of the texture atlas to use
    int movieFrameNumber = (int)floor(textureRefreshTime * kNumberOfFramesPerSecond) % kNumberOfMovieFrames;
    
    // Calculate the position of the current sub-image
    GLfloat currentRowPosition = (movieFrameNumber % kNumberOfMovieFramesPerRow) * 1.0f / kNumberOfMovieFramesPerRow;
    GLfloat currentColumnPosition = (movieFrameNumber / kNumberOfMovieFramesPerColumn) * 1.0f / kNumberOfMovieFramesPerColumn;
    
    // Translate to origin of current frame
    self.baseEffect.textureMatrix2d0 = GLKMatrix4MakeTranslation(currentRowPosition,
                                                                 currentColumnPosition,
                                                                 0.0f);
    // Scale to make current frame fills coordinate space
    self.baseEffect.textureMatrix2d0 = GLKMatrix4Scale(self.baseEffect.textureMatrix2d0,
                                                       1.0f/kNumberOfMovieFramesPerRow,
                                                       1.0f/kNumberOfMovieFramesPerColumn,
                                                       1.0f);
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
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                 GLKMathDegreesToRadians(self.spotLight0TiltAboutXAngleDeg),
                                                                 1,
                                                                 0,
                                                                 0);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,
                                                                 GLKMathDegreesToRadians(self.spotLight0TiltAboutZAngleDeg),
                                                                 0,
                                                                 0,
                                                                 1);
    
    // Configure light in current coordinate system
    self.baseEffect.light0Position = GLKVector4Make(0, 0, 0, 1);
    self.baseEffect.light0SpotDirection = GLKVector3Make(0, -1, 0);
    self.baseEffect.texture2d0.enabled = GL_FALSE;
    
    [self.baseEffect prepareToDrawMultitextures];
    [self.canLightModel draw];
    
    // Restore saved attributes
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
    self.baseEffect.texture2d0.enabled = GL_FALSE;
    
    [self.baseEffect prepareToDrawMultitextures];
    [self.canLightModel draw];
    
    // Restore saved attributes
    self.baseEffect.transform.modelviewMatrix = savedModelviewMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self updateSpotLightDirections];
    [self updateTextureTransform];
    
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    // Calculate the aspect ratio for the scene and setup a
    // perspective projection
    const GLfloat  aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(80.0f),// Wide field of view
                                                                           aspectRatio,
                                                                           0.1f,   // Don't make near plane too close
                                                                           255.0f);// Far is arbitrarily far enough to contain scene
    self.baseEffect.transform.projectionMatrix = GLKMatrix4Rotate(self.baseEffect.transform.projectionMatrix,
                                                                  GLKMathDegreesToRadians(-90.0f),
                                                                  0.0f,
                                                                  0.0f,
                                                                  1.0f);
    
    // Draw lights
    [self drawLight0];
    [self drawLight1];
    
    if(_shouldRipple)
    {
        static CGFloat glkRefreshTime = 0;
        glkRefreshTime += 10 * 1/60.f;
        
        [self.animatedMesh updateMeshWithElapsedTime:glkRefreshTime];
    }
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    
    // Draw the mesh
    [self.baseEffect prepareToDrawMultitextures];
    [self.animatedMesh prepareToDraw];
    [self.animatedMesh drawEntireMesh];
}

- (void)changePOVSwitch:(UISwitch *)sender{
    self.shouldRipple = [sender isOn];
    
    if(!self.shouldRipple)
    {
        [self.animatedMesh updateMeshWithDefaultPositions];
    }
}




@end
