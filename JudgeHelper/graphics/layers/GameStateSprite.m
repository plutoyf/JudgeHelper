//
//  GameStateSprite.m
//  JudgeHelper
//
//  Created by fyang on 8/2/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "GameStateSprite.h"
#import "GlobalSettings.h"
#import "CCNode+SFGestureRecognizers.h"
#import "SelectPlayerLayer.h"

@implementation GameStateSprite

-(void) swipeGameStateByUIGestureRecognizer:(UIGestureRecognizer*) sender {
    [self swipeGameState: sender.node == showGameStateMenuItem];
}

-(void) swipeGameStateByMenu:(id) sender {
    [self swipeGameState: sender == showGameStateMenuItem];
}

-(void) swipeGameState:(BOOL) open {
    CGPoint newPoint;
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    if(open) {
        newPoint = ccp(self.boundingBox.size.width/2, self.boundingBox.size.height/2);
    } else {
        newPoint = ccp(size.width+self.boundingBox.size.width/2, self.boundingBox.size.height/2);
    }
    
    CCMoveTo *move = [CCMoveTo actionWithDuration:0.25 position:newPoint];
    
    [self runAction:[CCSequence actions:move, nil]];
}


-(id) init {
    if(self = [super init]) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        GlobalSettings* global = [GlobalSettings globalSettings];
        
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
            playerLine.position = REVERSE_XY(0, 80+40*i);
            [playerLines setObject:playerLine forKey:p.id];
            [self addChild:playerLine];
            
            CCLabelTTF* label = [CCLabelTTF labelWithString:p.name fontName:@"Marker Felt" fontSize:REVERSE_X(14)];
            label.position = REVERSE_XY(50, 0);
            [playerLine addChild:label];
            
            i++;
        }
        
        CCMenuItem* undoMenuItem = [CCMenuItemImage itemFromNormalImage:@"undo.png" selectedImage:@"undo-sel.png" target:self selector:@selector(undoButtonPressed:)];
        [undoMenuItem setScaleX: IMG_WIDTH/undoMenuItem.contentSize.width];
        [undoMenuItem setScaleY: IMG_HEIGHT/undoMenuItem.contentSize.height];
        CCMenu *undoMenu = [CCMenu menuWithItems:undoMenuItem, nil];
        undoMenu.position = ccp(REVERSE_X(60), size.height-REVERSE_Y(40));
        [self addChild: undoMenu];
        
        CCMenuItem* redoMenuItem = [CCMenuItemImage itemFromNormalImage:@"redo.png" selectedImage:@"redo-sel.png" target:self selector:@selector(redoButtonPressed:)];
        [redoMenuItem setScaleX: IMG_WIDTH/redoMenuItem.contentSize.width];
        [redoMenuItem setScaleY: IMG_HEIGHT/redoMenuItem.contentSize.height];
        CCMenu *redoMenu = [CCMenu menuWithItems:redoMenuItem, nil];
        redoMenu.position = ccp(REVERSE_X(160), size.height-REVERSE_Y(40));
        [self addChild: redoMenu];
        
        CCMenuItem* quitMenuItem = [CCMenuItemImage itemFromNormalImage:@"quit.png" selectedImage:@"quit-sel.png" target:self selector:@selector(quitButtonPressed:)];
        [quitMenuItem setScaleX: IMG_WIDTH/quitMenuItem.contentSize.width];
        [quitMenuItem setScaleY: IMG_HEIGHT/quitMenuItem.contentSize.height];
        CCMenu *quitMenu = [CCMenu menuWithItems:quitMenuItem, nil];
        quitMenu.position = ccp(REVERSE_X(260), size.height-REVERSE_Y(40));
        [self addChild: quitMenu];
        
        /*
        CCLabelTTF* realPositionHandModeTitle = [CCLabelTTF labelWithString:@"相对位置显示" fontName:@"Marker Felt" fontSize:REVERSE_X(28)];
        realPositionHandModeTitle.position = ccp(redoButton.position.x+redoButton.boundingBox.size.width+REVERSE_X(80), size.height-redoButton.boundingBox.size.width/2);
        [self addChild: realPositionHandModeTitle];
        
        realPositionHandModeOffItem = [CCMenuItemImage itemFromNormalImage:@"btn_off2_red-40.png" selectedImage:@"btn_off2_red-40.png" target:nil selector:nil];
        realPositionHandModeOnItem = [CCMenuItemImage itemFromNormalImage:@"btn_on2_green-40.png" selectedImage:@"btn_on2_green-40.png" target:nil selector:nil];
        CCMenuItemToggle *toggleItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(realPositionHandModeButtonTapped:) items:([global isRealPositionHandModeEnable]?realPositionHandModeOnItem:realPositionHandModeOffItem), ([global isRealPositionHandModeEnable]?realPositionHandModeOffItem:realPositionHandModeOnItem), nil];
        CCMenu *toggleMenu = [CCMenu menuWithItems:toggleItem, nil];
        toggleMenu.position = ccp(realPositionHandModeTitle.position.x+realPositionHandModeTitle.boundingBox.size.width/2+40, size.height-redoButton.boundingBox.size.width/2);

        [self addChild:toggleMenu];
        
        realPositionHandModeLabel = [CCLabelTTF labelWithString:[global isRealPositionHandModeEnable]?@"(开启)":@"(关闭)" fontName:@"Marker Felt" fontSize:REVERSE_X(28)];
        realPositionHandModeLabel.position = ccp(toggleMenu.position.x+REVERSE_X(80), size.height-redoButton.boundingBox.size.width/2);
        [self addChild: realPositionHandModeLabel];
         */
        
        showGameStateMenuItem = [CCMenuItemImage itemFromNormalImage:@"left2.png" selectedImage:@"left2-sel.png" target:self selector:@selector(swipeGameStateByMenu:)];
        [showGameStateMenuItem setScaleX: REVERSE_X(30)/showGameStateMenuItem.contentSize.width];
        [showGameStateMenuItem setScaleY: REVERSE_X(40)/showGameStateMenuItem.contentSize.height];
        CCMenu* showGameStateMenu = [CCMenu menuWithItems:showGameStateMenuItem, nil];
        showGameStateMenu.position = ccp(-showGameStateMenuItem.boundingBox.size.width/2, size.height/2);
        [self addChild: showGameStateMenu];
        
        hideGameStateMenuItem = [CCMenuItemImage itemFromNormalImage:@"right2.png" selectedImage:@"right2-sel.png" target:self selector:@selector(swipeGameStateByMenu:)];
        [hideGameStateMenuItem setScaleX: REVERSE_X(30)/hideGameStateMenuItem.contentSize.width];
        [hideGameStateMenuItem setScaleY: REVERSE_X(40)/hideGameStateMenuItem.contentSize.height];
        CCMenu* hideGameStateMenu = [CCMenu menuWithItems:hideGameStateMenuItem, nil];
        hideGameStateMenu.position = ccp(size.width-hideGameStateMenuItem.boundingBox.size.width/2, size.height/2);
        [self addChild: hideGameStateMenu];
        
        /*
        showGameState = [CCSprite spriteWithFile:@"left2.png"];
        [showGameState setScaleX: REVERSE_X(30)/showGameState.contentSize.width];
        [showGameState setScaleY: REVERSE_X(40)/showGameState.contentSize.height];
        showGameState.isTouchEnabled = YES;
        showGameState.position = ccp(-showGameState.boundingBox.size.width/2, size.height/2);
        UIGestureRecognizer *showGameStateTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGameState:)];
        [showGameState addGestureRecognizer:showGameStateTapGestureRecognizer];
        UISwipeGestureRecognizer* showGameStateSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGameState:)];
        showGameStateSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [showGameState addGestureRecognizer: showGameStateSwipeGestureRecognizer];
        [self addChild: showGameState];
        
        hideGameState = [CCSprite spriteWithFile:@"right2.png"];
        [hideGameState setScaleX: REVERSE_X(30)/hideGameState.contentSize.width];
        [hideGameState setScaleY: REVERSE_X(40)/hideGameState.contentSize.height];
        hideGameState.isTouchEnabled = YES;
        hideGameState.position = ccp(size.width-showGameState.boundingBox.size.width/2, size.height/2);
        UIGestureRecognizer *hideGameStateTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGameState:)];
        [hideGameState addGestureRecognizer:hideGameStateTapGestureRecognizer];
        [self addChild: hideGameState];
         */
        
        self.isTouchEnabled = YES;
        UISwipeGestureRecognizer* hideGameStateSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGameStateByUIGestureRecognizer:)];
        hideGameStateSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer: hideGameStateSwipeGestureRecognizer];
    }
    
    return self;
}

/*
-(void) realPositionHandModeButtonTapped : (id) sender {
    GlobalSettings *globals = [GlobalSettings globalSettings];
    CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
    if (toggleItem.selectedItem == realPositionHandModeOffItem) {
        [globals setRealPositionHandMode:NO];
        realPositionHandModeLabel.string = @"(关闭)";
    } else if (toggleItem.selectedItem == realPositionHandModeOnItem) {
        [globals setRealPositionHandMode:YES];
        realPositionHandModeLabel.string = @"(开启)";
    }
    
    for(CCPlayer* p in engin.players) {
        p.realPositionModeEnable = [globals isRealPositionHandModeEnable];
    }
}
*/
 
-(void) undoButtonPressed : (id) sender {
    [engin action: @"UNDO_ACTION"];
}

-(void) redoButtonPressed : (id) sender {
    [engin action: @"REDO_ACTION"];
}

-(void) quitButtonPressed : (id) sender {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[SelectPlayerLayer scene] ]];
}

-(void) addNewStatusWithActorRole: (Role) role andReceiver: (Player*) receiver andResult: (BOOL) result {
    for(NSMutableArray* visibleObjects in [playerVisibleObjects allValues]) {
        [visibleObjects addObject:[NSMutableArray new]];
    }
    
    if(receiver) {
        CCSprite* playerLine = [playerLines objectForKey:receiver.id];
        NSMutableArray* visibleNodes  = [[playerVisibleObjects objectForKey:receiver.id] lastObject];
        NSMutableArray* lifeBoxes = [playerLifeBoxes objectForKey:receiver.id];
        
        MySprite* icon = [MySprite spriteWithFile: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:role]]];
        [icon setScaleX: REVERSE_X(20)/icon.contentSize.width];
        [icon setScaleY: REVERSE_X(20)/icon.contentSize.height];
        if(!result) icon.opacity = 80;
        icon.position = REVERSE_XY(100+20*lifeBoxes.count, 0);
        [visibleNodes addObject:icon];
        [playerLine addChild:icon];
        
        ccColor4B color = (receiver.life >= 1) ? ccc4(0, 255, 0, 255) : (receiver.life <= 0) ? ccc4(255, 0, 0, 255) : ccc4(100, 100, 0, 255);
        CCLayerColor *lifeBox = [CCLayerColor layerWithColor:color];
        lifeBox.contentSize = CGSizeMake(REVERSE_X(20), REVERSE_Y(4));
        lifeBox.position = REVERSE_XY(100+20*lifeBoxes.count-10, -14);
        int opacity = (receiver.status == IN_GAME) ? 255 : 80;
        lifeBox.opacity = opacity;
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
        int maxCount = 0;
        for(NSString* id in pIds) {
            CCSprite* playerLine = [playerLines objectForKey:id];
            NSMutableArray* visibleNodes  = [[playerVisibleObjects objectForKey:id] lastObject];
            Player* player = [engin getPlayerById:id];
            NSMutableArray* lifeBoxes = [playerLifeBoxes objectForKey:id];
            maxCount = maxCount < lifeBoxes.count ? lifeBoxes.count : maxCount;
            ccColor3B color = lifeBoxes.count > 0 ? ((CCLayerColor*)[lifeBoxes lastObject]).color : ccc3(0, 255, 0);
            
            if(player.status == IN_GAME) {
                for(;lifeBoxes.count < maxLifeBoxesNumber;) {
                    CCLayerColor *lifeBox = [CCLayerColor layerWithColor:ccc4(color.r, color.g, color.b, 255)];
                    lifeBox.contentSize = CGSizeMake(REVERSE_X(20), REVERSE_Y(4));
                    lifeBox.position = REVERSE_XY(100+20*lifeBoxes.count-10, -14);
                    [visibleNodes addObject:lifeBox];
                    [lifeBoxes addObject:lifeBox];
                    [playerLine addChild:lifeBox];
                }
            }
            
            int opacity = (player.status == IN_GAME) ? 255 : 80;
            for(CCLayerColor* lifeBox in lifeBoxes) lifeBox.opacity = opacity;
        }
        
        if(role == Judge) {
            for(NSString* id in pIds) {
                CCSprite* playerLine = [playerLines objectForKey:id];
                CCLayerColor *separatorBox = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
                separatorBox.contentSize = CGSizeMake(1, REVERSE_Y(40));
                separatorBox.position = REVERSE_XY(100+20*maxCount-10, -20);
                [playerLine addChild:separatorBox z:1];
            }
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
        for(CCLayerColor* lifeBox in lifeBoxes) lifeBox.opacity = opacity;
    }
}
@end
