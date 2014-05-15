//
//  MyScene.m
//  RunningFlight
//
//  Created by fox on 14-5-12.
//  Copyright (c) 2014年 fox. All rights reserved.
//

#import "MyScene.h"
#import "GameOverScene.h"
static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;
static const uint32_t flightCategory         =  0x1 << 2;
static NSString *s;
static int count=0;

@interface MyScene()<SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode *flight;
@property (nonatomic) SKLabelNode *score;
@property (nonatomic) SKLabelNode *point;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval projectileUpdateTimeInterval;
@end

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

static float calculateDistant(CGPoint a, CGPoint b){
    return sqrtf((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y));
}
const float projectileSpeed=8.0;
const float flightMoveSpeed=92.0;
@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        count=0;
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
        
        self.flight=[SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        self.flight.size=CGSizeMake(25.0, 25.0);
        self.flight.position = CGPointMake(100, self.frame.size.height/2);
        self.flight.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:self.flight.size];
        self.flight.physicsBody.dynamic=YES;
        self.flight.physicsBody.categoryBitMask=flightCategory;
        self.flight.physicsBody.contactTestBitMask=monsterCategory;
        self.flight.physicsBody.collisionBitMask=0;
        
        self.score=[SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        self.score.text=@"SCORE : ";
        self.score.fontSize=15;
        self.score.position=CGPointMake(400,290);

        self.point=[SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        self.point.position=CGPointMake(450,290);
        self.point.text=@"0";
        self.point.fontSize=15;
        [self addChild:self.score];
        [self addChild:self.flight];
        [self addChild:self.point];
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}


- (void)addMonster {
    
    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size]; // 1
    monster.physicsBody.dynamic = YES; // 2
    monster.physicsBody.categoryBitMask = monsterCategory; // 3
    monster.physicsBody.contactTestBitMask = projectileCategory; // 4
    monster.physicsBody.collisionBitMask = 0; // 5
    // Determine where to spawn the monster along the Y axis
    int minY = monster.size.height / 2;
    int maxY = self.frame.size.height - monster.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);
    monster.size=CGSizeMake(20.0, 20.0);
    [self addChild:monster];
    
    // Determine speed of the monster
    int minDuration = 5.0;
    int maxDuration = 10.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

- (void)addProjectile:(CGPoint) location {
    
    // Create sprite
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;

    projectile.position = location;
    projectile.size=CGSizeMake(5.0, 5.0);
    [self addChild:projectile];
    
    int actualDuration = 1.0;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(self.frame.size.width+20.0, location.y) duration:actualDuration];
    //SKAction * wait=[SKAction waitForDuration:0.1];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove,actionMoveDone]]];
    
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster {
    count+=1;
    s=[NSString stringWithFormat:@"%d",count];
    self.point.text=s;
    [projectile removeFromParent];
    [monster removeFromParent];
}

- (void)flight:(SKSpriteNode *)flight didCollideWithMonster:(SKSpriteNode *)monster {
    //count+=1;
    //NSString *s=[NSString stringWithFormat:@"%d",count];
    //self.point.text=s;
    SKAction * loseAction = [SKAction runBlock:^{
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size score:count];
        [self.view presentScene:gameOverScene transition: reveal];
    }];
    s=@"0";
    [monster runAction:loseAction];
    //count=0;
    //[self.flight removeFromParent];
    //[monster removeFromParent];
}


- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKPhysicsBody *firstBody, *secondBody;
    
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
    
    // contact between projectile and monster
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
    
    //contact between flight and monster
    if ((firstBody.categoryBitMask & monsterCategory) != 0 &&
        (secondBody.categoryBitMask & flightCategory) != 0)
    {
        [self flight:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    self.projectileUpdateTimeInterval +=timeSinceLast;
    if (self.projectileUpdateTimeInterval>0.1){
        self.projectileUpdateTimeInterval=0.0;
        [self addProjectile:self.flight.position];
    }
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
        //[self addProjectile:self.flight.position];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        //SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        //sprite.position = location;
        float moveDuration=calculateDistant(self.flight.position, location)/flightMoveSpeed;
        SKAction *action = [SKAction moveTo:location duration:moveDuration];
        
        [self.flight runAction:action];
        
        //[self addChild:sprite];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}
@end
