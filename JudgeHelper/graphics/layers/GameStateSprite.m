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
#import "iAdSingleton.h"
#import "AppDelegate.h"
#import "CCDirector (Landscape).h"

@implementation GameStateSprite

-(void) swipeGameStateByUIGestureRecognizer:(UIGestureRecognizer*) sender {
    [self swipeGameState: sender.node == showGameStateMenu];
}

-(void) swipeGameStateByMenu:(id) sender {
    [self swipeGameState: sender == showGameStateMenuItem];
}

-(void) swipeGameState:(BOOL) open {
    CGPoint newPoint;
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    if(open) {
        newPoint = ccp(size.width/2, size.height/2);
    } else {
        newPoint = ccp(size.width/2*3, size.height/2);
    }
    
    CCMoveTo *move = [CCMoveTo actionWithDuration:0.25 position:newPoint];
    
    [self runAction:[CCSequence actions:move, nil]];
}

-(void) movePlayerStatusLayer: (UIPanGestureRecognizer*) sender {
    float H = self.contentSize.height-[iAdSingleton sharedInstance].getBannerHeight;
    float h = playerStatusLayer.contentSize.height;
    float m = REVERSE(40);
    
    if(h+m <= H) return;
    
    CGPoint translation = [sender translationInView:sender.view];
    translation.y *= -1;
    [sender setTranslation:CGPointZero inView:sender.view];
    CGPoint p1 = ccpAdd(playerStatusLayer.position, translation);
    
    p1.x = playerStatusLayer.position.x;
    
    if(p1.y < H-m-h) {
        p1.y = H-m-h;
    } else if(p1.y > 0) {
        p1.y = 0;
    }
    
    playerStatusLayer.position = p1;
}

-(id) init {
    if(self = [super init]) {
        CGSize globalSize = [[CCDirector sharedDirector] winSize];
        GlobalSettings* global = [GlobalSettings globalSettings];
        self.contentSize = globalSize;
        CGSize size = self.contentSize;
        size.height -= [iAdSingleton sharedInstance].getBannerHeight;
        
        engin = [CCEngin getEngin];
        
        CCLayerColor *layerColer = [CCLayerColor layerWithColor:ccc4(0,100,100,255)];
        layerColer.position = ccp(0, 0);
        layerColer.opacity = 230;
        [self addChild:layerColer z:-1];
        
        _position = ccp(globalSize.width/2*3, globalSize.height/2);
        
        //init
        playerStatusLayer = [CCLayer new];
        playerStatusLayer.contentSize = CGSizeMake(size.width, REVERSE(40)*engin.players.count-REVERSE(40));
        playerStatusLayer.position = ccp(0, size.height-playerStatusLayer.contentSize.height-REVERSE(40));
        playerStatusLayer.isTouchEnabled = YES;
        UIGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePlayerStatusLayer:)];
        [playerStatusLayer addGestureRecognizer:panGestureRecognizer];
        [self addChild:playerStatusLayer];
        
        
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
            playerLine.position = ccp(0, playerStatusLayer.contentSize.height-REVERSE(40)*i-REVERSE(20));
            [playerLines setObject:playerLine forKey:p.id];
            [playerStatusLayer addChild:playerLine];
            
            CCLabelTTF* label = [CCLabelTTF labelWithString:p.name fontName:@"Marker Felt" fontSize:VALUE(14, 10)];
            label.position = REVERSE_XY(60, 0);
            [playerLine addChild:label];
            
            i++;
        }

        
        CCMenuItem* undoMenuItem = [CCMenuItemImage itemWithNormalImage:@"undo.png" selectedImage:@"undo-sel.png" target:self selector:@selector(undoButtonPressed:)];
        [undoMenuItem setScaleX: REVERSE(60)/undoMenuItem.contentSize.width];
        [undoMenuItem setScaleY: REVERSE(60)/undoMenuItem.contentSize.height];
        CCMenu *undoMenu = [CCMenu menuWithItems:undoMenuItem, nil];
        undoMenu.contentSize = undoMenuItem.contentSize;
        undoMenu.position = ccp(size.width - REVERSE_X(250), size.height-REVERSE_Y(50));
        [self addChild: undoMenu];
        
        CCMenuItem* redoMenuItem = [CCMenuItemImage itemWithNormalImage:@"redo.png" selectedImage:@"redo-sel.png" target:self selector:@selector(redoButtonPressed:)];
        [redoMenuItem setScaleX: REVERSE(60)/redoMenuItem.contentSize.width];
        [redoMenuItem setScaleY: REVERSE(60)/redoMenuItem.contentSize.height];
        CCMenu *redoMenu = [CCMenu menuWithItems:redoMenuItem, nil];
        redoMenu.contentSize = redoMenuItem.contentSize;
        redoMenu.position = ccp(size.width - REVERSE_X(150), size.height-REVERSE_Y(50));
        [self addChild: redoMenu];
        
        CCMenuItem* quitMenuItem = [CCMenuItemImage itemWithNormalImage:@"quit.png" selectedImage:@"quit-sel.png" target:self selector:@selector(quitButtonPressed:)];
        [quitMenuItem setScaleX: REVERSE(60)/quitMenuItem.contentSize.width];
        [quitMenuItem setScaleY: REVERSE(60)/quitMenuItem.contentSize.height];
        CCMenu *quitMenu = [CCMenu menuWithItems:quitMenuItem, nil];
        quitMenu.contentSize = quitMenuItem.contentSize;
        quitMenu.position = ccp(size.width - REVERSE_X(50), size.height-REVERSE_Y(50));
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
        
        showGameStateMenuItem = [CCMenuItemImage itemWithNormalImage:@"left2.png" selectedImage:@"left2-sel.png" target:self selector:@selector(swipeGameStateByMenu:)];
        [showGameStateMenuItem setScaleX: REVERSE(30)/showGameStateMenuItem.contentSize.width];
        [showGameStateMenuItem setScaleY: REVERSE(40)/showGameStateMenuItem.contentSize.height];
        showGameStateMenu = [CCMenu menuWithItems:showGameStateMenuItem, nil];
        showGameStateMenu.contentSize = showGameStateMenuItem.contentSize;
        showGameStateMenu.position = ccp(-showGameStateMenuItem.boundingBox.size.width/2, size.height/2);
        [self addChild: showGameStateMenu];

        
        hideGameStateMenuItem = [CCMenuItemImage itemWithNormalImage:@"right2.png" selectedImage:@"right2-sel.png" target:self selector:@selector(swipeGameStateByMenu:)];
        [hideGameStateMenuItem setScaleX: REVERSE(30)/hideGameStateMenuItem.contentSize.width];
        [hideGameStateMenuItem setScaleY: REVERSE(40)/hideGameStateMenuItem.contentSize.height];
        hideGameStateMenu = [CCMenu menuWithItems:hideGameStateMenuItem, nil];
        hideGameStateMenu.contentSize = hideGameStateMenuItem.contentSize;
        hideGameStateMenu.position = ccp(size.width-hideGameStateMenuItem.boundingBox.size.width/2, size.height/2);
        [self addChild: hideGameStateMenu];
        
        /*
        showGameState = [CCSprite spriteWithFile:@"left2.png"];
        [showGameState setScaleX: REVERSE(30)/showGameState.contentSize.width];
        [showGameState setScaleY: REVERSE(40)/showGameState.contentSize.height];
        showGameState.isTouchEnabled = YES;
        showGameState.position = ccp(-showGameState.boundingBox.size.width/2, size.height/2);
        UIGestureRecognizer *showGameStateTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGameState:)];
        [showGameState addGestureRecognizer:showGameStateTapGestureRecognizer];
        UISwipeGestureRecognizer* showGameStateSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGameState:)];
        showGameStateSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [showGameState addGestureRecognizer: showGameStateSwipeGestureRecognizer];
        [self addChild: showGameState];
        
        hideGameState = [CCSprite spriteWithFile:@"right2.png"];
        [hideGameState setScaleX: REVERSE(30)/hideGameState.contentSize.width];
        [hideGameState setScaleY: REVERSE(40)/hideGameState.contentSize.height];
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

- (BOOL) isTouchInsideOpenMenuWithTouch:(UITouch*)touch {
    return ![showGameStateMenu isPointInArea: [touch locationInView: [touch view]]];
}
 
-(void) undoButtonPressed : (id) sender {
    [engin action: @"UNDO_ACTION"];
}

-(void) redoButtonPressed : (id) sender {
    [engin action: @"REDO_ACTION"];
}

-(void) quitButtonPressed : (id) sender {
    [((AppController*)[[UIApplication sharedApplication] delegate]).navigationController popToRootViewControllerAnimated:YES];
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[SelectPlayerLayer scene] ]];
}

-(void) addNewStatusWithActorRole: (Role) role andReceiver: (Player*) receiver andResult: (BOOL) result {
    for(NSMutableArray* visibleObjects in [playerVisibleObjects allValues]) {
        [visibleObjects addObject:[NSMutableArray new]];
    }
   
    int iconSize = 30;
    int marginLeft = 130;
    int lifeBoxHeight = 6;
    
    if(receiver) {
        CCSprite* playerLine = [playerLines objectForKey:receiver.id];
        NSMutableArray* visibleNodes  = [[playerVisibleObjects objectForKey:receiver.id] lastObject];
        NSMutableArray* lifeBoxes = [playerLifeBoxes objectForKey:receiver.id];
        
        MySprite* icon = [MySprite spriteWithFile: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:role]]];
        [icon setScaleX: REVERSE(iconSize)/icon.contentSize.width];
        [icon setScaleY: REVERSE(iconSize)/icon.contentSize.height];
        if(!result) icon.opacity = 80;
        icon.position = ccp(REVERSE(marginLeft+iconSize*lifeBoxes.count), 0);
        [visibleNodes addObject:icon];
        [playerLine addChild:icon];
        
        ccColor4B color = (receiver.life >= 1) ? ccc4(0, 255, 0, 255) : (receiver.life <= 0) ? ccc4(255, 0, 0, 255) : ccc4(100, 100, 0, 255);
        CCLayerColor *lifeBox = [CCLayerColor layerWithColor:color];
        lifeBox.contentSize = CGSizeMake(REVERSE(iconSize), REVERSE(lifeBoxHeight));
        lifeBox.position = ccp(REVERSE(marginLeft+iconSize*lifeBoxes.count-iconSize/2), REVERSE(-iconSize/2-lifeBoxHeight));
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
                    lifeBox.contentSize = CGSizeMake(REVERSE(iconSize), REVERSE(lifeBoxHeight));
                    lifeBox.position = ccp(REVERSE(marginLeft+iconSize*lifeBoxes.count-iconSize/2), REVERSE(-iconSize/2-lifeBoxHeight));
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
                separatorBox.contentSize = CGSizeMake(1, REVERSE(40));
                separatorBox.position = ccp(REVERSE(marginLeft+iconSize*maxCount-iconSize/2), REVERSE(-iconSize));
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
