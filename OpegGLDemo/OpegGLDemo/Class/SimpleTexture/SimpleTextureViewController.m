//
//  SimpleTextureViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/19.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "SimpleTextureViewController.h"
#import <GLKit/GLKit.h>
#import "AGLKVertexAttribArrayBuffer.h"

typedef struct{
    GLKVector3 positionCoords;//点坐标
    GLKVector2 textureCoords;//纹理坐标
}SceneVertex;

static const SceneVertex vertices[] =
{
    {{-0.5f, -0.5f, 0.0f},{0.0f, 0.0f}},//左下角
    {{0.5f, -0.5f, 0.0f},{1.0f, 0.0f}},//右下角
    {{-0.5f, 0.5f, 0.0f},{0.0f, 1.0f}},//左上角
};

@interface SimpleTextureViewController ()<GLKViewDelegate>
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) GLKView *glkView;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexBuffer;
@end

@implementation SimpleTextureViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    [self p_startOpegGL];
}

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

    
}
#pragma mark - delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT);
    
    //三角顶点数据
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                            numberOfCordinates:3
                                  attribOffset:offsetof(SceneVertex, positionCoords)
                                  shouldEnable:YES];
    //纹理数据
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                            numberOfCordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];
    
    //渲染
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:3];
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
        
        //设置纹理
        CGImageRef imageRef = [[UIImage imageNamed:@"1"] CGImage];
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef
                                                                   options:nil//怎么解析图像加载
                                                                     error:NULL];
        
        //GLKBaseEffect提供了使用纹理做渲染的内建支持
        _baseEffect.texture2d0.name = textureInfo.name;
        _baseEffect.texture2d0.target = textureInfo.target;
    }
    return _baseEffect;
}

@end
