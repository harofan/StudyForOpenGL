//
//  MultipleTexturesViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/23.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "MultipleTexturesViewController.h"
#import <GLKit/GLKit.h>
#import "AGLKVertexAttribArrayBuffer.h"

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

@interface MultipleTexturesViewController ()<GLKViewDelegate>

@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
//@property (strong, nonatomic) GLKTextureInfo *textureInfo0;
//@property (strong, nonatomic) GLKTextureInfo *textureInfo1;
@end

@implementation MultipleTexturesViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.view.backgroundColor = [UIColor blackColor];
    [self p_startOpegGL];
}

- (void)dealloc{
    self.vertexBuffer = nil;
    [EAGLContext setCurrentContext:nil];
}
#pragma mark - private
- (void)p_startOpegGL{
    
    GLKView *glkView = [[GLKView alloc] init];
    glkView.frame = CGRectMake(0, 0, 375, 667);
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    glkView.delegate = self;
    [self.view addSubview:glkView];
    [EAGLContext setCurrentContext:glkView.context];
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    
    //使用自己封装的一个OpegnGL渲染工具类帮助我们进行操作
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex)
                                                                 numberOfVertices:sizeof(vertices)/sizeof(SceneVertex)
                                                                             data:vertices
                                                                            usage:GL_STATIC_DRAW];
    
    //设置纹理0
    CGImageRef imageRef0 = [[UIImage imageNamed:@"leaves"] CGImage];
    GLKTextureInfo *textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0
                         options:[NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES],
                                  GLKTextureLoaderOriginBottomLeft, nil]
                         error:NULL];
    self.baseEffect.texture2d0.name = textureInfo0.name;
    self.baseEffect.texture2d0.target = textureInfo0.target;
    
    //设置纹理1
    CGImageRef imageRef1 = [[UIImage imageNamed:@"beetle"] CGImage];
    GLKTextureInfo *textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1
                         options:[NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES],
                                  GLKTextureLoaderOriginBottomLeft, nil]
                         error:NULL];
    self.baseEffect.texture2d1.name = textureInfo1.name;
    self.baseEffect.texture2d1.target = textureInfo1.target;
    
    //多重纹理模式,一般情况下这个mode的效果最好
    //这里必须要设置texture2d1的,否则效果就像是我们把叶子的纹理渲染到虫子上一般,
    //texture2d0可以不设置,不设置的话我们就会看不到下面的白底
//    self.baseEffect.texture2d0.envMode = GLKTextureEnvModeDecal;
    self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    

}
#pragma mark - delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClear(GL_COLOR_BUFFER_BIT);
    //三角顶点数据
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                            numberOfCordinates:3
                                  attribOffset:offsetof(SceneVertex, positionCoords)
                                  shouldEnable:YES];
    
    //树叶纹理数据
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                            numberOfCordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];
    
    //昆虫纹理数据
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord1
                            numberOfCordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];

    [self.baseEffect prepareToDraw];
    
    //渲染纹理
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)];
}

#pragma mark - set && get
- (GLKBaseEffect *)baseEffect{

    if (!_baseEffect) {
        //省去自己编写一个小的GPU程序
        _baseEffect = [[GLKBaseEffect alloc] init];
        _baseEffect.useConstantColor = GL_TRUE;
        _baseEffect.constantColor = GLKVector4Make(1.0f,//Red
                                                   1.0f,//Green
                                                   1.0f,//Blue
                                                   1.0f);//Alpha

    }
    return _baseEffect;
}

@end
