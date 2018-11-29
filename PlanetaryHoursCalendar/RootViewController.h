//
//  RootViewController.h
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 10/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "SnappingSlider.h"

@interface RootViewController : UIViewController <UIPageViewControllerDelegate, MKMapViewDelegate, SnappingSliderDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

