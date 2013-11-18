//
//  RoleViewController.m
//  JudgeHelper
//
//  Created by YANG FAN on 16/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "RoleViewController.h"
#import "CCEngin.h"
#import "GlobalSettings.h"
#import "RoleCollectionViewCell.h"
#import "AppDelegate.h"
#import "GameLayer.h"

@interface RoleViewController ()

@end

@implementation RoleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initRoles];
    [self selectRole:Judge];
    [self matchPlayerNumber];
    
    [self.roleCollectionView registerNib:[UINib nibWithNibName:@"RoleCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"roleCollectionViewCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

Engin *engin;
NSArray *roles;
NSMutableDictionary *roleNumbers;
- (void) initRoles {
    GlobalSettings *global = [GlobalSettings globalSettings];
    
    engin = [CCEngin getEngin];
    roles = [global getRoles] ? [global getRoles] : engin.roles;
    roleNumbers = [NSMutableDictionary dictionaryWithDictionary: [global getRoleNumbers] ? [global getRoleNumbers] : engin.roleNumbers];
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return roles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)roleCellTapped:(UITapGestureRecognizer *)inGestureRecognizer {
    NSIndexPath *indexPath = [self.roleCollectionView indexPathForCell:(UICollectionViewCell *)inGestureRecognizer.view];
    
    RoleCollectionViewCell *cell = (RoleCollectionViewCell *)[self.roleCollectionView cellForItemAtIndexPath:indexPath];
    
    int row = [roles indexOfObject:[Engin getRoleName:cell.role]];
    [self.roleNumberPicker selectRow:row inComponent:0 animated:YES];
    [self selectRole:cell.role];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

int maxRoleNumber;
int staticRoleNumber;
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
        maxRoleNumber = 99;
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

- (IBAction)actionButtonTapped:(id)sender {
    [self matchPlayerNumber];
    if ([self isRedyToStart]) {
        [engin initRoles: roleNumbers];
    
        CCDirector *director = [CCDirector sharedDirector];
        if(director.runningScene != nil) {
            [director replaceScene:[GameLayer scene]];
        }
        [self.navigationController pushViewController:director animated:YES];
        //[self.navigationController pushViewController:[[RootViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
    }
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
