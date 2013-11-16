//
//  TitleScene.h
//  Airplane
//
//  Created by Christopher Eatough on 16/11/2013.
//  Copyright (c) 2013 Christopher Eatough. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface TitleScene : SKScene {
    CGRect screenRect;
    CGFloat screenHeight;
    CGFloat screenWidth;
}

@property SKLabelNode *gameTitle;
@property SKLabelNode *subTitle;

@end
