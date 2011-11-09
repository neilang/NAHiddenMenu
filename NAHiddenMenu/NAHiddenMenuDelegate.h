//
//  NAHiddenMenuDelegate.h
//
//  Created by Neil Ang on 9/11/11.
//  Copyright (c) 2011 neilang.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NAHiddenMenuController;

// The menu is a custom table view, and the following selectors are required to make it work
@protocol NAHiddenMenuDelegate <NSObject>

@required

// Return the view controller to be presented when a menu row is tapped, or nil.
-(UIViewController *)hiddenMenu:(NAHiddenMenuController *)hiddenMenu viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath;

// The default view controller to show on startup. This cannot be nil.
-(UIViewController *)defualtViewControllerForHiddenMenu:(NAHiddenMenuController *)hiddenMenu;


// Re-implementation of UITableViewDataSource protocol
@required

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@optional

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;


@end
