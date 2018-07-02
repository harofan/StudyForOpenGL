//
//  TextureTransformViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/5/18.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "TextureTransformViewController.h"
#import <GLKit/GLKit.h>
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKTextureTransformBaseEffect.h"

@interface TextureTransformViewController ()<GLKViewDelegate>

@property (strong, nonatomic) AGLKTextureTransformBaseEffect *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (assign, nonatomic) CGFloat textureScaleFactor;
@property (assign, nonatomic) CGFloat textureAngle;
@property (nonatomic) GLKMatrixStackRef textureMatrixStack;
@property (strong, nonatomic) GLKView *glkView;

@end

typedef struct {
    GLKVector3  positionCoords;
    GLKVector2  textureCoords;
}SceneVertex;

static const SceneVertex vertices[] =
{
    {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}},  // first triangle
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},  // second triangle
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
};

@implementation TextureTransformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.textureMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    self.textureScaleFactor = 1.0;
    
    GLKView *glkView = [[GLKView alloc] initWithFrame:CGRectMake(0, 0, 375, 500)];
    glkView.delegate = self;
    self.glkView = glkView;
    [self.view addSubview:glkView];
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glkView.context];
    
    self.baseEffect = [[AGLKTextureTransformBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, // Red
                                                   1.0f, // Green
                                                   1.0f, // Blue
                                                   1.0f);// Alpha
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex)
                                                                 numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)
                                                                             data:vertices
                                                                            usage:GL_STATIC_DRAW];
    
    //texture0
    CGImageRef imageRef0 = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    GLKTextureInfo *textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0
                                                                options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil]
                                                                  error:NULL];
    self.baseEffect.texture2d0.name = textureInfo0.name;
    self.baseEffect.texture2d0.target = textureInfo0.target;
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    
    //texture1
    CGImageRef imageRef1 = [[UIImage imageNamed:@"beetle.png"] CGImage];
    GLKTextureInfo *textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1
                                                                options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil]
                                                                  error:NULL];
    self.baseEffect.texture2d1.name = textureInfo1.name;
    self.baseEffect.texture2d1.target = textureInfo1.target;
    self.baseEffect.texture2d1.enabled = GL_TRUE;
    self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    [self.baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_S
                                           value:GL_REPEAT];
    [self.baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_T
                                           value:GL_REPEAT];

    //Replaces the topmost matrix with the matrix provided.
    GLKMatrixStackLoadMatrix4(self.textureMatrixStack,
                              self.baseEffect.textureMatrix2d1);
    
}

- (void)dealloc{
    [EAGLContext setCurrentContext:self.glkView.context];
    self.vertexBuffer = nil;
    self.glkView.context = nil;
    [EAGLContext setCurrentContext:self.glkView.context];
    CFRelease(self.textureMatrixStack);
    self.textureMatrixStack = NULL;
}

#pragma mark - delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClear(GL_COLOR_BUFFER_BIT);

    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                            numberOfCordinates:3
                                  attribOffset:offsetof(SceneVertex, positionCoords)
                                  shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                            numberOfCordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord1
                            numberOfCordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];

    //Pushes all of the matrices down one level and copies the topmost matrix.
    GLKMatrixStackPush(self.textureMatrixStack);
    
    //旋转, 位移, 缩放
    GLKMatrixStackTranslate(self.textureMatrixStack,
                            0.5, 0.5, 0.0);
    GLKMatrixStackScale(self.textureMatrixStack,
                        _textureScaleFactor, _textureScaleFactor, 1.0);
    GLKMatrixStackRotate(self.textureMatrixStack,
                         GLKMathDegreesToRadians(_textureAngle),
                         0.0, 0.0, 1.0);//z 轴
    GLKMatrixStackTranslate(self.textureMatrixStack,
                            -0.5, -0.5, 0.0);
    
    self.baseEffect.textureMatrix2d1 = GLKMatrixStackGetMatrix4(self.textureMatrixStack);
    [self.baseEffect prepareToDrawMultitextures];
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)];
    
    //Pops the topmost matrix off of the stack, moving the rest of the matrices up one level.
    GLKMatrixStackPop(self.textureMatrixStack);
    
    self.baseEffect.textureMatrix2d1 = GLKMatrixStackGetMatrix4(self.textureMatrixStack);
}

- (IBAction)changeScaleSlider:(UISlider *)sender {
    self.textureScaleFactor = [sender value];
    [self.glkView display];
}
- (IBAction)changeRotateSlider:(UISlider *)sender {
    self.textureAngle = [sender value];
    [self.glkView display];
}

@end
