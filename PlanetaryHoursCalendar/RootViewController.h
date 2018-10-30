//
//  RootViewController.h
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 10/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface RootViewController : UIViewController <UIPageViewControllerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

