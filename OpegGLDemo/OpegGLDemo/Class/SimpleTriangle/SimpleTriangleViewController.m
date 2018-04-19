//
//  SimpleTriangleViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/18.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import "SimpleTriangleViewController.h"
#import <GLKit/GLKit.h>

@interface SimpleTriangleViewController ()<GLKViewDelegate>
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) GLKView *glkView;
@end

struct SceneVertex{
    GLKVector3 positionCoords;
};
//渲染顶点数据
static const struct SceneVertex vertices[] = {
    {{-0.5f, -0.5f, 0.0}},//下左
    {{0.5f, -0.5f, 0.0}},//下右
    {{-0.5f, 0.5f, 0.0}},//上左
};

static GLuint vertexBufferID;
@implementation SimpleTriangleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self p_startOpegGL];
}

- (void)dealloc{
    [EAGLContext setCurrentContext:self.glkView.context];
    if (0 != vertexBufferID) {
        glDeleteBuffers(1, &vertexBufferID);
        vertexBufferID = 0;
    }
    self.glkView.context = nil;
    [EAGLContext setCurrentContext:nil];
}

- (void)p_startOpegGL{
    
    //渲染一个三角形有六个步骤
    //1.为缓存生成一个独一无二的标识符   glGenBuffers
    //2.为接下来的运算绑定缓存         glBindBuffer
    //3.复制数据到缓存中              glBufferData
    
    GLKView *view = [[GLKView alloc] init];
    self.glkView = view;
    [self.view addSubview:view];
    view.frame = self.view.bounds;
    view.delegate = self;
    
    NSLog(@"%@",[view class]);
    //OpegGL ES 2.0
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    //设置当前上下文
    [EAGLContext setCurrentContext:view.context];
    
    //背景色
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    
    //绑定
    //生成一个缓存标识 第二个是缓存标识的存储位置
    glGenBuffers(1, &vertexBufferID);
    //绑定用于指定标识符的缓存到当前缓存
    glBindBuffer(GL_ARRAY_BUFFER,//指定一个顶点数组类型
                 vertexBufferID);//要绑定的缓存标识符
    //复制顶点数据到上下文绑定的缓存数据中
    glBufferData(GL_ARRAY_BUFFER,//指定上下文中更新要绑定的哪个缓存
                 sizeof(vertices),//复制进去的字节量
                 vertices,//复制字节的地址
                 GL_STATIC_DRAW);//缓存在未来如何被使用
}

#pragma mark - delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    //4.启动      glEnableVertexAttribArray
    //5.设置指针   glVertexAttribPointer
    //6.绘图      glDrawArrays
    [self.baseEffect prepareToDraw];
    //清除 frame buffer
    glClear(GL_COLOR_BUFFER_BIT);
    //启动顶点缓存渲染
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //告诉OpegGL ES顶点数据在哪,以及解释顶点数据是怎么保存的
    glVertexAttribPointer(GLKVertexAttribPosition,//缓存包含的每个顶点的位置信息
                          3,//每个位置3部分
                          GL_FLOAT,//每个部分保存为一个浮点值
                          GL_FALSE,//小数点固定数据不能被改变,使用浮点数能优化GPU的运算量,并且提高精度
                          sizeof(struct SceneVertex),//步幅,每个顶点保存需要多少字节
                          NULL);//从当前绑定的顶点缓存的开始位置访问顶点数据
    //画三角形
    glDrawArrays(GL_TRIANGLES,//告诉GPU怎么处理在绑定的顶点缓存内的顶点数据,这里指示去渲染三角形
                 0,//从第一个顶点开始画
                 3);//需要渲染的顶点数量
    
}

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
