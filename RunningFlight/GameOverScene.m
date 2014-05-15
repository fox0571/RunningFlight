//
//  GameOverScene.m
//  RunningFlight
//
//  Created by fox on 14-5-15.
//  Copyright (c) 2014年 fox. All rights reserved.
//

#import "GameOverScene.h"
#import "MyScene.h"

@implementation GameOverScene

-(id) initWithSize:(CGSize)size score:(int)score{
    if (self = [super initWithSize:size]) {
        
        // 1
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // 2
        NSString * message=@"GAME OVER";
        NSString * totalScore=[NSString stringWithFormat:@"%d",score];
        
        // 3
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        SKLabelNode *label1 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        SKLabelNode *label2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label1.text=@"Total Score:";
        label2.text=totalScore;
        label.text = message;
        
        label.fontSize = 40;
        
        label.fontColor = [SKColor blackColor];
        label1.fontColor = [SKColor blackColor];
        label2.fontColor = [SKColor blackColor];

        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        label1.position = CGPointMake(label.position.x, label.position.y-28);
        label2.position = CGPointMake(label1.position.x+150, label1.position.y);


        [self addChild:label];
        [self addChild:label1];
        [self addChild:label2];
        
        // 4
        [self runAction:
         [SKAction sequence:@[
                              [SKAction waitForDuration:3.0],
                              [SKAction runBlock:^{
             // 5
             SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
             SKScene * myScene = [[MyScene alloc] initWithSize:self.size];
             [self.view presentScene:myScene transition: reveal];
         }]
                              ]]
         ];
        
    } 
    return self;
}
@end
