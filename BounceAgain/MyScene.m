//
//  MyScene.m
//  BounceAgain
//
//  Created by Arvid on 2013-12-16.
//  Copyright (c) 2013 Arvid. All rights reserved.
//

#import "MyScene.h"

static const uint32_t ballCategory              =  0x1 << 0;
static const uint32_t goalRegistrationCategory  =  0x1 << 1;

@interface MyScene () <SKPhysicsContactDelegate>

@property (nonatomic) SKSpriteNode *ball;
@property BOOL ballIsSelected;
//@property float ballOriginalX;
//@property float ballOriginalY;
@property CGPoint originalBallPosition;
@property CGPoint oldBallPosition;
@property (nonatomic) SKSpriteNode *goal;
@property (nonatomic) SKShapeNode *goalRegistrationNode;
@property (nonatomic) SKSpriteNode *ballRegistrationNode;
@property (nonatomic) SKSpriteNode *spikesNode;
@property (nonatomic) SKSpriteNode *defender;


@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
    
    
        
        
        // bakgrund och spelplan
        self.backgroundColor = [SKColor colorWithRed:255.0/255.0f green:134.0/255.0f blue:25.0/255.0f alpha:1];
        
        // målområden
        CGMutablePathRef lowerGoalAreaPath = CGPathCreateMutable();
        CGPathMoveToPoint(lowerGoalAreaPath, nil, 3.0f, 3.0f);
        CGPathAddArc(lowerGoalAreaPath, nil, self.frame.size.width / 2.0f, 3.0f, self.frame.size.width / 2.0f - 6, 0, M_PI, 0);
        
        SKShapeNode *lowerGoalAreaNode = [[SKShapeNode alloc] init];
        lowerGoalAreaNode.path = lowerGoalAreaPath;
        lowerGoalAreaNode.lineWidth = 5;
        lowerGoalAreaNode.fillColor = [UIColor colorWithRed:0.0f green:145.0 / 255.0f blue:178.0 / 255.0 alpha:1.0f];
        [self addChild:lowerGoalAreaNode];
        
        CGMutablePathRef upperGoalAreaPath = CGPathCreateMutable();
        CGPathMoveToPoint(upperGoalAreaPath, nil, 3.0f, self.frame.size.height - 3.0f);
        CGPathAddArc(upperGoalAreaPath, nil, self.frame.size.width / 2.0f, self.frame.size.height - 3.0f, self.frame.size.width / 2.0f - 6, 0, M_PI, 1);
        
        SKShapeNode *upperGoalAreaNode = [[SKShapeNode alloc] init];
        upperGoalAreaNode.path = upperGoalAreaPath;
        upperGoalAreaNode.lineWidth = 5;
        upperGoalAreaNode.fillColor = [UIColor colorWithRed:0.0f green:145.0 / 255.0f blue:178.0 / 255.0 alpha:1.0f];
        [self addChild:upperGoalAreaNode];
        
        // mittlinje
        CGMutablePathRef midlinePath = CGPathCreateMutable();
        CGPathMoveToPoint(midlinePath, nil, 0.0f, self.frame.size.height / 2.0f);
        CGPathAddLineToPoint(midlinePath, nil, self.frame.size.width, self.frame.size.height / 2.0f);
        
        SKShapeNode *midlineNode = [[SKShapeNode alloc] init];
        midlineNode.path = midlinePath;
        midlineNode.lineWidth = 5.0f;
        [self addChild:midlineNode];
        
        // sid- och baslinjer
        SKShapeNode *sidelines = [[SKShapeNode alloc] init];
        sidelines.path = CGPathCreateWithRect(self.frame, nil);
        sidelines.lineWidth = 10.0f;
        [self addChild:sidelines];
        
        
        // skapa spelyta, hela skärmen, ingen gravitation, kontaktdelegat för att registrera att bollen gått i mål
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        self.physicsWorld.contactDelegate = self;
        
//        SKPhysicsBody *borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        // borderbody skall ha ett "hål" vid mållinjen för att bollen vid höj hastighet inte ska studsa tillbaka, utan fortsätta upp utanför skärmen
        CGMutablePathRef borderPath = CGPathCreateMutable();
//        CGPathMoveToPoint(borderPath, nil, 0.0f, 0.0f);
        
        CGPoint addLines[] =
        {
            CGPointMake(0.0, 0.0),
            CGPointMake(0.0, self.frame.size.height),
            CGPointMake(self.frame.size.width / 2.0f - 75, self.frame.size.height),
            CGPointMake(self.frame.size.width / 2.0f - 75, self.frame.size.height + 200.0),
            CGPointMake(self.frame.size.width / 2.0f + 75, self.frame.size.height + 200.0),
            CGPointMake(self.frame.size.width / 2.0f + 75, self.frame.size.height),
            CGPointMake(self.frame.size.width, self.frame.size.height),
            CGPointMake(self.frame.size.width, 0.0f),
            CGPointMake(0.0f, 0.0f)
        };
        
        CGPathAddLines(borderPath, nil, addLines, 10);
        SKPhysicsBody *borderBody = [SKPhysicsBody bodyWithEdgeChainFromPath:borderPath];
        
        SKShapeNode *testNode = [[SKShapeNode alloc] init];
        testNode.path = borderPath;
//        testNode.fillColor = [UIColor redColor];
        [self addChild:testNode];
        
//         CGContextAddLines(context, addLines, sizeof(addLines)/sizeof(addLines[0]));
        
        
        self.physicsBody = borderBody;
        
        
        // friktion, ************  ska nog ändras ********************
        self.physicsBody.friction = 0.0f;
        
        // initiera en boll
        self.ball = [SKSpriteNode spriteNodeWithImageNamed:@"ballWithHolder"];
//        self.ball.position = CGPointMake(50.0f, 50.0f);
        self.ball.xScale = 0.75f;
        self.ball.yScale = self.ball.xScale;
        self.ball.alpha = 0.0f; // metoden beginRound gör bollen synlig och ger den en position
        [self.ball setName:@"Ball"];
        
        // ge bollen en physicsbody
        self.ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:23.0f];
//        self.ball.physicsBody = [SKPhysicsBody bo]
        self.ball.physicsBody.dynamic = YES;
        self.ball.physicsBody.affectedByGravity = NO;
        self.ball.physicsBody.categoryBitMask = ballCategory;
        self.ball.physicsBody.contactTestBitMask = goalRegistrationCategory;
        self.ball.physicsBody.usesPreciseCollisionDetection = YES;
        
        // nod för att detektera mål
        self.ballRegistrationNode = [SKSpriteNode spriteNodeWithImageNamed:@"newFootball"];
        self.ballRegistrationNode.alpha = 0.0f;
        self.ballRegistrationNode.xScale = 0.5f;
        self.ballRegistrationNode.yScale = self.ballRegistrationNode.xScale;
        [self.ball addChild:self.ballRegistrationNode];
        
        // bollen är ej ännu selected
        self.ballIsSelected = NO;
        
        [self addChild:_ball];
        
        

        
        // hållare för målet, skall inkludera en bild av målet, samt ett antal child nodes med physicsbodies för att simulera ett mål
        
        float alphaOfGoalNodes = 0.0f; // testing
        
//        self.frame.size.height
        SKSpriteNode *goalContainer = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0 green:0 blue:1.0f alpha:0.0f] size:CGSizeMake(150, 100)];
        goalContainer.position = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height - 30);
        [self addChild:goalContainer];
        
        // målgrafiken
        
        SKSpriteNode *goalImageSprite = [SKSpriteNode spriteNodeWithImageNamed:@"goalBW"];
        goalImageSprite.xScale = 0.65f;
        goalImageSprite.yScale = goalImageSprite.xScale;
        [goalContainer addChild:goalImageSprite];
        
        // noder för stolpar
        SKShapeNode *leftGoalPost = [[SKShapeNode alloc] init];
        leftGoalPost.path = CGPathCreateWithRoundedRect(CGRectMake(-70.0f, -25.0f, 15.0f, 50.0f), 5.0, 5.0, nil);
        leftGoalPost.fillColor = [SKColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:alphaOfGoalNodes];
        leftGoalPost.lineWidth = 0.0f;
//        leftGoalPost.position = CGPointMake(-75.0, -25.0);
        leftGoalPost.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:leftGoalPost.path];
        [goalContainer addChild:leftGoalPost];
        
        SKShapeNode *rightGoalPost = [[SKShapeNode alloc] init];
        rightGoalPost.path = CGPathCreateWithRoundedRect(CGRectMake(75.0 - 20.0f, -25.0f, 15.0f, 50.0f), 5.0, 5.0, nil);
        rightGoalPost.fillColor = [SKColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:alphaOfGoalNodes];
        rightGoalPost.lineWidth = 0.0f;
//        rightGoalPost.position = CGPointMake(75.0-30.0, -25.0);
        rightGoalPost.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:rightGoalPost.path];
        [goalContainer addChild:rightGoalPost];
        
        // node som registrerar att bollen gått i mål, är en property då den används i updatemetoden
        self.goalRegistrationNode = [[SKShapeNode alloc] init];
        self.goalRegistrationNode.path = CGPathCreateWithRect(CGRectMake(-75.0f, 15.0f, 150.0f, 200.0f), nil);
        self.goalRegistrationNode.fillColor = [SKColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:alphaOfGoalNodes];
        self.goalRegistrationNode.lineWidth = 0.0f;
//        self.goalRegistrationNode.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:self.goalRegistrationNode.path];
//        self.goalRegistrationNode.physicsBody.categoryBitMask = goalRegistrationCategory;
//        self.goalRegistrationNode.physicsBody.contactTestBitMask = ballCategory;
//        self.goalRegistrationNode.physicsBody.usesPreciseCollisionDetection = YES;
        [goalContainer addChild:self.goalRegistrationNode];
        
        
        // hinder för bollen
//        self.spikesNode = [SKSpriteNode spriteNodeWithImageNamed:@"spikesAlternative"];
//        self.spikesNode.position = CGPointMake(200, 200);
//        
//        [self addChild:self.spikesNode];
        
        // försvarare
        self.defender = [SKSpriteNode spriteNodeWithImageNamed:@"defender"];
        self.defender.xScale = 0.75f;
        self.defender.yScale = self.defender.xScale;
        self.defender.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.defender.frame.size.height / 2.0f + 7.0f];
        self.defender.position = CGPointMake(200, 200);
        self.defender.physicsBody.dynamic = NO;
        [self addChild:self.defender];
        
        
        
//        [self beginRound];
        
        
    }
    return self;
}

// metod för start av omgång
-(void)beginRound {
    NSLog(@"beginRound");
    
    // initera bollen i nedre målområdet
    
    //NSLog(@"lowergoalareaposition = %f, %f", [lower)
    
    self.ball.position = CGPointMake(50.0f, 50.0f);
    self.ball.alpha = 1.0f;
    self.ball.physicsBody.angularVelocity = 0.0f;
    self.ball.physicsBody.velocity = CGVectorMake(0.0f, 0.0f);
}





-(void)didMoveToView:(SKView *)view {
    
	// för att skjuta iväg bollen
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [[self view] addGestureRecognizer:panGestureRecognizer];
    
    // för att reseta under utveckling
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
    [[self view] addGestureRecognizer:pinchGestureRecognizer];
    
    NSLog(@"didMoveToView-metoden");
    
//    UIScreenEdgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer ]
	
	// starta spelet
    [self beginRound];
}


-(void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchLocation = [recognizer locationInView:self.view];
        
        touchLocation = [self convertPointFromView:touchLocation];
        if ([self.ball containsPoint:touchLocation]) {
            NSLog(@"Ball is touched");
            self.ballIsSelected = YES;
            self.originalBallPosition = touchLocation;
            
        }
        
    }

    else if (recognizer.state == UIGestureRecognizerStateEnded && self.ballIsSelected) {
        self.ballIsSelected = NO;
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGVector velocityVector = CGVectorMake(velocity.x * 0.05, -velocity.y * 0.05);
        [self.ball.physicsBody applyImpulse:velocityVector];
    }
}

-(void)handlePinchFrom:(UIPinchGestureRecognizer *)recognizer {
    // reseta under utveckling
    [self beginRound];
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"TouchesBegan-metoden");
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    if ([self.ball containsPoint:location]) {
        self.ballIsSelected = YES;
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    NSLog(@"Kontakt!");
    
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
    
    // 2
    if ((firstBody.categoryBitMask & goalRegistrationCategory) != 0 && (secondBody.categoryBitMask & ballCategory) != 0) {
            NSLog(@"Kontaktmål");
    }
}




-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // detektera mål
//    if ([self.ballRegistrationNode intersectsNode:self.goalRegistrationNode]) {
//        NSLog(@"Mål!");
//        self.ball.physicsBody.velocity = CGVectorMake(0.0f, 0.0f);
//        self.ball.physicsBody.angularVelocity = 0;
//    }

    if (self.ball.position.y > self.frame.size.height) {
        NSLog(@"Mål!");
        self.ball.physicsBody.velocity = CGVectorMake(0.0f, 0.0f);
        self.ball.physicsBody.angularVelocity = 0;


    }
    
    
    // hindra bollen från att få för stor rotation
//    NSLog(@"Ang vel = %f", self.ball.physicsBody.angularVelocity);
    if (self.ball.physicsBody.angularVelocity > 7.0f){
        self.ball.physicsBody.angularVelocity = 7.0f;
    } else if (self.ball.physicsBody.angularVelocity < -7.0f){
        self.ball.physicsBody.angularVelocity = -7.0f;
    }
    
    // detektera kollision med spikesnode
//    if ([self.ball intersectsNode:self.spikesNode]) {
//        self.ball.physicsBody.velocity = CGVectorMake(0.0f, 0.0f);
//        SKAction *fadeAction =[SKAction fadeOutWithDuration:0.1];
//        [self.ball runAction:fadeAction];
//    }
    
    // flytta defender
    static float xDeltaDefender = 2.0f;
    if (self.defender.position.x > self.frame.size.width * 0.9f) {
        xDeltaDefender *= -1.0f;
    } else if (self.defender.position.x < self.frame.size.width * 0.1f) {
        xDeltaDefender *= -1.0f;
    }
    
    
    self.defender.position = CGPointMake(self.defender.position.x + xDeltaDefender, self.defender.position.y);
    
}

@end
