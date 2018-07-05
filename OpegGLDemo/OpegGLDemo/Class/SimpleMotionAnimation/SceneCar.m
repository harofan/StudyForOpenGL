//
//  SceneCar.m
//  
//

#import "SceneCar.h"


@interface SceneCar ()

@property (strong, nonatomic, readwrite) SceneModel
*model;
@property (assign, nonatomic, readwrite) GLKVector3 
position;
@property (assign, nonatomic, readwrite) GLKVector3 
nextPosition;
@property (assign, nonatomic, readwrite) GLKVector3 
velocity;
@property (assign, nonatomic, readwrite) GLfloat 
yawRadians;
@property (assign, nonatomic, readwrite) GLfloat 
targetYawRadians;
@property (assign, nonatomic, readwrite) GLKVector4 
color;
@property (assign, nonatomic, readwrite) GLfloat 
radius;

@end


@implementation SceneCar

@synthesize model;
@synthesize position;
@synthesize velocity;
@synthesize yawRadians;
@synthesize targetYawRadians;
@synthesize color;
@synthesize nextPosition;
@synthesize radius;


/////////////////////////////////////////////////////////////////
// Returns nil
- (id)init
{
    NSAssert(0, @"Invalid initializer");
    
    self = nil;
    
    return self;
}


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)initWithModel:(SceneModel *)aModel
           position:(GLKVector3)aPosition
           velocity:(GLKVector3)aVelocity
              color:(GLKVector4)aColor;
{
    if(nil != (self = [super init]))
    {
        self.position = aPosition;
        self.color = aColor;
        self.velocity = aVelocity;
        self.model = aModel;
        
        SceneAxisAllignedBoundingBox axisAlignedBoundingBox =
        self.model.axisAlignedBoundingBox;
        
        // Half the widest diameter is radius
        self.radius = 0.5f * MAX(axisAlignedBoundingBox.max.x -
                                 axisAlignedBoundingBox.min.x,
                                 axisAlignedBoundingBox.max.z -
                                 axisAlignedBoundingBox.min.z);
    }
    
    return self;
}


//墙壁碰撞行为
- (void)bounceOffWallsWithBoundingBox:(SceneAxisAllignedBoundingBox)rinkBoundingBox
{
    if((rinkBoundingBox.min.x + self.radius) > self.nextPosition.x)
    {
        self.nextPosition = GLKVector3Make((rinkBoundingBox.min.x + self.radius),
                                           self.nextPosition.y, self.nextPosition.z);
        self.velocity = GLKVector3Make(-self.velocity.x,
                                       self.velocity.y, self.velocity.z);
    }else if((rinkBoundingBox.max.x - self.radius) < self.nextPosition.x)
    {
        self.nextPosition = GLKVector3Make((rinkBoundingBox.max.x - self.radius),
                                           self.nextPosition.y, self.nextPosition.z);
        self.velocity = GLKVector3Make(-self.velocity.x,
                                       self.velocity.y, self.velocity.z);
    }
    
    if((rinkBoundingBox.min.z + self.radius) > self.nextPosition.z)
    {
        self.nextPosition = GLKVector3Make(self.nextPosition.x,
                                           self.nextPosition.y,
                                           (rinkBoundingBox.min.z + self.radius));
        self.velocity = GLKVector3Make(self.velocity.x,
                                       self.velocity.y, -self.velocity.z);
    }else if((rinkBoundingBox.max.z - self.radius) < self.nextPosition.z)
    {
        self.nextPosition = GLKVector3Make(self.nextPosition.x,
                                           self.nextPosition.y,
                                           (rinkBoundingBox.max.z - self.radius));
        self.velocity = GLKVector3Make(self.velocity.x,
                                       self.velocity.y, -self.velocity.z);
    }
}


//仿真车辆与车辆的碰撞,使其反弹
- (void)bounceOffCars:(NSArray *)cars
          elapsedTime:(NSTimeInterval)elapsedTimeSeconds
{
    for(SceneCar *currentCar in cars)
    {
        if(currentCar != self)
        {
            //计算其他三辆车下一个位置与自己下一个位置的距离
            float distance = GLKVector3Distance(self.nextPosition, currentCar.nextPosition);
            
            if((2.0f * self.radius) > distance)
            {  //发生碰撞
                GLKVector3 ownVelocity = self.velocity;
                GLKVector3 otherVelocity = currentCar.velocity;
                //利用向量差求出另一辆车的方向
                GLKVector3 directionToOtherCar = GLKVector3Subtract(currentCar.position,
                                                                    self.position);
                //返回单位向量
                directionToOtherCar = GLKVector3Normalize(directionToOtherCar);
                //另一辆车的反方向(自己车的方向)
                GLKVector3 negDirectionToOtherCar = GLKVector3Negate(directionToOtherCar);
                
                //返回通过将向量的每个分量乘以标量值而创建的新向量。
                GLKVector3 tanOwnVelocity = GLKVector3MultiplyScalar(negDirectionToOtherCar, GLKVector3DotProduct(ownVelocity, negDirectionToOtherCar));
                GLKVector3 tanOtherVelocity = GLKVector3MultiplyScalar(directionToOtherCar, GLKVector3DotProduct(otherVelocity, directionToOtherCar));
                
                {  // 更新自己车的速度
                    self.velocity = GLKVector3Subtract(ownVelocity,
                                                       tanOwnVelocity);
                    
                    // 基于运行时间对车速进行缩放
                    GLKVector3 travelDistance = GLKVector3MultiplyScalar(self.velocity,elapsedTimeSeconds);
                    
                    //更新下一个位置
                    self.nextPosition = GLKVector3Add(self.position,
                                                      travelDistance);
                }
                
                {  // Update other car's velocity
                    currentCar.velocity = GLKVector3Subtract(
                                                             otherVelocity,
                                                             tanOtherVelocity);
                    
                    // Scale velocity based on elapsed time
                    GLKVector3 travelDistance = GLKVector3MultiplyScalar(currentCar.velocity,
                                                                         elapsedTimeSeconds);
                    
                    // Update position based on velocity and time since last
                    currentCar.nextPosition = GLKVector3Add(currentCar.position,
                                                            travelDistance);
                }
            }
        }
    }
}


//向运动方向旋转
- (void)spinTowardDirectionOfMotion:(NSTimeInterval)elapsed
{
    self.yawRadians = SceneScalarSlowLowPassFilter(elapsed,
                                                   self.targetYawRadians,
                                                   self.yawRadians);
}


//设置车辆行驶效果以及碰撞
- (void)updateWithController:(id <SceneCarControllerProtocol>)controller;
{
    //计算0.01s和0.5s的间隔时间
    NSTimeInterval   elapsedTimeSeconds =
    MIN(MAX([controller timeSinceLastUpdate], 0.01f), 0.5f);
    
    //基于间隔时间对速度进行缩放
    GLKVector3 travelDistance = GLKVector3MultiplyScalar(self.velocity,
                                                         elapsedTimeSeconds);
    
    //根据上次的位置和速度更新位置
    self.nextPosition = GLKVector3Add(self.position,
                                      travelDistance);
    
    //获取溜冰场盒子边界
    SceneAxisAllignedBoundingBox rinkBoundingBox = [controller rinkBoundingBox];
    
    //仿真碰撞
    [self bounceOffCars:[controller cars]
            elapsedTime:elapsedTimeSeconds];
    [self bounceOffWallsWithBoundingBox:rinkBoundingBox];
    
    //如果速度慢的话使其加速
    if(0.1 > GLKVector3Length(self.velocity))
    {  //速度太慢，方向不可靠，所以往新方向发射,方向是随机的
        self.velocity = GLKVector3Make((random() / (0.5f * RAND_MAX)) - 1.0f, // range -1 to 1
                                       0.0f,
                                       (random() / (0.5f * RAND_MAX)) - 1.0f);// range -1 to 1
    }else if(4 > GLKVector3Length(self.velocity))
    {  //当前方向加速
        self.velocity = GLKVector3MultiplyScalar(self.velocity,
                                                 1.01f);
    }
    
    //汽车速度方向和z方向的点积
    float dotProduct = GLKVector3DotProduct(GLKVector3Normalize(self.velocity),
                                            GLKVector3Make(0.0, 0, -1.0));
    
    //设置目标偏航角以配合汽车的运动方向
    if(0.0 > self.velocity.x)
    {  //二三象限,计算反余弦得出角度
        self.targetYawRadians = acosf(dotProduct);
    }else{  //一四象限
        self.targetYawRadians = -acosf(dotProduct);
    }
    
    //向运动方向旋转
    [self spinTowardDirectionOfMotion:elapsedTimeSeconds];
    
    self.position = self.nextPosition;
}


/////////////////////////////////////////////////////////////////
// Draw the receiver: This method sets anEffect's current 
// material color to the receivers color, translates to the 
// receiver's position, rotates to match the receiver's yaw 
// angle, draws the receiver's model. This method restores the 
// values of anEffect's properties to values in place when the 
// method was called.
- (void)drawWithBaseEffect:(GLKBaseEffect *)anEffect;
{
    // Save effect attributes that will be changed
    GLKMatrix4  savedModelviewMatrix =
    anEffect.transform.modelviewMatrix;
    GLKVector4  savedDiffuseColor =
    anEffect.material.diffuseColor;
    GLKVector4  savedAmbientColor =
    anEffect.material.ambientColor;
    
    // Translate to the model's position
    anEffect.transform.modelviewMatrix =
    GLKMatrix4Translate(savedModelviewMatrix,
                        position.x, position.y, position.z);
    
    // Rotate to match model's yaw angle (rotation about Y)
    anEffect.transform.modelviewMatrix =
    GLKMatrix4Rotate(anEffect.transform.modelviewMatrix,
                     self.yawRadians,
                     0.0, 1.0, 0.0);
    
    // Set the model's material color
    anEffect.material.diffuseColor = self.color;
    anEffect.material.ambientColor = self.color;
    
    [anEffect prepareToDraw];
    
    // Draw the model
    [model draw];
    
    // Restore saved attributes
    anEffect.transform.modelviewMatrix = savedModelviewMatrix;
    anEffect.material.diffuseColor = savedDiffuseColor;
    anEffect.material.ambientColor = savedAmbientColor;
}

@end


/////////////////////////////////////////////////////////////////
// This function returns a value between target and current. Call
// this function repeatedly to asymptotically return values closer
// to target: "ease in" to the target value.
GLfloat SceneScalarFastLowPassFilter(
                                     NSTimeInterval elapsed,    // seconds elapsed since last call
                                     GLfloat target,            // target value to approach
                                     GLfloat current)           // current value
{  // Constant 50.0 is an arbitrarily "large" factor
    return current + (50.0 * elapsed * (target - current));
}


//反复调用使目标渐渐改变旋转方向
GLfloat SceneScalarSlowLowPassFilter(NSTimeInterval elapsed,    //自从上次调用过了几秒
                                     GLfloat target,            // 目标余弦角度
                                     GLfloat current)           // 当前角度
{  // Constant 4.0 is an arbitrarily "small" factor
    return current + (4.0 * elapsed * (target - current));
}


/////////////////////////////////////////////////////////////////
// This function returns a vector between target and current. 
// Call repeatedly to asymptotically return vectors closer
// to target: "ease in" to the target value.
GLKVector3 SceneVector3FastLowPassFilter(
                                         NSTimeInterval elapsed,    // seconds elapsed since last call
                                         GLKVector3 target,         // target value to approach
                                         GLKVector3 current)        // current value
{  
    return GLKVector3Make(
                          SceneScalarFastLowPassFilter(elapsed, target.x, current.x),
                          SceneScalarFastLowPassFilter(elapsed, target.y, current.y),
                          SceneScalarFastLowPassFilter(elapsed, target.z, current.z));
}


/////////////////////////////////////////////////////////////////
// This function returns a vector between target and current. 
// Call repeatedly to asymptotically return vectors closer
// to target: "ease in" to the target value.
GLKVector3 SceneVector3SlowLowPassFilter(
                                         NSTimeInterval elapsed,    // seconds elapsed since last call
                                         GLKVector3 target,         // target value to approach
                                         GLKVector3 current)        // current value
{  
    return GLKVector3Make(SceneScalarSlowLowPassFilter(elapsed, target.x, current.x),
                          SceneScalarSlowLowPassFilter(elapsed, target.y, current.y),
                          SceneScalarSlowLowPassFilter(elapsed, target.z, current.z));
}
