//
//  MainMenuViewController.m
//  JudgeHelper
//
//  Created by fyang on 14/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "MainMenuViewController.h"
#import "AppDelegate.h"
#import "GlobalSettings.h"
#import "PlayerTableViewCell.h"
#import "PlayerCollectionViewCell.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    selectedPIds = [NSMutableArray new];
    [self initPlayerIds];
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

// Add new method
- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (IBAction)nextButtonTapped:(id)sender {
    NSMutableArray *selectedPlayerIds = [NSMutableArray new];
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *path in selectedIndexPaths) {
        PlayerTableViewCell *cell = (PlayerTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
        [selectedPlayerIds addObject:cell.userId];
    }
    GlobalSettings* global = [GlobalSettings globalSettings];
    [global setPlayerIds: selectedPlayerIds];

    
    UIViewController *rootViewController = (UIViewController*)[(AppController*)[[UIApplication sharedApplication] delegate] viewController];
    [self.navigationController pushViewController:rootViewController animated:YES];
}



NSMutableArray* pids;

-(void) initPlayerIds {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    id obj = [userDefaults objectForKey:@"pids"];
    pids = obj==nil ? [NSMutableArray new] : [NSMutableArray arrayWithArray:obj];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return pids.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"playerTableViewCell";
    
    PlayerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
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
    PlayerTableViewCell *cell = (PlayerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if(![selectedPIds containsObject:cell.userId]) {
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexPaths addObject:[NSIndexPath indexPathForRow:selectedPIds.count inSection:0]];
        [selectedPIds addObject:cell.userId];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
        }
        completion: ^(BOOL finished){
            [self.collectionView scrollToItemAtIndexPath:indexPaths.lastObject atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerTableViewCell *cell = (PlayerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if([selectedPIds containsObject:cell.userId]) {
        NSInteger* i = [selectedPIds indexOfObject:cell.userId];
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        [selectedPIds removeObjectAtIndex:i];
        [self.collectionView deleteItemsAtIndexPaths:indexPaths];
    }
}


NSMutableArray* selectedPIds;

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return selectedPIds.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"playerCollectionViewCell";
    [self.collectionView registerNib:[UINib nibWithNibName:@"PlayerCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
    PlayerCollectionViewCell *cell = (PlayerCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSString *pid = [selectedPIds objectAtIndex:indexPath.row];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* name = [userDefaults stringForKey:[pid stringByAppendingString:@"-name"]];
    NSData* imgData = [userDefaults dataForKey:[pid stringByAppendingString:@"-img"]];
    UIImage* image = [UIImage imageWithData:imgData];
    
    cell.userName.text = name;
    cell.userImage.image = image;
    
    return cell;
    
}

@end
