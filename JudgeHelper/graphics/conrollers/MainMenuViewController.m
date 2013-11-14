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
    self.tweetsArray = [[NSArray alloc] initWithObjects:
                        @"Always put your fears behind you and your dreams in front of you.",
                        @"A relationship with no trust is like a cell phone with no service, all you can do is play games.",
                        @"People should stop talking about their problem and start thinking about the solution.",
                        @"Dear Chuck Norris, Screw you. I can grill burgers under water. Sincerely, Spongebob Squarepants.",
                        @"My arms will always be open for you, they will never close, not unless you're in them.",
                        nil];
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
    UIViewController *rootViewController = (UIViewController*)[(AppController*)[[UIApplication sharedApplication] delegate] viewController];
    [self.navigationController pushViewController:rootViewController animated:YES];}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [pids count];
}

//4
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //5
    static NSString *cellIdentifier = @"PlayerTableViewCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //5.1 you do not need this if you have set SettingsCell as identifier in the storyboard (else you can remove the comments on this code)
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    
    //6
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* id = [pids objectAtIndex:indexPath.row];
    NSString* name = [userDefaults stringForKey:[id stringByAppendingString:@"-name"]];
    NSData* imgData = [userDefaults dataForKey:[id stringByAppendingString:@"-img"]];
    UIImage* image = [UIImage imageWithData:imgData];

    //7
    //UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    //UILabel *label = (UILabel *)[cell viewWithTag:2];
    //[imageView setImage:image];
    //[label setText:name];
    cell.imageView.image = image;
    cell.textLabel.text = name;
    
    return cell;
}

NSMutableArray* pids;
-(void) initPlayerIds {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    id obj = [userDefaults objectForKey:@"pids"];
    pids = obj==nil ? [NSMutableArray new] : [NSMutableArray arrayWithArray:obj];
}

@end
