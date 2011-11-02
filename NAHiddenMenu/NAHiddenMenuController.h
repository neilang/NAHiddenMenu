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
@property (nonatomic, copy, readonly)   NSArray          *viewControllers;
@property (nonatomic, assign, readonly) BOOL              isAnimating;

- (id)initWithViewControllers:(NSArray *)viewControllers;
- (IBAction)showMenu:(id)sender;
- (void)setRootViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end


@interface NAHiddenMenuTouchView : UIView
@property (nonatomic, assign) NAHiddenMenuController *hiddenMenuController;
@end;