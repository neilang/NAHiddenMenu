//
//  NAHiddenMenuController.m
//
//  Created by Neil Ang on 2/11/11.
//  Copyright (c) 2011 neilang.com. All rights reserved.
//

#import "NAHiddenMenuController.h"
#import <QuartzCore/QuartzCore.h>

#ifndef __IPHONE_5_0
#warning "NAHiddenMenuController uses features only available in iOS SDK 5.0 and later."
#endif

#define HIDDEN_MENU_WIDTH 280.0f 
#define REVEAL_ANIMATION_SPEED 0.4f
#define HIDE_MENU_DELAY 0.2f
#define CONTAINER_SHADOW_WIDTH 10.0

@interface NAHiddenMenuController()
@property (nonatomic, assign, readwrite) UIViewController *currentViewController;
@property (nonatomic, retain, readwrite) UITableView      *tableView;
@property (nonatomic, retain)            UIView           *containerView;
@property (nonatomic, retain)            UIView           *touchView;
@property (nonatomic, assign, readwrite) BOOL              isAnimating;
@property (nonatomic, assign, readwrite) BOOL              isMenuVisible;
@end

@implementation NAHiddenMenuController

@synthesize currentViewController = _currentViewController;
@synthesize containerView         = _containerView;
@synthesize touchView             = _touchView;
@synthesize isAnimating           = _isAnimating;
@synthesize isMenuVisible         = _isMenuVisible;
@synthesize tableView             = _tableView;
@synthesize hiddenMenuDelegate    = _hiddenMenuDelegate;

- (id)initWithDelegate:(id<NAHiddenMenuDelegate>)delegate {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.hiddenMenuDelegate    = delegate;
        self.currentViewController = nil;
        self.isMenuVisible         = YES;
        self.isAnimating           = NO;

        // Setup the menu table view
        CGRect tableViewFrame     = self.view.frame;
        tableViewFrame.origin     = CGPointZero;
        tableViewFrame.size.width = HIDDEN_MENU_WIDTH;
        
        UITableView *tableView     = [[UITableView alloc] initWithFrame:tableViewFrame];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        tableView.dataSource = self;
        tableView.delegate   = self;
        
        self.tableView = tableView;
        
        [self.view addSubview:self.tableView];
        
        // Setup the container view which will hold the child view controllers view
        CGRect containerViewFrame   = self.view.frame;
        containerViewFrame.origin   = CGPointZero;
        containerViewFrame.origin.x = HIDDEN_MENU_WIDTH;
        
        UIView *containerView             = [[UIView alloc] initWithFrame:containerViewFrame];
        containerView.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        containerView.autoresizesSubviews = YES;
        
        self.containerView = containerView;
        
        // The container view also needs a subtle shadow
        CAGradientLayer *containerShadow = [[CAGradientLayer alloc] init];
        containerShadow.frame            = CGRectMake(-CONTAINER_SHADOW_WIDTH, 0, CONTAINER_SHADOW_WIDTH, self.containerView.frame.size.height);
        containerShadow.colors           = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor], nil];
        containerShadow.startPoint       = CGPointMake(1, 1);
        
        [self.containerView.layer addSublayer:containerShadow];
        [self.view addSubview:self.containerView];
        
        // Setup the touch mask for when the menu is visible
        NAHiddenMenuTouchView *touchView = [[NAHiddenMenuTouchView alloc] initWithFrame:self.containerView.frame];
        touchView.hiddenMenuController   = self;
        self.touchView                   = touchView;
        
        [self.view addSubview:touchView];
                
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Set the default view controller
    CGRect frame = self.containerView.frame;
    frame.origin = CGPointZero;
    UIViewController * viewController = [self.hiddenMenuDelegate defualtViewController];
    viewController.view.frame         = frame;
    
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
    
    [viewController viewWillAppear:NO];
    [self.containerView addSubview:viewController.view];
    [viewController viewDidAppear:NO];
    self.currentViewController = viewController;
}

-(void)viewDidLoad{

    // Add Left swipe gesture
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    
    // Add right swipe gesture
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
}

- (IBAction)showMenu:(id)sender{
        
    if(self.isAnimating) return;
    if(self.isMenuVisible) return;
    
    self.isAnimating   = YES;
    self.isMenuVisible = YES;
    
    self.touchView.hidden = NO;
    
    [UIView animateWithDuration:REVEAL_ANIMATION_SPEED animations:^{
        CGRect frame = self.containerView.frame;
        frame.origin.x = HIDDEN_MENU_WIDTH;
        self.containerView.frame = frame;
    } completion:^(BOOL finished){
        self.isAnimating = NO;
    }];
}

- (void)hideMenuWithDelay:(NSTimeInterval)delay{
    
    if(self.isAnimating) return;
    if(!self.isMenuVisible) return;

    self.isMenuVisible = NO;
    self.isAnimating   = YES;
    
    self.touchView.hidden = YES;
    
    [UIView animateWithDuration:REVEAL_ANIMATION_SPEED delay:delay options:UIViewAnimationCurveLinear animations:^{
        CGRect frame = self.containerView.frame;
        frame.origin = CGPointZero;
        self.containerView.frame = frame;
    } completion:^(BOOL finished){
        self.isAnimating = NO;
    }];
}

-(IBAction)hideMenu:(id)sender {
    [self hideMenuWithDelay:0.0f];
}

- (void)setRootViewController:(UIViewController *)viewController{
    
    // Add the view controller as a child
    
    if (viewController == self.currentViewController) {
        [self hideMenu:nil];
        return;
    }
    
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
        
    // Reset the frame view
    CGRect frame = self.containerView.frame;
    frame.origin = CGPointZero;
    viewController.view.frame = frame;
    
    // Perform the view transition
    [self transitionFromViewController:self.currentViewController toViewController:viewController duration:0.0f options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished){
        
        // Remove the old viewcontroller
        [self.currentViewController willMoveToParentViewController:nil];
        [self.currentViewController removeFromParentViewController];
        
        // Reset the pointer and hide the menu
        self.currentViewController = viewController;
        [self hideMenuWithDelay:HIDE_MENU_DELAY];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        
    if ([self.hiddenMenuDelegate respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        [self.hiddenMenuDelegate performSelector:@selector(numberOfSectionsInTableView:) withObject:tableView];
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.hiddenMenuDelegate tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.hiddenMenuDelegate tableView:tableView cellForRowAtIndexPath:indexPath];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = [self.hiddenMenuDelegate tableView:tableView viewControllerForRowAtIndexPath:indexPath];
    
    if (viewController) {
        [self setRootViewController:viewController];
    }
}

#pragma mark - UIViewControllerRotation
// Move this to delegate??
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)	{
		return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
	} else {
		return YES;
	}
}

@end

@implementation NAHiddenMenuTouchView

@synthesize hiddenMenuController = _hiddenMenuController;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {    
    [self.superview touchesBegan:touches withEvent:event];
    [self.hiddenMenuController hideMenu:nil];
}

@end

#undef HIDDEN_MENU_WIDTH
#undef REVEAL_ANIMATION_SPEED
#undef CONTAINER_SHADOW_WIDTH
#undef HIDE_MENU_DELAY
