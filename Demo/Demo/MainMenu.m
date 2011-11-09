//
//  MainMenu.m
//  Demo
//
//  Created by Neil Ang on 9/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "SampleTableViewController.h"

@implementation MainMenu

@synthesize viewControllers = _viewControllers;

- (id)init {
    self = [super init];
    if (self) {
        
        UIViewController *viewController1 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        viewController1.view.backgroundColor = [UIColor blueColor];

        UIViewController *viewController2 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        viewController2.view.backgroundColor = [UIColor redColor];
        
        SampleTableViewController *tableViewController = [[SampleTableViewController alloc] initWithNibName:nil bundle:nil];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
        
        self.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, navController, nil];
        
    }
    return self;
}

-(UIViewController *)defualtViewController{
    return [self.viewControllers objectAtIndex:0];
}

-(UIViewController *)tableView:(UITableView *)tableView viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.viewControllers objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"HiddenMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Example %d", indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


@end
