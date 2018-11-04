//
//  DataViewController.m
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 10/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "DataViewController.h"

@interface DataViewController ()

@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject description];
    EKEventViewController *eventVC = [[EKEventViewController alloc] init];
    [eventVC.view setBackgroundColor:[UIColor clearColor]];
    [eventVC.view setOpaque:FALSE];
    [eventVC setEvent:self.dataObject];
    [eventVC setDelegate:self];
    [self addChild:eventVC withChildToRemove:nil];
    [self enumerateSubviews:self.view];
}

- (void)enumerateSubviews:(typeof(UIView *))view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
//    if ([subviews count] == 0) return; // COUNT CHECK LINE
    
    for (typeof(UIView *)subview in subviews) {
        [subview setBackgroundColor:[UIColor clearColor]];
        [subview setOpaque:FALSE];
        [subview setAlpha:0.9];
        [self enumerateSubviews:subview];
    }
}

- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action
{
    [controller dismissViewControllerAnimated:TRUE completion:^{
        
    }];
}

- (void)addChild:(UIViewController *)childToAdd withChildToRemove:(UIViewController *)childToRemove
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (childToRemove != nil)
    {
        if ([childToRemove isKindOfClass:[EKEventViewController class]]) {
            [childToRemove.view removeFromSuperview];
            [childToRemove removeFromParentViewController];
        }
    }
    
    if (childToAdd != nil)
    {
        [self addChildViewController:childToAdd];
        [childToAdd didMoveToParentViewController:self];
        
        if ([childToAdd isKindOfClass:[EKEventViewController class]]) {
            // match the child size to its parent
            CGRect frame = childToAdd.view.frame;
            frame.size.height = CGRectGetHeight(self.containerView.frame);
            frame.size.width = CGRectGetWidth(self.containerView.frame);
            childToAdd.view.frame = frame;
            
            [self.containerView addSubview:childToAdd.view];
        }
    }
    
    NSLog(@"Number of child view controllers: %lu", self.childViewControllers.count);
}


@end
