//
//  MainMenuViewController.m
//  JudgeHelper
//
//  Created by fyang on 14/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "MainMenuViewController.h"
#import "GameLayer.h"
#import "AppDelegate.h"
#import "GlobalSettings.h"
#import "PlayerTableViewCell.h"
#import "PlayerCollectionViewCell.h"
#import "RoleCollectionViewCell.h"
#import "PlayerCreationView.h"
#import "CCEngin.h"
#import "Role.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

// Add new method
- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ((AppController*)[[UIApplication sharedApplication] delegate]).navigationController = self.navigationController;
    
    selectedPIds = [NSMutableArray new];
    [self initPlayerIds];
    
    [self initRoles];
    [self selectRole:Judge];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.leftBodyView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.4f constant:0.f]];
    
    [self.playerCollectionView registerNib:[UINib nibWithNibName:@"PlayerCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"playerCollectionViewCell"];
    [self.roleCollectionView registerNib:[UINib nibWithNibName:@"RoleCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"roleCollectionViewCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Replace this method
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)nextButtonTapped:(id)sender {
    GlobalSettings* global = [GlobalSettings globalSettings];
    [global setPlayerIds: selectedPIds];

    BOOL isReadyToStart = NO;
    switch (self.view.tag) {
        case 0:
            isReadyToStart = [self isRedyToStart];
            self.view.tag = isReadyToStart ? 2 : 1;
            [self matchPlayerNumber];
            [self animateViewWithLeftPart:!isReadyToStart andRightPart:YES];
            break;
        case 1:
            self.view.tag = 2;
            [self matchPlayerNumber];
            [self animateViewWithLeftPart:YES andRightPart:NO];
            break;
        case 2:
            if ([self isRedyToStart]) {
                CCDirector *director = [CCDirector sharedDirector];
                if(director.runningScene != nil) {
                    [director replaceScene:[GameLayer scene]];
                }
                [self.navigationController pushViewController:director animated:YES];

            }
        default:
            break;
    }
}

- (IBAction)createPlayerButtonTapped:(id)sender {
    // Declaring the popover layer
    PlayerCreationView *playerCreationView = [[[NSBundle mainBundle] loadNibNamed:@"PlayerCreationView" owner:self options:nil] objectAtIndex:0];
    playerCreationView.frame = CGRectMake(0, -70, playerCreationView.bounds.size.width, playerCreationView.bounds.size.height);
    [self.view insertSubview:playerCreationView aboveSubview:self.bodyView];
    
    //playerCreationView.layer.borderWidth = 1.0f;
    //playerCreationView.layer.borderColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f] CGColor];
    playerCreationView.playerImage.layer.borderWidth = 1.0f;
    playerCreationView.playerImage.layer.borderColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f] CGColor];
    
    playerCreationView.playerImage.layer.cornerRadius = 0.6f;
    playerCreationView.playerImage.clipsToBounds = YES;
    
    playerCreationView.shieldView = [[UIView alloc] initWithFrame:self.view.bounds];
    playerCreationView.shieldView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    [self.view insertSubview:playerCreationView.shieldView belowSubview:playerCreationView];
    
    [UIView animateWithDuration:.5 animations:^(void) {
        [playerCreationView setFrame:CGRectOffset([playerCreationView frame], 0, playerCreationView.bounds.size.height)];
    } completion:^(BOOL Finished) {
    }];
}

- (void) animateViewWithLeftPart:(BOOL) animateLeftPartView andRightPart:(BOOL) animateRightPartView {
    NSLayoutConstraint *leftPartConstraint, *rightPartConstraint;
    float newLeftPartSpaceValue, newRightPartSpaceValue;
    UIView *leftPartView, *rightPartView;
    
    if (animateLeftPartView) {
        leftPartView = self.leftPlayerView.tag == 1 ? self.leftPlayerView : self.leftRoleView;
        leftPartConstraint = self.leftPlayerView.tag == 1 ? self.leftPlayerViewSpace : self.leftRoleViewSpace;
        newLeftPartSpaceValue = self.leftPlayerView.tag == 1 ? -leftPartView.bounds.size.width : 0;
        leftPartView.tag = 0;
    }
    
    if (animateRightPartView) {
        rightPartView = self.rightPlayerView.tag == 1 ? self.rightPlayerView : self.rightRoleView;
        rightPartConstraint = self.rightPlayerView.tag == 1 ? self.rightPlayerViewSpace : self.rightRoleViewSpace;
        newRightPartSpaceValue = self.rightPlayerView.tag == 1 ? -rightPartView.bounds.size.width : 0;
        rightPartView.tag = 0;
    }
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:0.5 animations:^{
        if (animateLeftPartView) {
            leftPartConstraint.constant = newLeftPartSpaceValue;
            [self.view layoutIfNeeded];
        }
        
        if (animateRightPartView) {
            rightPartConstraint.constant = newRightPartSpaceValue;
            [self.view layoutIfNeeded];
        }
    }];
     
    if (animateLeftPartView) {
        leftPartView = leftPartView == self.leftPlayerView ? self.leftRoleView : self.leftPlayerView;
        leftPartConstraint = leftPartView == self.leftPlayerView ? self.leftPlayerViewSpace : self.leftRoleViewSpace;
        newLeftPartSpaceValue = leftPartView == self.leftPlayerView ? 0 : -leftPartView.bounds.size.width;
        leftPartView.tag = 1;
    }
    
    if (animateRightPartView) {
        rightPartView = rightPartView == self.rightPlayerView ? self.rightRoleView : self.rightPlayerView;
        rightPartConstraint = rightPartView == self.rightPlayerView ? self.rightPlayerViewSpace : self.rightRoleViewSpace;
        newRightPartSpaceValue = rightPartView == self.rightPlayerView ? 0 : -rightPartView.bounds.size.width;

        rightPartView.tag = 1;
    }
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView animateWithDuration:0.5 delay:0.5 options:nil animations:^{
        if (animateLeftPartView) {
            leftPartConstraint.constant = newLeftPartSpaceValue;
            [self.view layoutIfNeeded];
        }
        
        if (animateRightPartView) {
            rightPartConstraint.constant = newRightPartSpaceValue;
            [self.view layoutIfNeeded];
        }
    } completion:nil];
}


-(void) initPlayerIds {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    id obj = [userDefaults objectForKey:@"pids"];
    pids = obj==nil ? [NSMutableArray new] : [NSMutableArray arrayWithArray:obj];
}

- (void) initRoles {
    GlobalSettings *global = [GlobalSettings globalSettings];
    
    engin = [CCEngin getEngin];
    roles = [global getRoles] ? [global getRoles] : engin.roles;
    roleNumbers = [NSMutableDictionary dictionaryWithDictionary: [global getRoleNumbers] ? [global getRoleNumbers] : engin.roleNumbers];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return pids.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"playerTableViewCell";
    
    PlayerTableViewCell *cell = [self.playerTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PlayerTableViewCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects) {
            if([currentObject isKindOfClass:[PlayerTableViewCell class]]) {
                cell = (PlayerTableViewCell *)currentObject;
                break;
            }
        }
    }
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* pid = [pids objectAtIndex:indexPath.row];
    NSString* name = [userDefaults stringForKey:[pid stringByAppendingString:@"-name"]];
    NSData* imgData = [userDefaults dataForKey:[pid stringByAppendingString:@"-img"]];
    UIImage* image = [UIImage imageWithData:imgData];
    
    cell.userId = pid;
    cell.userImage.image = image;
    cell.userName.text = name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerTableViewCell *cell = (PlayerTableViewCell *)[self.playerTableView cellForRowAtIndexPath:indexPath];
    if(![selectedPIds containsObject:cell.userId]) {
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexPaths addObject:[NSIndexPath indexPathForRow:selectedPIds.count inSection:0]];
        [selectedPIds addObject:cell.userId];
        [self.playerCollectionView performBatchUpdates:^{
            [self.playerCollectionView insertItemsAtIndexPaths:indexPaths];
        }
        completion: ^(BOOL finished){
            int numberOfItems = [self.playerCollectionView numberOfItemsInSection:0];
            if(numberOfItems > 0) {
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:numberOfItems-1 inSection:0];
                [self.playerCollectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerTableViewCell *cell = (PlayerTableViewCell *)[self.playerTableView cellForRowAtIndexPath:indexPath];
    [self deselectPlayer:cell.userId];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PlayerTableViewCell *cell = (PlayerTableViewCell *)[self.playerTableView cellForRowAtIndexPath:indexPath];
        NSString *pid = cell.userId;
        [self deselectPlayer:pid];
        
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [pids removeObject:pid];
        [userDefaults setObject:pids forKey:@"pids"];
        [userDefaults removeObjectForKey:[pid stringByAppendingString:@"-name"]];
        [userDefaults removeObjectForKey:[pid stringByAppendingString:@"-img"]];
        [userDefaults synchronize];
    }
    
    [self reloadPlayerTableView];
}

- (void) reloadPlayers {
    [self initPlayerIds];
    [self reloadPlayerTableView];
}

- (void) reloadPlayerTableView {
    [self.playerTableView reloadData];
    for (NSString *pid in selectedPIds) {
        int i = [pids indexOfObject:pid];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.playerTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)deselectPlayer: (NSString *) pid {
    if([selectedPIds containsObject:pid]) {
        int i = [selectedPIds indexOfObject:pid];
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        [selectedPIds removeObjectAtIndex:i];
        [self.playerCollectionView deleteItemsAtIndexPaths:indexPaths];
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.playerCollectionView) {
        return selectedPIds.count;
    } else {
        return roles.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.playerCollectionView) {
        PlayerCollectionViewCell *cell = (PlayerCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"playerCollectionViewCell" forIndexPath:indexPath];
        
        if (cell.gestureRecognizers.count == 0) {
            [cell addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(playerCellTapped:)]];
        }
        
        NSString *pid = [selectedPIds objectAtIndex:indexPath.row];
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* name = [userDefaults stringForKey:[pid stringByAppendingString:@"-name"]];
        NSData* imgData = [userDefaults dataForKey:[pid stringByAppendingString:@"-img"]];
        UIImage* image = [UIImage imageWithData:imgData];
        
        cell.userName.text = name;
        cell.userImage.image = image;
        
        return cell;
    } else {
        RoleCollectionViewCell *cell = (RoleCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"roleCollectionViewCell" forIndexPath:indexPath];
        
        if (cell.gestureRecognizers.count == 0) {
            [cell addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(roleCellTapped:)]];
        }
        
        Role r = [Engin getRoleFromString:[roles objectAtIndex:indexPath.row]];
        UIImage *image = [UIImage imageNamed: [[@"Icon-72-" stringByAppendingString: [CCEngin getRoleCode:r ]] stringByAppendingString: @".png"]];
        
        cell.role = r;
        cell.roleImage.image = image;
        cell.roleLabel.text = [CCEngin getRoleLabel:r];
        cell.roleNumber.text = [NSString stringWithFormat:@"%d", ((NSNumber*)[roleNumbers objectForKey:[CCEngin getRoleName:r]]).intValue];
        
        return cell;
    }
    
}

- (void)playerCellTapped:(UITapGestureRecognizer *)inGestureRecognizer {
    if (self.view.tag == 2) {
        self.view.tag = 0;
        [self animateViewWithLeftPart:self.leftPlayerView.tag!=1 andRightPart:self.rightPlayerView.tag!=1];
    } else {
        NSIndexPath *indexPath = [self.playerCollectionView indexPathForCell:(UICollectionViewCell *)inGestureRecognizer.view];
        
        NSString *pid = [selectedPIds objectAtIndex:indexPath.row];
        
        NSIndexPath *tableViewCellIndexPath = [NSIndexPath indexPathForRow:[pids indexOfObject:pid] inSection:0];
        [self.playerTableView deselectRowAtIndexPath:tableViewCellIndexPath animated:YES];
        [self deselectPlayer:pid];
    }
}

- (void)roleCellTapped:(UITapGestureRecognizer *)inGestureRecognizer {
    NSIndexPath *indexPath = [self.roleCollectionView indexPathForCell:(UICollectionViewCell *)inGestureRecognizer.view];
    
    RoleCollectionViewCell *cell = (RoleCollectionViewCell *)[self.roleCollectionView cellForItemAtIndexPath:indexPath];
    
    int row = [roles indexOfObject:[Engin getRoleName:cell.role]];
    [self.roleNumberPicker selectRow:row inComponent:0 animated:YES];
    [self selectRole:cell.role];
    
    if (self.view.tag == 2) {
        self.view.tag = 1;
        [self animateViewWithLeftPart:self.leftRoleView.tag!=1 andRightPart:self.rightRoleView.tag!=1];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    return component == 0 ? roles.count : maxRoleNumber;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        Role r = [Engin getRoleFromString:[roles objectAtIndex:row]];
        return [CCEngin getRoleLabel:r];
    } else {
        return [NSString stringWithFormat:@"%d", maxRoleNumber==1 ? staticRoleNumber : row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    Role r = [Engin getRoleFromString:[roles objectAtIndex:[pickerView selectedRowInComponent:0]]];
    
    if (component == 0) {
        [self selectRole:r];
    } else {
        [self setNumber:row forRole:r];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    switch (component){
        case 0:
            return 100.0f;
        case 1:
            return 50.0f;
    }
    return 0;
}

- (void) selectRole:(Role) r {
    if (r == Judge) {
        maxRoleNumber = 1;
        staticRoleNumber = ((NSNumber*)[roleNumbers objectForKey:[CCEngin getRoleName:r]]).intValue;
    } else {
        maxRoleNumber = 100;
    }
    [self.roleNumberPicker reloadComponent:1];
    
    UIImage *image = [UIImage imageNamed: [[@"Icon-72-" stringByAppendingString: [CCEngin getRoleCode:r]] stringByAppendingString: @".png"]];
    self.roleImageView.image = image;
    
    for (int i = 0; i<roles.count; i++) {
        RoleCollectionViewCell *cell = (RoleCollectionViewCell *)[self.roleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        cell.roleLabel.textColor = cell.role==r ? [UIColor redColor] : [UIColor blackColor];
    }
    
    [self.roleNumberPicker selectRow:((NSNumber*)[roleNumbers objectForKey:[CCEngin getRoleName:r]]).intValue inComponent:1 animated:YES];
}

- (void) setNumber:(int) num forRole:(Role) r {
    [roleNumbers setObject: [NSNumber numberWithInt:num] forKey:[CCEngin getRoleName:r]];
    
    RoleCollectionViewCell *cell = (RoleCollectionViewCell *)[self.roleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[roles indexOfObject:[Engin getRoleName:r]] inSection:0]];
    cell.roleNumber.text = [NSString stringWithFormat:@"%d", num];
    
    [self matchPlayerNumber];
}

-(int) getPlayerNumberDelta {
    NSArray* ids = [[GlobalSettings globalSettings] getPlayerIds];
    
    int rNum = 0;
    for(NSNumber* n in roleNumbers.allValues) {
        rNum += n.intValue;
    }
    
    GlobalSettings* global = [GlobalSettings globalSettings];
    int pNum = [global getGameMode] == NORMAL ? ids.count : ids.count*2-1;
    
    return rNum - pNum;
}

-(void) matchPlayerNumber {
    int delta = [self getPlayerNumberDelta];
    
    if(delta < 0) {
        self.statusLabel.text = [NSString stringWithFormat:@"角色数目过少, 请再添加%d个角色", -delta];
    } else if (delta > 0) {
        self.statusLabel.text = [NSString stringWithFormat:@"角色数目过多, 请再减少%d个角色", delta];
    } else {
        self.statusLabel.text = @"可以开始游戏";
    }
}

-(BOOL) isRedyToStart {
    return [self getPlayerNumberDelta]==0;
}


@end
