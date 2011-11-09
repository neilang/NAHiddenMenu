//
//  MainMenu.m
//  Demo
//
//  Created by Neil Ang on 9/11/11.
//  Copyright (c) 2011 neilang.com. All rights reserved.
//

#import "MainMenu.h"
#import "SampleTableViewController.h"
#import "NAHiddenMenuController.h"

@implementation MainMenu

@synthesize viewControllers = _viewControllers;

- (id)init {
    self = [super init];
    if (self) {
        
        UIViewController *viewController1 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        viewController1.view.backgroundColor = [UIColor redColor];
        viewController1.title = @"Example 1";
        UINavigationController *viewController1NavController = [[UINavigationController alloc] initWithRootViewController:viewController1];
        
        UIViewController *viewController2 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        viewController2.view.backgroundColor = [UIColor blueColor];
        viewController2.title = @"Example 2";
        UINavigationController *viewController2NavController = [[UINavigationController alloc] initWithRootViewController:viewController2];
        
        SampleTableViewController *tableViewController = [[SampleTableViewController alloc] initWithNibName:nil bundle:nil];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
        
        self.viewControllers = [NSArray arrayWithObjects:viewController1NavController, viewController2NavController, navController, nil];
        
    }
    return self;
}

-(UIViewController *)defualtViewControllerForHiddenMenu:(NAHiddenMenuController *)hiddenMenu{
    
    // Set the first table row as selected too
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [hiddenMenu.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];

    UINavigationController *navController = [self.viewControllers objectAtIndex:0];
    UIViewController *viewController      = [navController.viewControllers objectAtIndex:0];
    
    if (!viewController.navigationItem.leftBarButtonItem) {
        UIBarButtonItem  *menuButton     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:hiddenMenu action:@selector(showMenu:)];
        viewController.navigationItem.leftBarButtonItem = menuButton;
    }

    return navController;
}

-(UIViewController *)hiddenMenu:(NAHiddenMenuController *)hiddenMenu viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UINavigationController *navController = [self.viewControllers objectAtIndex:indexPath.row];
    UIViewController *viewController      = [navController.viewControllers objectAtIndex:0];
    
    if (!viewController.navigationItem.leftBarButtonItem) {
        UIBarButtonItem  *menuButton     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:hiddenMenu action:@selector(showMenu:)];
        viewController.navigationItem.leftBarButtonItem = menuButton;
    }
    
    return navController;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"HiddenMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Example %d", indexPath.row+1];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.viewControllers count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


@end
