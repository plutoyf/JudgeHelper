//
//  GameStateSprite.m
//  JudgeHelper
//
//  Created by fyang on 8/2/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "GameStateSprite.h"
#import "CCEngin.h"
#import "CCPlayer.h"
#import "CCNode+SFGestureRecognizers.h"

@implementation GameStateSprite

- (void)swipeGameState:(UIGestureRecognizer*) sender {
    CGPoint newPoint;
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    if(sender.node == showGameState) {
        newPoint = ccp(self.boundingBox.size.width/2, self.boundingBox.size.height/2);
    } else if(sender.node == hideGameState) {
        newPoint = ccp(size.width+self.boundingBox.size.width/2, self.boundingBox.size.height/2);
    }
    
    CCMoveTo *move = [CCMoveTo actionWithDuration:0.25 position:newPoint];
    
    [self runAction:[CCSequence actions:move, nil]];
}


CCSprite* showGameState;
CCSprite* hideGameState;
-(id) init {
    if(self = [super init]) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        self.contentSize = size;
        
        engin = [CCEngin getEngin];
        
        CCLayerColor *layerColer = [CCLayerColor layerWithColor:ccc4(0,100,100,255)];
        layerColer.position = ccp(0, 0);
        layerColer.opacity = 230;
        [self addChild:layerColer z:-1];        
        
        _position = ccp(size.width/2*3, size.height/2);
        
        //init
        pIds = [NSMutableArray new];
        playerLines = [NSMutableDictionary new];
        playerVisibleObjects = [NSMutableDictionary new];
        playerLifeBoxes = [NSMutableDictionary new];
        int i = 0;
        for(CCPlayer* p in engin.players) {
            if(p.role == Judge) continue;
            [pIds addObject:p.id];
            [playerVisibleObjects setObject:[NSMutableArray new] forKey:p.id];
            [playerLifeBoxes setObject:[NSMutableArray new] forKey:p.id];
            
            CCSprite* playerLine = [CCSprite new];
            playerLine.position = ccp(0, 80+40*i);
            playerLine.cascadeOpacityEnabled=YES;
            [playerLines setObject:playerLine forKey:p.id];
            [self addChild:playerLine];
            
            CCLabelTTF* label = [CCLabelTTF labelWithString:p.name fontName:@"Marker Felt" fontSize:14];
            label.position = ccp(50, 0);
            [playerLine addChild:label];
            
            i++;
        }
        
        CCSprite* undoButton = [CCSprite spriteWithFile:@"undo.png"];
        undoButton.position = ccp(60, size.height-undoButton.boundingBox.size.width/2);
        undoButton.isTouchEnabled = YES;
        [undoButton addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(undoButtonPressed:)] ];
        [self addChild:undoButton];
        
        CCSprite* redoButton = [CCSprite spriteWithFile:@"redo.png"];
        redoButton.position = ccp(60+undoButton.boundingBox.size.width/2+redoButton.boundingBox.size.width/2+40, size.height-redoButton.boundingBox.size.width/2);
        redoButton.isTouchEnabled = YES;
        [redoButton addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(redoButtonPressed:)] ];
        [self addChild:redoButton];
        
        showGameState = [CCSprite spriteWithFile:@"left2.png"];
        showGameState.isTouchEnabled = YES;
        showGameState.position = ccp(-showGameState.boundingBox.size.width/2, size.height/2);
        UIGestureRecognizer *showGameStateTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGameState:)];
        [showGameState addGestureRecognizer:showGameStateTapGestureRecognizer];
        [self addChild: showGameState];
        
        hideGameState = [CCSprite spriteWithFile:@"right2.png"];
        hideGameState.isTouchEnabled = YES;
        hideGameState.position = ccp(size.width-showGameState.boundingBox.size.width/2, size.height/2);
        UIGestureRecognizer *hideGameStateTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGameState:)];
        [hideGameState addGestureRecognizer:hideGameStateTapGestureRecognizer];
        [self addChild: hideGameState];
    }
    
    return self;
}


-(void) undoButtonPressed : (id) sender {
    [engin action: @"UNDO_ACTION"];
}

-(void) redoButtonPressed : (id) sender {
    [engin action: @"REDO_ACTION"];
}

NSMutableDictionary* playerLines;
NSMutableDictionary* playerVisibleObjects;
NSMutableDictionary* playerLifeBoxes;
NSMutableArray* pIds;
-(void) addNewStatusWithActorRole: (Role) role andReceiver: (Player*) receiver andResult: (BOOL) result {
    for(NSMutableArray* visibleObjects in [playerVisibleObjects allValues]) {
        [visibleObjects addObject:[NSMutableArray new]];
    }
    
    if(receiver) {
        CCSprite* playerLine = [playerLines objectForKey:receiver.id];
        NSMutableArray* visibleNodes  = [[playerVisibleObjects objectForKey:receiver.id] lastObject];
        NSMutableArray* lifeBoxes = [playerLifeBoxes objectForKey:receiver.id];
        
        MySprite* icon = [MySprite spriteWithFile: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:role]]];
        if(!result) icon.opacity = 80;
        icon.position = ccp(100+20*lifeBoxes.count, 0);
        [visibleNodes addObject:icon];
        [playerLine addChild:icon];
        
        ccColor4B color = (receiver.life >= 1) ? ccc4(0, 255, 0, 255) : (receiver.life <= 0) ? ccc4(255, 0, 0, 255) : ccc4(100, 100, 0, 255);
        CCLayerColor *lifeBox = [CCLayerColor layerWithColor:color];
        lifeBox.contentSize = CGSizeMake(20, 4);
        lifeBox.position = ccp(100+20*lifeBoxes.count-10, -14);
        [visibleNodes addObject:lifeBox];
        [lifeBoxes addObject:lifeBox];
        [playerLine addChild:lifeBox];
    }
    
    if(!receiver || role == Judge) {
        int maxLifeBoxesNumber = 0;
        for(NSString* id in pIds) {
            NSMutableArray* lifeBoxes = [playerLifeBoxes objectForKey:id];
            maxLifeBoxesNumber = (lifeBoxes.count > maxLifeBoxesNumber) ? lifeBoxes.count : maxLifeBoxesNumber;
        }
        for(NSString* id in pIds) {
            CCSprite* playerLine = [playerLines objectForKey:id];
            NSMutableArray* visibleNodes  = [[playerVisibleObjects objectForKey:id] lastObject];
            Player* player = [engin getPlayerById:id];
            NSMutableArray* lifeBoxes = [playerLifeBoxes objectForKey:id];
            ccColor3B color = lifeBoxes.count > 0 ? ((CCLayerColor*)[lifeBoxes lastObject]).color : ccc3(0, 255, 0);
            
            if(player.status == IN_GAME) {
                for(;lifeBoxes.count < maxLifeBoxesNumber;) {
                    CCLayerColor *lifeBox = [CCLayerColor layerWithColor:ccc4(color.r, color.g, color.b, 255)];
                    lifeBox.contentSize = CGSizeMake(20, 4);
                    lifeBox.position = ccp(100+20*lifeBoxes.count-10, -14);
                    [visibleNodes addObject:lifeBox];
                    [lifeBoxes addObject:lifeBox];
                    [playerLine addChild:lifeBox];
                }
            }
            
            int opacity = (player.status == IN_GAME) ? 255 : 80;
            playerLine.opacity = opacity;
            for(CCLayerColor* lifeBox in lifeBoxes) lifeBox.opacity = opacity;
        }
    }
    
}

-(void) revertStatus {
    for(NSString* id in pIds) {
        CCSprite* playerLine = [playerLines objectForKey:id];
        NSMutableArray* visibleNodes  = [[playerVisibleObjects objectForKey:id] lastObject];
        NSMutableArray* lifeBoxes = [playerLifeBoxes objectForKey:id];
        Player* player = [engin getPlayerById:id];
        
        for(CCNode* node in visibleNodes) {
            if([lifeBoxes containsObject:node]) {
                [lifeBoxes removeObject:node];
            }
        }
        [lifeBoxes removeObjectsInArray:visibleNodes];
        
        for(CCNode* node in visibleNodes) {
            [playerLine removeChild:node];
        }
        
        [[playerVisibleObjects objectForKey:id] removeLastObject];
        
        int opacity = (player.status == IN_GAME) ? 255 : 80;
        playerLine.opacity = opacity;
        for(CCLayerColor* lifeBox in lifeBoxes) lifeBox.opacity = opacity;
    }
}
@end
