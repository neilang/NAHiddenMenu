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
@property (nonatomic, retain)            UITableView      *tableView;
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

- (id)initWithViewControllers:(NSArray *)viewControllers{
    
    assert([viewControllers count] > 0);
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        self.currentViewController = nil;
        
        // Make each view controller a child of this view controller
        for (UIViewController *viewController in viewControllers) {
            [self addChildViewController:viewController];
            [viewController didMoveToParentViewController:self];
            
            CGRect frame = viewController.view.frame;
            frame.origin = CGPointZero;
            viewController.view.frame = frame;
        }
        
        // Add the table view (which will display the menu)
        CGRect tableViewFrame = self.view.frame;
        tableViewFrame.origin.x = 0.0f;
        tableViewFrame.origin.y = 0.0f;
        tableViewFrame.size.width = HIDDEN_MENU_WIDTH;
        
        UITableView *tableView     = [[UITableView alloc] initWithFrame:tableViewFrame];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        tableView.dataSource = self;
        tableView.delegate   = self;
        
        self.tableView = tableView;
        
        #if !__has_feature(objc_arc)
        [tableView release];
        #endif

        [self.view addSubview:self.tableView];

        
        // Add a container view to display the current view controllers view
        CGRect containerViewFrame   = self.view.frame;
        containerViewFrame.origin   = CGPointZero;
        containerViewFrame.origin.x = HIDDEN_MENU_WIDTH;
        
        UIView *containerView = [[UIView alloc] initWithFrame:containerViewFrame];
        self.containerView = containerView;
        self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.containerView.autoresizesSubviews = YES;
        self.containerView.backgroundColor = [UIColor yellowColor];
        
        
        #if !__has_feature(objc_arc)
        [containerView release];
        #endif
        
        // Give the container view a subtle shadow
        CAGradientLayer *containerShadow = [[CAGradientLayer alloc] init];
        
        containerShadow.frame      = CGRectMake(-CONTAINER_SHADOW_WIDTH, 0, CONTAINER_SHADOW_WIDTH, self.containerView.frame.size.height);
        containerShadow.colors     = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor], nil];
        containerShadow.startPoint = CGPointMake(1, 1);
        
        [self.containerView.layer addSublayer:containerShadow];
        
        #if !__has_feature(objc_arc)
        [containerShadow release];
        #endif
        
        [self.view addSubview:self.containerView];
        
        // Setup a touch mask for when the menu is visible
        NAHiddenMenuTouchView *touchView = [[NAHiddenMenuTouchView alloc] initWithFrame:self.containerView.frame];
        touchView.hiddenMenuController = self;
        self.touchView = touchView;
        #if !__has_feature(objc_arc)
        [touchView release];
        #endif
        
        [self.view addSubview:touchView];
        
        self.isMenuVisible = YES;
        self.isAnimating   = NO;

        // Load the first view controller
        UIViewController * vc = [self.childViewControllers objectAtIndex:0];
        [vc viewWillAppear:NO];
        [self.containerView addSubview:vc.view];
        [vc viewDidAppear:NO];
        
        self.currentViewController = vc;
        
        // Select the first row to fake the initial selection
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        
    }
    return self;
}



-(void)viewDidLoad{
    
    // Add Left swipe gesture
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    #if !__has_feature(objc_arc)
    [leftSwipe release];
    #endif
    
    // Add right swipe gesture
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
    #if !__has_feature(objc_arc)
    [rightSwipe release];
    #endif
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
    
    // When closing the menu there should only be a delay when a new table row is selected
    
    [UIView animateWithDuration:REVEAL_ANIMATION_SPEED delay:delay options:UIViewAnimationCurveLinear animations:^{
        CGRect frame = self.containerView.frame;
        frame.origin.x = 0.0f;
        self.containerView.frame = frame;
    } completion:^(BOOL finished){
        self.isAnimating = NO;
    }];
}

-(IBAction)hideMenu:(id)sender {
    [self hideMenuWithDelay:0.0f];
}

- (void)setRootViewController:(UIViewController *)viewController{
    
    if (viewController == self.currentViewController) {
        [self hideMenu:nil];
        return;
    }
    
    // Reset the view frame
    CGRect frame = self.currentViewController.view.frame;
    frame.origin = CGPointZero;
    viewController.view.frame = frame;
    
    // Perform the view transition
    [self transitionFromViewController:self.currentViewController toViewController:viewController duration:0.0f options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished){
        self.currentViewController = viewController;
        [self hideMenuWithDelay:HIDE_MENU_DELAY]; // hide the menu with delay
    }];
}

#if !__has_feature(objc_arc)
- (void)dealloc {
    
    [_containerView release]; _containerView = nil;
    [_touchView release]; _touchView = nil;
    [_tableView release]; _tableView = nil;
    
    _currentViewController = nil;
    
    [super dealloc];
}
#endif

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.childViewControllers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HiddenMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIViewController *vc = (UIViewController *)[self.childViewControllers objectAtIndex:indexPath.row];
    cell.textLabel.text = vc.title;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = (UIViewController *)[self.childViewControllers objectAtIndex:indexPath.row];  
    
    [self setRootViewController:vc];
    
}

#pragma mark - UIViewControllerRotation

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

#if !__has_feature(objc_arc)
- (void)dealloc {
    _hiddenMenuController = nil;
    [super dealloc];
}
#endif

@end

#undef HIDDEN_MENU_WIDTH
#undef REVEAL_ANIMATION_SPEED
#undef CONTAINER_SHADOW_WIDTH
#undef HIDE_MENU_DELAY
