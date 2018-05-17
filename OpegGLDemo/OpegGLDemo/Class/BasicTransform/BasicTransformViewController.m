//
//  BasicTransformViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/5/17.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "BasicTransformViewController.h"
#import <GLKit/GLKit.h>
#import "AGLKVertexAttribArrayBuffer.h"
#import "lowPolyAxesAndModels2.h"

typedef NS_ENUM(NSInteger, SceneTransformationSelector){
    SceneTranslate = 0,
    SceneRotate,
    SceneScale,
};

typedef NS_ENUM(NSInteger, SceneTransformationAxisSelector){
    SceneXAxis = 0,
    SceneYAxis,
    SceneZAxis,
};


@interface BasicTransformViewController ()<GLKViewDelegate>
@property (weak, nonatomic) IBOutlet UISlider *firstSlider;
@property (weak, nonatomic) IBOutlet UISlider *secondSlider;
@property (weak, nonatomic) IBOutlet UISlider *thirdSlider;

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (strong, nonatomic) GLKView *glkView;
@end

@implementation BasicTransformViewController
{
    SceneTransformationSelector      _transform1Type;
    SceneTransformationAxisSelector  _transform1Axis;
    CGFloat                          _transform1Value;
    SceneTransformationSelector      _transform2Type;
    SceneTransformationAxisSelector  _transform2Axis;
    CGFloat                          _transform2Value;
    SceneTransformationSelector      _transform3Type;
    SceneTransformationAxisSelector  _transform3Axis;
    CGFloat                          _transform3Value;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    GLKView *glkView = [[GLKView alloc] init];
    [self.view addSubview:glkView];
    glkView.frame = CGRectMake(0, 120, 375, 400);
    self.glkView = glkView;
    
    glkView.delegate = self;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glkView.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.4f, 0.4f, 0.4f, 1.0f);
    self.baseEffect.light0.position = GLKVector4Make(1.0f, 0.8f, 0.4f, 0.0f);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);

    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat))
                                                                         numberOfVertices:sizeof(lowPolyAxesAndModels2Verts) / (3 * sizeof(GLfloat))
                                                                                     data:lowPolyAxesAndModels2Verts
                                                                                    usage:GL_STATIC_DRAW];
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat))
                                                                       numberOfVertices:sizeof(lowPolyAxesAndModels2Normals) / (3 * sizeof(GLfloat))
                                                                                   data:lowPolyAxesAndModels2Normals
                                                                                  usage:GL_STATIC_DRAW];

    glEnable(GL_DEPTH_TEST);
    
    //坐标系变换
    GLKMatrix4 modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(30.0f),
                                                        1.0,  // Rotate about X axis
                                                        0.0,
                                                        0.0);
    modelviewMatrix = GLKMatrix4Rotate(modelviewMatrix,
                                       GLKMathDegreesToRadians(-30.0f),
                                       0.0,
                                       1.0,  // Rotate about Y axis
                                       0.0);
    modelviewMatrix = GLKMatrix4Translate(modelviewMatrix,
                                          -0.25,
                                          0.0,
                                          -0.20);

    self.baseEffect.transform.modelviewMatrix = modelviewMatrix;
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)dealloc{

    self.vertexPositionBuffer = nil;
    self.vertexNormalBuffer = nil;
    
    self.glkView.context = nil;
    [EAGLContext setCurrentContext:nil];
}

#pragma mark - delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    //变换
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-0.5 * aspectRatio,
                                                                    0.5 * aspectRatio,
                                                                    -0.5,
                                                                    0.5,
                                                                    -5.0,
                                                                    5.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    [self.vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexNormalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCordinates:3 attribOffset:0 shouldEnable:YES];

    //保存当前Modelview矩阵
    GLKMatrix4 savedModelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    
    //转换用户三次操作
    GLKMatrix4 newModelviewMatrix = GLKMatrix4Multiply(savedModelviewMatrix,SceneMatrixForTransform(_transform1Type, _transform1Axis, _transform1Value));
    newModelviewMatrix = GLKMatrix4Multiply(newModelviewMatrix, SceneMatrixForTransform(_transform2Type, _transform2Axis, _transform2Value));
    newModelviewMatrix = GLKMatrix4Multiply(newModelviewMatrix, SceneMatrixForTransform(_transform3Type, _transform3Axis, _transform3Value));
    
    //准备开始绘制变换坐标系后的图形
    self.baseEffect.transform.modelviewMatrix = newModelviewMatrix;
    
    //白光
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, lowPolyAxesAndModels2NumVerts);

    
    // 准备绘制坐标系变换迁的矩阵
    self.baseEffect.transform.modelviewMatrix =
    savedModelviewMatrix;
    
    // 改变光源颜色渲染旧的矩阵
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 0.0f, 0.3f);
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, lowPolyAxesAndModels2NumVerts);
}

#pragma mark - target

/**********   slider   ************/
- (IBAction)changeFirstSlider:(UISlider *)sender {
    _transform1Value = sender.value;
    [self.glkView display];
}
- (IBAction)changeSecondSlider:(UISlider *)sender {
    _transform2Value = sender.value;
    [self.glkView display];
}
- (IBAction)changeThirdSlider:(UISlider *)sender {
    _transform3Value = sender.value;
    [self.glkView display];
}

/**********   transform type ***********/
- (IBAction)takeFirstTransformType:(UISegmentedControl *)sender {
    _transform1Type = [sender selectedSegmentIndex];
}
- (IBAction)takeSecondTransformType:(UISegmentedControl *)sender {
    _transform2Type = [sender selectedSegmentIndex];
}
- (IBAction)takeThirdTransformType:(UISegmentedControl *)sender {
    _transform3Type = [sender selectedSegmentIndex];
}

/**********   transform direction   ***********/
- (IBAction)takeFirstTransformDirection:(UISegmentedControl *)sender {
    _transform1Axis = [sender selectedSegmentIndex];
}
- (IBAction)takeSecondTransformDirection:(UISegmentedControl *)sender {
    _transform2Axis = [sender selectedSegmentIndex];
}
- (IBAction)takeThirdTransformDirection:(UISegmentedControl *)sender {
_transform3Axis = [sender selectedSegmentIndex];
}

/**
 Reset config
 */
- (IBAction)didClickResetButton:(id)sender {
    
    [_firstSlider setValue:0.0];
    [_secondSlider setValue:0.0];
    [_thirdSlider setValue:0.0];
    _transform1Value = 0.0;
    _transform2Value = 0.0;
    _transform3Value = 0.0;
    
    [self.glkView display];
}
#pragma mark - func
/**
 生产出用户选择后的坐标系
 */
static GLKMatrix4 SceneMatrixForTransform(SceneTransformationSelector type,
                                          SceneTransformationAxisSelector axis,
                                          float value)
{
    GLKMatrix4 result = GLKMatrix4Identity;
    
    switch (type) {
        case SceneRotate:
            switch (axis) {
                case SceneXAxis:
                    result = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180.0 * value),
                                                    1.0,
                                                    0.0,
                                                    0.0);
                    break;
                case SceneYAxis:
                    result = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180.0 * value),
                                                    0.0,
                                                    1.0,
                                                    0.0);
                    break;
                case SceneZAxis:
                default:
                    result = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180.0 * value),
                                                    0.0,
                                                    0.0,
                                                    1.0);
                    break;
            }
            break;
        case SceneScale:
            switch (axis) {
                case SceneXAxis:
                    result = GLKMatrix4MakeScale(1.0 + value,
                                                 1.0,
                                                 1.0);
                    break;
                case SceneYAxis:
                    result = GLKMatrix4MakeScale(1.0,
                                                 1.0 + value,
                                                 1.0);
                    break;
                case SceneZAxis:
                default:
                    result = GLKMatrix4MakeScale(1.0,
                                                 1.0,
                                                 1.0 + value);
                    break;
            }
            break;
        default:
            switch (axis) {
                case SceneXAxis:
                    //乘0.3是为了减少位移量
                    result = GLKMatrix4MakeTranslation(0.3 * value,
                                                       0.0,
                                                       0.0);
                    break;
                case SceneYAxis:
                    result = GLKMatrix4MakeTranslation(0.0,
                                                       0.3 * value,
                                                       0.0);
                    break;
                case SceneZAxis:
                default:
                    result = GLKMatrix4MakeTranslation(0.0,
                                                       0.0,
                                                       0.3 * value);
                    break;
            }
            break;
    }
    
    return result;
}

@end
