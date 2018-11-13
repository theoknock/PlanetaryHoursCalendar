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

#import "DateTimePickerViewController.h"

@interface RootViewController : UIViewController <UIPageViewControllerDelegate, MKMapViewDelegate, DateTimePickerViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
- (void)datePickerDidChange:(NSDate *)date;
- (void)timePickerDidChange:(NSTimeInterval)time;
- (NSDate *)pickerDate;
- (NSTimeInterval)pickerTime;

@end

