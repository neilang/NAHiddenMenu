//
//  NAHiddenMenuController.h
//  Example
//
//  Created by Neil Ang on 2/11/11.
//  Copyright (c) 2011 neilang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NAHiddenMenuController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign, readonly) UIViewController *currentViewController;
@property (nonatomic, assign, readonly) BOOL              isAnimating;
@property (nonatomic, assign, readonly) BOOL              isMenuVisible;

- (id)initWithViewControllers:(NSArray *)viewControllers;
- (IBAction)showMenu:(id)sender;
-(IBAction)hideMenu:(id)sender;
- (void)hideMenuWithDelay:(NSTimeInterval)delay;
- (void)setRootViewController:(UIViewController *)viewController;

@end


@interface NAHiddenMenuTouchView : UIView
@property (nonatomic, assign) NAHiddenMenuController *hiddenMenuController;
@end;