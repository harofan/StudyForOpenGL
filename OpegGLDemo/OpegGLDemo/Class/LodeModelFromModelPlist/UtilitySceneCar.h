//
//  UtilitySceneCar.h
//  OpegGLDemo
//
//  Created by 范杨 on 2018/7/9.
//  Copyright © 2018年 RPGLiker. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "UtilityModel.h"

@protocol UtilitySceneCarControllerProtocol

- (NSTimeInterval)timeSinceLastUpdate;
- (AGLKAxisAllignedBoundingBox)rinkBoundingBox;
- (NSArray *)cars;

@end

@interface UtilitySceneCar : NSObject
@property (strong, nonatomic, readonly) UtilityModel *model;
@property (assign, nonatomic, readonly) GLKVector3 position;
@property (assign, nonatomic, readonly) GLKVector3 nextPosition;
@property (assign, nonatomic, readonly) GLKVector3 velocity;
@property (assign, nonatomic, readonly) GLfloat yawRadians;
@property (assign, nonatomic, readonly) GLfloat targetYawRadians;
@property (assign, nonatomic, readonly) GLKVector4 color;
@property (assign, nonatomic, readonly) GLfloat radius;

- (id)initWithModel:(UtilityModel *)aModel
           position:(GLKVector3)aPosition
           velocity:(GLKVector3)aVelocity
              color:(GLKVector4)aColor;

- (void)updateWithController:(id <UtilitySceneCarControllerProtocol>)controller;
- (void)drawWithBaseEffect:(GLKBaseEffect *)anEffect;
@end

extern GLfloat UtilitySceneScalarFastLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                            GLfloat target,
                                            GLfloat current);

extern GLfloat UtilitySceneScalarSlowLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                            GLfloat target,
                                            GLfloat current);

extern GLKVector3 UtilitySceneVector3FastLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                                GLKVector3 target,
                                                GLKVector3 current);

extern GLKVector3 UtilitySceneVector3SlowLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                                GLKVector3 target,
                                                GLKVector3 current);
