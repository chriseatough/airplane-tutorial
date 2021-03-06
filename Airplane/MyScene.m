//
//  MyScene.m
//  Airplane
//
//  Created by Christopher Eatough on 11/11/2013.
//  Copyright (c) 2013 Christopher Eatough. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        //init several sizes used in all scene
        screenRect = [[UIScreen mainScreen] bounds];
        screenHeight = screenRect.size.height;
        screenWidth = screenRect.size.width;
        
        //adding the airplane
        _plane = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 8 N.png"];
        _plane.scale = 0.6;
        _plane.zPosition = [self getRandomNumberBetween:1 to:2];
        _plane.position = CGPointMake(screenWidth/2, 15+_plane.size.height/2);
        [self addChild:_plane];
        
        // adding a physics body
        _plane.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_plane.size];
        _plane.physicsBody.dynamic = YES;
        _plane.physicsBody.categoryBitMask = playerCategory;
        _plane.physicsBody.contactTestBitMask = enemyCategory;
        _plane.physicsBody.collisionBitMask = 0;
        
        //adding the background
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"airPlanesBackground"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:background];
        
        //adding airplane shadow
        _planeShadow = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 8 SHADOW.png"];
        _planeShadow.scale = 0.6;
        _planeShadow.zPosition = _plane.zPosition - 1;
        _planeShadow.position = CGPointMake(screenWidth/2+15, 0+_planeShadow.size.height/2);
        [self addChild:_planeShadow];
        
        //adding propeller animation
        _propeller = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE PROPELLER 1.png"];
        _propeller.scale = 0.2;
        _propeller.position = CGPointMake(screenWidth/2, _plane.size.height+10);
        
        SKTexture *propeller1 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 1.png"];
        SKTexture *propeller2 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 2.png"];
        
        SKAction *spin = [SKAction animateWithTextures:@[propeller1,propeller2] timePerFrame:0.1];
        SKAction *spinForever = [SKAction repeatActionForever:spin];
        [_propeller runAction:spinForever];
        
        [self addChild:_propeller];
        
        
        //CoreMotion
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = .2;
        //self.motionManager.gyroUpdateInterval = .2;
        
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                     [self outputAccelertionData:accelerometerData.acceleration];
                                                     if(error){
                                                         
                                                         NSLog(@"%@", error);
                                                     }
                                                 }];
        
        //adding the smokeTrail
        NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"trail" ofType:@"sks"];
        _smokeTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
        _smokeTrail.position = CGPointMake(screenWidth/2, 15);
        [self addChild:_smokeTrail];
        
        //schedule enemies
        SKAction *wait = [SKAction waitForDuration:1];
        SKAction *callEnemies = [SKAction runBlock:^{
            [self EnemiesAndClouds];
        }];
        
        SKAction *updateEnimies = [SKAction sequence:@[wait,callEnemies]];
        [self runAction:[SKAction repeatActionForever:updateEnimies]];
        
        //load explosions
        SKTextureAtlas *explosionAtlas = [SKTextureAtlas atlasNamed:@"EXPLOSION"];
        NSArray *textureNames = [explosionAtlas textureNames];
        _explosionTextures = [NSMutableArray new];
        for (NSString *name in textureNames) {
            SKTexture *texture = [explosionAtlas textureNamed:name];
            [_explosionTextures addObject:texture];
        }
        
        //load clouds
        SKTextureAtlas *cloudsAtlas = [SKTextureAtlas atlasNamed:@"Clouds"];
        NSArray *textureNamesClouds = [cloudsAtlas textureNames];
        _cloudsTextures = [NSMutableArray new];
        for (NSString *name in textureNamesClouds) {
            SKTexture *texture = [cloudsAtlas textureNamed:name];
            [_cloudsTextures addObject:texture];
        }
        
        // adding a label that has the players score
        _scoreNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _scoreNode.text = [NSString stringWithFormat:@"%d", score];
        _scoreNode.fontSize = 20;
        _scoreNode.position = CGPointMake(10, 0);
        [self addChild:_scoreNode];

        // adding a label that has the players lives
        lives = 3;
        _livesNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _livesNode.text = [NSString stringWithFormat:@"%d", lives];
        _livesNode.fontSize = 20;
        _livesNode.position = CGPointMake(screenWidth - 20, 0);
        [self addChild:_livesNode];
        
    }
    return self;
}

-(void)EnemiesAndClouds{
    //not always come
    int GoOrNot = [self getRandomNumberBetween:0 to:1];
    
    if(GoOrNot == 1){
        
        SKSpriteNode *enemy;
        
        int randomEnemy = [self getRandomNumberBetween:0 to:1];
        if(randomEnemy == 0)
            enemy = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 1 N.png"];
        else
            enemy = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 2 N.png"];
        
        
        enemy.scale = 0.6;
        
        enemy.position = CGPointMake(screenRect.size.width/2, screenRect.size.height/2);
        enemy.zPosition = [self getRandomNumberBetween:0 to:1];
        
        
        CGMutablePathRef cgpath = CGPathCreateMutable();
        
        //random values
        float xStart = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
        float xEnd = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
        
        //ControlPoint1
        float cp1X = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
        float cp1Y = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.height ];
        
        //ControlPoint2
        float cp2X = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
        float cp2Y = [self getRandomNumberBetween:0 to:cp1Y];
        
        CGPoint s = CGPointMake(xStart, 1024.0);
        CGPoint e = CGPointMake(xEnd, -100.0);
        CGPoint cp1 = CGPointMake(cp1X, cp1Y);
        CGPoint cp2 = CGPointMake(cp2X, cp2Y);
        CGPathMoveToPoint(cgpath,NULL, s.x, s.y);
        CGPathAddCurveToPoint(cgpath, NULL, cp1.x, cp1.y, cp2.x, cp2.y, e.x, e.y);
        
        SKAction *planeDestroy = [SKAction followPath:cgpath asOffset:NO orientToPath:YES duration:5];
        [self addChild:enemy];
        
        SKAction *remove = [SKAction removeFromParent];
        [enemy runAction:[SKAction sequence:@[planeDestroy,remove]]];
        
        CGPathRelease(cgpath);
        
        enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.size];
        enemy.physicsBody.dynamic = YES;
        enemy.physicsBody.categoryBitMask = enemyCategory;
        enemy.physicsBody.contactTestBitMask = bulletCategory;
        enemy.physicsBody.collisionBitMask = 0;
        
        //random Clouds
        int randomClouds = [self getRandomNumberBetween:0 to:1];
        if(randomClouds == 1){
            
            int whichCloud = [self getRandomNumberBetween:0 to:3];
            SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithTexture:[_cloudsTextures objectAtIndex:whichCloud]];
            
            // setting the starting position of the cloud
            int startingX = [self getRandomNumberBetween:0 to:screenRect.size.width];
            int startingY = screenRect.size.height + cloud.size.height;
            cloud.position = CGPointMake(startingX, startingY);
            cloud.zPosition = [self getRandomNumberBetween:0 to:1];

            // setting the ending position of the cloud, and the duration it takes to arrive there
            int randomTimeCloud = [self getRandomNumberBetween:9 to:19];
            int endingX = startingX;
            int endingY = 0 - cloud.size.height;

            SKAction *move =[SKAction moveTo:CGPointMake(endingX, endingY) duration:randomTimeCloud];
            SKAction *remove = [SKAction removeFromParent];
            [cloud runAction:[SKAction sequence:@[move,remove]]];
            [self addChild:cloud];
        }
        
    }
    
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    
    if(fabs(acceleration.x) > fabs(currentMaxAccelX))
    {
        currentMaxAccelX = acceleration.x;
    }
    if(fabs(acceleration.y) > fabs(currentMaxAccelY))
    {
        currentMaxAccelY = acceleration.y;
    }
    
    
}

-(void)update:(NSTimeInterval)currentTime{
    //NSLog(@"one second");
    
    
    float maxY = screenRect.size.width - _plane.size.width/2;
    float minY = _plane.size.width/2;
    
    
    float maxX = screenRect.size.height - _plane.size.height/2;
    float minX = _plane.size.height/2;
    
    float newY = 0;
    float newX = 0;
    
    if(currentMaxAccelX > 0.05){
        newX = currentMaxAccelX * 10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 R.png"];
    }
    else if(currentMaxAccelX < -0.05){
        newX = currentMaxAccelX*10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 L.png"];
    }
    else{
        newX = currentMaxAccelX*10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 N.png"];
    }
    
    newY = 6.0 + currentMaxAccelY *10;
    
    float newXshadow = newX+_planeShadow.position.x;
    float newYshadow = newY+_planeShadow.position.y;
    
    newXshadow = MIN(MAX(newXshadow,minY+15),maxY+15);
    newYshadow = MIN(MAX(newYshadow,minX-15),maxX-15);
    
    float newXpropeller = newX+_propeller.position.x;
    float newYpropeller = newY+_propeller.position.y;
    
    newXpropeller = MIN(MAX(newXpropeller,minY),maxY);
    newYpropeller = MIN(MAX(newYpropeller,minX+(_plane.size.height/2)-5),maxX+(_plane.size.height/2)-5);
    
    newX = MIN(MAX(newX+_plane.position.x,minY),maxY);
    newY = MIN(MAX(newY+_plane.position.y,minX),maxX);
    
    
    _plane.position = CGPointMake(newX, newY);
    _planeShadow.position = CGPointMake(newXshadow, newYshadow);
    _propeller.position = CGPointMake(newXpropeller, newYpropeller);
    _smokeTrail.position = CGPointMake(newX,newY-(_plane.size.height/2));
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    CGPoint location = [_plane position];
    SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithImageNamed:@"B 2.png"];
    
    bullet.position = CGPointMake(location.x,location.y+_plane.size.height/2);
    //bullet.position = location;
    bullet.zPosition = 1;
    bullet.scale = 0.8;
    
    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.size];
    bullet.physicsBody.dynamic = NO;
    bullet.physicsBody.categoryBitMask = bulletCategory;
    bullet.physicsBody.contactTestBitMask = enemyCategory;
    bullet.physicsBody.collisionBitMask = 0;
    
    SKAction *action = [SKAction moveToY:self.frame.size.height+bullet.size.height duration:2];
    SKAction *remove = [SKAction removeFromParent];
    
    [bullet runAction:[SKAction sequence:@[action,remove]]];
    
    [self addChild:bullet];
}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (firstBody.categoryBitMask == bulletCategory && secondBody.categoryBitMask == enemyCategory)
    {
        
        SKNode *projectile = (contact.bodyA.categoryBitMask & bulletCategory) ? contact.bodyA.node : contact.bodyB.node;
        SKNode *enemy = (contact.bodyA.categoryBitMask & bulletCategory) ? contact.bodyB.node : contact.bodyA.node;
        [projectile runAction:[SKAction removeFromParent]];
        [enemy runAction:[SKAction removeFromParent]];
        
        score++;
        _scoreNode.text = [NSString stringWithFormat:@"%d", score];
        
        //add explosion
        SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[_explosionTextures objectAtIndex:0]];
        explosion.zPosition = 1;
        explosion.scale = 0.6;
        explosion.position = contact.bodyA.node.position;
        [self addChild:explosion];
        
        SKAction *explosionAction = [SKAction animateWithTextures:_explosionTextures timePerFrame:0.07];
        SKAction *remove = [SKAction removeFromParent];
        [explosion runAction:[SKAction sequence:@[explosionAction,remove]]];
        
    }

    // if there is a collision between the player and an enemy plane
    if ((firstBody.categoryBitMask == playerCategory && secondBody.categoryBitMask == enemyCategory)
        || (firstBody.categoryBitMask == enemyCategory && secondBody.categoryBitMask == playerCategory)){

        SKNode *enemy = (contact.bodyB.categoryBitMask & enemyCategory) ? contact.bodyB.node : contact.bodyA.node;
        [enemy runAction:[SKAction removeFromParent]];
        
        // http://www.youtube.com/watch?v=IJtaYgN-_dw - pulse red when a collision occurs
        SKAction *pulseRed = [SKAction sequence:@[
                                                  [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.2],
                                                  [SKAction colorizeWithColorBlendFactor:0.0 duration:0.2]
                                                  ]];
        [_plane runAction:pulseRed];

        if (lives == 0) {
            [_plane runAction:[SKAction removeFromParent]];
            [_planeShadow runAction:[SKAction removeFromParent]];
            [_propeller runAction:[SKAction removeFromParent]];
            [_smokeTrail runAction:[SKAction removeFromParent]];
            
            // http://www.youtube.com/watch?v=IJtaYgN-_dw - transition to a new scene (this one, again)
            SKScene *nextScene = [[MyScene alloc] initWithSize:self.size];
            SKTransition *doors = [SKTransition doorsCloseVerticalWithDuration:0.5];
            [self.view presentScene:nextScene transition:doors];
        }

        //add explosion
        SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[_explosionTextures objectAtIndex:0]];
        explosion.zPosition = 1;
        explosion.scale = 0.6;
        explosion.position = contact.bodyA.node.position;
        [self addChild:explosion];

        SKAction *explosionAction = [SKAction animateWithTextures:_explosionTextures timePerFrame:0.07];
        SKAction *remove = [SKAction removeFromParent];
        [explosion runAction:[SKAction sequence:@[explosionAction,remove]]];

        lives--;
        _livesNode.text = [NSString stringWithFormat:@"%d", lives];
        
    }
    
}


@end
