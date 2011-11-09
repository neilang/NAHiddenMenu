//
//  MainMenu.h
//  Demo
//
//  Created by Neil Ang on 9/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NAHiddenMenuDelegate.h"

@interface MainMenu : NSObject<NAHiddenMenuDelegate>

@property (nonatomic, retain) NSArray *viewControllers;

@end
