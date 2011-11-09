//
//  NAHiddenMenuDelegate.h
//  Demo
//
//  Created by Neil Ang on 9/11/11.
//  Copyright (c) 2011 neilang.com. All rights reserved.
//

#import <Foundation/Foundation.h>

// The menu is a custom table view, and the following selectors are required to make it work
@protocol NAHiddenMenuDelegate <NSObject>

@required

// Return the view controller to be presented when a menu row is tapped, or nil if you wish to implement your own action.
-(UIViewController *)tableView:(UITableView *)tableView viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath;

// The default view controller to show on startup. This cannot be nil.
-(UIViewController *)defualtViewController;

// Re-implementation of UITableViewDataSource protocol
@required

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@optional

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;


@end
