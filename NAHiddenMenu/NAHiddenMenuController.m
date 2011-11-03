//
//  NAHiddenMenuController.m
//
//  Created by Neil Ang on 2/11/11.
//  Copyright (c) 2011 neilang.com. All rights reserved.
//

#import "NAHiddenMenuController.h"
#import <QuartzCore/QuartzCore.h>


#define HIDDEN_MENU_WIDTH 280.0f 
#define MENU_BAR_OFFSET 20.0
#define REVEAL_ANIMATION_SPEED 0.4f
#define HIDE_MENU_DELAY 0.3f
#define PROXY_SHADOW_WIDTH 10.0

@interface NAHiddenMenuController()
@property (nonatomic, assign, readwrite) UIViewController *currentViewController;
@property (nonatomic, copy, readwrite)   NSArray          *viewControllers;
@property (nonatomic, retain)            UITableView      *tableView;
@property (nonatomic, retain)            UIView           *proxyView;
@property (nonatomic, retain)            UIView           *touchView;
@property (nonatomic, assign, readwrite) BOOL              isAnimating;
@property (nonatomic, assign, readwrite) BOOL              isMenuVisible;
@end


@implementation NAHiddenMenuController

@synthesize currentViewController = _currentViewController;
@synthesize viewControllers       = _viewControllers;
@synthesize proxyView             = _proxyView;
@synthesize touchView             = _touchView;
@synthesize isAnimating           = _isAnimating;
@synthesize isMenuVisible         = _isMenuVisible;
@synthesize tableView             = _tableView;

- (id)initWithViewControllers:(NSArray *)viewControllers{
    
    assert([viewControllers count] > 0);
    
    self = [super init];
    if (self) {
        
        self.currentViewController = nil;
        
        // Each viewController must have a UINavigationBar, so they are checked and added
        NSMutableArray *menuViewControllers = [[NSMutableArray alloc] initWithArray:viewControllers];
        
        for (size_t i = 0; i < [menuViewControllers count]; i++) {
            UIViewController *viewController = [menuViewControllers objectAtIndex:i];
            if (viewController.navigationController == nil) {
                UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:viewController];
                [menuViewControllers replaceObjectAtIndex:i withObject:navController];
                
                #if !__has_feature(objc_arc)
                [navController release];
                #endif
            }
                        
            // TODO: change this icon
            viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(showMenu:)];
        }
        
        self.viewControllers = menuViewControllers;
        
        #if !__has_feature(objc_arc)
        [menuViewControllers release];
        #endif
        
        // Add the table view (which will display the menu)
        
        CGRect tableViewFrame = self.view.frame;
        tableViewFrame.origin.x = 0.0f;
        tableViewFrame.origin.y = 0.0f;
        tableViewFrame.size.width = HIDDEN_MENU_WIDTH;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:tableViewFrame];
        
        tableView.dataSource = self;
        tableView.delegate   = self;
        
        self.tableView = tableView;
        
        #if !__has_feature(objc_arc)
        [tableView release];
        #endif

        [self.view addSubview:self.tableView];

        // Add a proxy view to display the current view controllers view
        
        CGRect proxyViewFrame = self.view.frame;
        
        proxyViewFrame.origin.x = tableViewFrame.size.width;
        proxyViewFrame.size.height = proxyViewFrame.size.height + MENU_BAR_OFFSET;
        proxyViewFrame.origin.y = -MENU_BAR_OFFSET;
        
        UIView *proxyView = [[UIView alloc] initWithFrame:proxyViewFrame];
        self.proxyView = proxyView;
        
        #if !__has_feature(objc_arc)
        [proxyView release];
        #endif
        
        // Give the proxy view a subtle shadow
        
        CAGradientLayer *proxyShadow = [[CAGradientLayer alloc] init];
        
        proxyShadow.frame      = CGRectMake(-PROXY_SHADOW_WIDTH, 0, PROXY_SHADOW_WIDTH, self.proxyView.frame.size.height);
        proxyShadow.colors     = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor], nil];
        proxyShadow.startPoint = CGPointMake(1, 1);
        
        [self.proxyView.layer addSublayer:proxyShadow];
        
        #if !__has_feature(objc_arc)
        [proxyShadow release];
        #endif
        
        [self.view addSubview:self.proxyView];
        
        // Setup a touch mask for when the menu is visible
        NAHiddenMenuTouchView *touchView = [[NAHiddenMenuTouchView alloc] initWithFrame:self.proxyView.frame];
        touchView.hiddenMenuController = self;
        self.touchView = touchView;
        #if !__has_feature(objc_arc)
        [touchView release];
        #endif
        
        [self.view addSubview:touchView];
        
        // Select the first row to fake the initial selection
        self.isMenuVisible = NO;
        self.isAnimating   = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];

        // Load the first view controller, but also reveal the menu
        UIViewController * vc = [self.viewControllers objectAtIndex:0];
        [self setRootViewController:vc animated:NO];
        [self showMenu:nil];
        
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
        CGRect frame = self.proxyView.frame;
        frame.origin.x = HIDDEN_MENU_WIDTH;
        self.proxyView.frame = frame;
    } completion:^(BOOL finished){
        self.isAnimating = NO;
    }];
}

- (IBAction)hideMenu:(id)sender{

    if(self.isAnimating) return;
    if(!self.isMenuVisible) return;

    self.isMenuVisible = NO;
    self.isAnimating   = YES;

    
    self.touchView.hidden = YES;
    
    // When closing the menu there should only be a delay when a new table row is selected
    float delay = sender == self.tableView ? HIDE_MENU_DELAY : 0.0;
    
    [UIView animateWithDuration:REVEAL_ANIMATION_SPEED delay:delay options:UIViewAnimationCurveLinear animations:^{
        CGRect frame = self.proxyView.frame;
        frame.origin.x = 0.0f;
        self.proxyView.frame = frame;
    } completion:^(BOOL finished){
        self.isAnimating = NO;
    }];
}

- (void)setRootViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    id sender = nil; 
    
    if (viewController != self.currentViewController) {
        
        // Remove the old subview
        
        [self.currentViewController viewWillDisappear:animated];
        
        for (UIView *view in self.proxyView.subviews) {
            [view removeFromSuperview];
        }
        
        [self.currentViewController viewDidDisappear:animated];
        
        // Add the new subview
        
        [viewController viewWillAppear:YES];
        [self.proxyView addSubview:viewController.view];
        [viewController viewDidAppear:YES];
        
        // Keep a reference to the current vc
        self.currentViewController = viewController;
        
        // Assume that this was set by selecting a new row in the menu
        sender = self.tableView;
    }
    
    if(animated){
        [self hideMenu:sender];
    }
    else{
        CGRect frame = self.proxyView.frame;
        frame.origin.x = 0.0f;
        self.proxyView.frame = frame;
    }
    
}

#if !__has_feature(objc_arc)
- (void)dealloc {
    
    [_viewControllers release]; _viewControllers = nil;
    [_proxyView release]; _proxyView = nil;
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
    return [self.viewControllers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HiddenMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIViewController *vc = (UIViewController *)[self.viewControllers objectAtIndex:indexPath.row];
    cell.textLabel.text = vc.title;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = (UIViewController *)[self.viewControllers objectAtIndex:indexPath.row];  
    [self setRootViewController:vc animated:YES];
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
#undef MENU_BAR_OFFSET
#undef REVEAL_ANIMATION_SPEED
#undef PROXY_SHADOW_WIDTH
#undef HIDE_MENU_DELAY
