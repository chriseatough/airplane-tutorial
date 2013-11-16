//
//  TitleScene.m
//  Airplane
//
//  Created by Christopher Eatough on 16/11/2013.
//  Copyright (c) 2013 Christopher Eatough. All rights reserved.
//

#import "TitleScene.h"
#import "MyScene.h"

@implementation TitleScene

-(id) initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        //init several sizes used in all scene
        screenRect = [[UIScreen mainScreen] bounds];
        screenHeight = screenRect.size.height;
        screenWidth = screenRect.size.width;

        // adding a label that has the players score
        _gameTitle = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _gameTitle.text = @"Airplane!";
        _gameTitle.fontSize = 40;
        _gameTitle.position = CGPointMake(screenWidth/2, screenHeight/2);
        [self addChild:_gameTitle];

        // add instructional text
        _subTitle = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _subTitle.text = @"Touch the screen to start";
        _subTitle.fontSize = 20;
        _subTitle.position = CGPointMake(screenWidth/2, (screenHeight/2)-40);
        [self addChild:_subTitle];
    }

    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    // http://www.youtube.com/watch?v=IJtaYgN-_dw - transition to a new scene (this one, again)
    SKScene *nextScene = [[MyScene alloc] initWithSize:self.size];
    SKTransition *doors = [SKTransition doorsCloseVerticalWithDuration:0.5];
    // https://developer.apple.com/library/ios/documentation/GraphicsAnimation/Conceptual/SpriteKit_PG/Transitions/Transitions.html
    doors.pausesIncomingScene = YES;
    [self.view presentScene:nextScene transition:doors];
}

@end
