//
//  MyScene.h
//  Airplane
//

//  Copyright (c) 2013 Christopher Eatough. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>

static const uint8_t bulletCategory = 1;
static const uint8_t enemyCategory = 2;

@interface MyScene : SKScene<UIAccelerometerDelegate, SKPhysicsContactDelegate>
{
    CGRect screenRect;
    CGFloat screenHeight;
    CGFloat screenWidth;
    double currentMaxAccelX;
    double currentMaxAccelY;
    int score;
}

@property (strong, nonatomic) CMMotionManager *motionManager;
@property SKSpriteNode *plane;
@property SKSpriteNode *planeShadow;
@property SKSpriteNode *propeller;
@property SKEmitterNode *smokeTrail;
@property NSMutableArray *explosionTextures;
@property NSMutableArray *cloudsTextures;
@property SKLabelNode *scoreNode;

@end
