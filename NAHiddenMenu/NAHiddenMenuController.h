//
//  NAHiddenMenuController.h
//  Example
//
//  Created by Neil Ang on 2/11/11.
//  Copyright (c) 2011 neilang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NAHiddenMenuDelegate.h"

@interface NAHiddenMenuController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign, readonly) UIViewController *currentViewController;
@property (nonatomic, assign, readonly) BOOL              isAnimating;
@property (nonatomic, assign, readonly) BOOL              isMenuVisible;
@property (nonatomic, retain, readonly) UITableView      *tableView;

// Delegate for the table view and data source.
@property (nonatomic, retain) id<NAHiddenMenuDelegate>    hiddenMenuDelegate;

- (id)initWithDelegate:(id<NAHiddenMenuDelegate>)delegate;
- (IBAction)showMenu:(id)sender;
- (IBAction)hideMenu:(id)sender;
- (void)hideMenuWithDelay:(NSTimeInterval)delay;
- (void)setRootViewController:(UIViewController *)viewController;

@end


@interface NAHiddenMenuTouchView : UIView
@property (nonatomic, assign) NAHiddenMenuController *hiddenMenuController;
@end;