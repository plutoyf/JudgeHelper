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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [pids count];
}

//4
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //5
    static NSString *cellIdentifier = @"playerTableViewCell";
    
    PlayerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //5.1 you do not need this if you have set SettingsCell as identifier in the storyboard (else you can remove the comments on this code)
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PlayerTableViewCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects) {
            if([currentObject isKindOfClass:[PlayerTableViewCell class]]) {
                cell = (PlayerTableViewCell *)currentObject;
                break;
            }
        }
    }
    
    
    //6
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* id = [pids objectAtIndex:indexPath.row];
    NSString* name = [userDefaults stringForKey:[id stringByAppendingString:@"-name"]];
    NSData* imgData = [userDefaults dataForKey:[id stringByAppendingString:@"-img"]];
    UIImage* image = [UIImage imageWithData:imgData];

    //7
    cell.userId = id;
    cell.userImage.image = image;
    cell.userName.text = name;
    
    return cell;
}

NSMutableArray* pids;
-(void) initPlayerIds {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    id obj = [userDefaults objectForKey:@"pids"];
    pids = obj==nil ? [NSMutableArray new] : [NSMutableArray arrayWithArray:obj];
}

@end
