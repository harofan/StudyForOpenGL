//
//  MixedFragmentViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/24.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "MixedFragmentViewController.h"
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

@interface MixedFragmentViewController ()<GLKViewDelegate>

@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) GLKTextureInfo *textureInfo0;
@property (strong, nonatomic) GLKTextureInfo *textureInfo1;

@end

@implementation MixedFragmentViewController

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
    //这里不要自作聪明用完就将他释放,也不要在dealloc里释放,否则会莫名奇妙的崩溃
    //GLKTextureLoaderOriginBottomLeft 翻转Y坐标
    CGImageRef imageRef0 = [[UIImage imageNamed:@"leaves"] CGImage];
    self.textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0
                                                     options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [NSNumber numberWithBool:YES],
                                                              GLKTextureLoaderOriginBottomLeft, nil]
                                                       error:NULL];
    
    //设置纹理1
    CGImageRef imageRef1 = [[UIImage imageNamed:@"beetle"] CGImage];
    self.textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1
                                                     options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [NSNumber numberWithBool:YES],
                                                              GLKTextureLoaderOriginBottomLeft, nil]
                                                       error:NULL];
    
    //混合片元颜色
    glEnable(GL_BLEND);
    //最常用的混合模式,第一个参数指定每个片元的最终颜色元素怎么影响混合的
    //第二个参数用于指定在目标帧缓存中已经存在的颜色元素怎么影响混合
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}
#pragma mark - delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
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
    
    self.baseEffect.texture2d0.name = self.textureInfo0.name;
    self.baseEffect.texture2d0.target = self.textureInfo0.target;
    [self.baseEffect prepareToDraw];
    
    //画三角形
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)];
    
    self.baseEffect.texture2d0.name = self.textureInfo1.name;
    self.baseEffect.texture2d0.target = self.textureInfo1.target;
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
