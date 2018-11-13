//
//  RootViewController.m
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 10/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "RootViewController.h"
#import "ModelController.h"
#import "DataViewController.h"
#import "PlanetaryHourDataSource.h"
#import "FESSolarCalculator.h"
#import "MKPointAnnotation+MKPointAnnotation_DispatchTimer.h"

@interface RootViewController ()
{
    MKUserLocation *lastUserLocation;
}

@property (readonly, strong, nonatomic) ModelController *modelController;

@end

@implementation RootViewController

@synthesize modelController = _modelController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    MKUserTrackingButton *button = [MKUserTrackingButton userTrackingButtonWithMapView:self.mapView];
//    [button.layer setBorderWidth:1.0];
//    [button.layer setCornerRadius:5.0];
//    [button setTranslatesAutoresizingMaskIntoConstraints:FALSE];
//    
//    [self.mapView addSubview:button];
//    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
//
//    [NSLayoutConstraint activateConstraints:@[[button.bottomAnchor constraintEqualToAnchor:self.mapView.bottomAnchor constant:-10.0],
//                                              [button.trailingAnchor constraintEqualToAnchor:self.mapView.trailingAnchor constant:-10.0]]];
    
//    CLLocation *userCoordinate = [[CLLocation alloc] initWithLatitude:PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate.latitude longitude:PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate.longitude];

    [PlanetaryHourDataSource.sharedDataSource calendarPlanetaryHoursForDate:[NSDate date] location:nil completionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
            self.pageViewController.delegate = self;

            DataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
            NSArray *viewControllers = @[startingViewController];
            [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            self.pageViewController.dataSource = self.modelController;

            [self addChild:self.pageViewController withChildToRemove:nil];
            [self.pageViewController didMoveToParentViewController:self];
        });
    }];

//    DateTimePickerViewController *dtvc = []
    
//    timeChangeNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"UIApplicationSignificantTimeChangeNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
//        [self calendarPlanetaryHour];
//    }];
}

- (void)addChild:(UIViewController *)childToAdd withChildToRemove:(UIViewController *)childToRemove
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (childToRemove != nil)
    {
        [childToRemove.view removeFromSuperview];
        [childToRemove removeFromParentViewController];
    }
    
    if (childToAdd != nil)
    {
        [self addChildViewController:childToAdd];
        [childToAdd didMoveToParentViewController:self];
        
        CGRect pageViewRect = self.containerView.bounds;
        childToAdd.view.frame = pageViewRect;
        if ([childToAdd isKindOfClass:[UIPageViewController class]]) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                pageViewRect = CGRectInset(pageViewRect, 40.0, 0.0);
            }
        }
        [self.containerView addSubview:childToAdd.view];
    }
}

- (ModelController *)modelController {
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[ModelController alloc] init];
    }
    return _modelController;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    if (![overlay isKindOfClass:[MKGeodesicPolyline class]]) {
        return nil;
    }
    
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
    renderer.lineWidth = 3.0f;
    renderer.strokeColor = [UIColor blueColor];
    renderer.alpha = 0.5;
    
    return renderer;
}

- (IBAction)elapseTime:(UISlider *)sender {
    dispatch_async(PlanetaryHourDataSource.sharedDataSource.planetaryHourDataRequestQueue, ^{
        [self.mapView.annotations enumerateObjectsUsingBlock:^(id<MKAnnotation>  _Nonnull planetaryHourAnnotation, NSUInteger hour, BOOL * _Nonnull stop) {
            if ([planetaryHourAnnotation isKindOfClass:[MKPointAnnotation class]] && [planetaryHourAnnotation respondsToSelector:@selector(sunriseLocation)])
            {
                MKMapPoint planetary_hour_origin = MKMapPointForCoordinate(((MKPointAnnotation *)planetaryHourAnnotation).sunriseLocation.coordinate);
                planetary_hour_origin = MKMapPointMake(planetary_hour_origin.x - (sender.value * earth_rotation_mps()), planetary_hour_origin.y);
                CLLocationCoordinate2D offset_start_coordinate = MKCoordinateForMapPoint(planetary_hour_origin);
                [planetaryHourAnnotation setCoordinate:offset_start_coordinate];
            }
        }];
    });
}


static NSDateIntervalFormatter *dateIntervalFormatter = NULL;
- (NSDateIntervalFormatter *)dateIntervalFormatter
{
    NSDateIntervalFormatter *dif = dateIntervalFormatter;
    if (!dateIntervalFormatter)
    {
        dif = [[NSDateIntervalFormatter alloc] init];
        [dif setDateStyle:NSDateIntervalFormatterNoStyle];
        [dif setTimeStyle:NSDateIntervalFormatterMediumStyle];
        
        dateIntervalFormatter = dif;
    }
    
    return dif;
}
double(^earth_rotation_mps)(void) = ^(void) {
    return MKMapSizeWorld.width / SECONDS_PER_DAY;
};

CLLocation *(^sunriseLocationForPlanetaryHour)(CLLocation * _Nullable, NSDate * _Nullable, NSUInteger) = ^(CLLocation * _Nullable location, NSDate * _Nullable date, NSUInteger hour) {
    if (!date) date = [NSDate date];
    hour = hour % HOURS_PER_DAY;
    FESSolarCalculator *solarCalculator   = [[FESSolarCalculator alloc] initWithDate:date location:location];
//    if (timeOffset == 0)
//        timeOffset = [date timeIntervalSinceDate:solarCalculator.sunrise];
    NSTimeInterval seconds_in_day         = [solarCalculator.sunset timeIntervalSinceDate:solarCalculator.sunrise];
    NSTimeInterval seconds_in_night       = SECONDS_PER_DAY - seconds_in_day;
    double meters_per_day                 = seconds_in_day   * earth_rotation_mps();
    double meters_per_night               = seconds_in_night * earth_rotation_mps();
    double meters_per_day_per_hour        = meters_per_day / HOURS_PER_SOLAR_TRANSIT;
    double meters_per_night_per_hour      = meters_per_night / HOURS_PER_SOLAR_TRANSIT;
    MKMapPoint user_location_point = MKMapPointForCoordinate(location.coordinate);
    MKMapPoint planetary_hour_origin = MKMapPointMake((hour < HOURS_PER_SOLAR_TRANSIT)
                                                      ? user_location_point.x + (meters_per_day_per_hour * hour)
                                                      : user_location_point.x + (meters_per_day + (meters_per_night_per_hour * (hour % 12))), user_location_point.y);
    CLLocationCoordinate2D start_coordinate = MKCoordinateForMapPoint(planetary_hour_origin);
    CLLocation *sunriseLocation = [[CLLocation alloc] initWithLatitude:start_coordinate.latitude longitude:start_coordinate.longitude];
    
    return sunriseLocation;
};

void(^addPlanetaryHourAnnotation)(NSInteger, NSString *, NSString *, CLLocation *, MKMapView *) = ^(NSInteger hour, NSString *title, NSString *subtitle, CLLocation *location, MKMapView *mapView)
{
    MKPointAnnotation *planetaryHourAnnotation = [[MKPointAnnotation alloc] init];
    planetaryHourAnnotation.title = title;
    planetaryHourAnnotation.subtitle = subtitle;
    [planetaryHourAnnotation setPlanetaryHour:[NSNumber numberWithInteger:hour]];
    [planetaryHourAnnotation setSunriseLocation:sunriseLocationForPlanetaryHour(location, nil, hour)];
    [planetaryHourAnnotation setCoordinate:planetaryHourAnnotation.sunriseLocation.coordinate];
    
    [mapView addAnnotation:planetaryHourAnnotation];
    
//    [planetaryHourAnnotation setTimer:dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, PlanetaryHourDataSource.sharedDataSource.planetaryHourDataRequestQueue)];
//    dispatch_source_set_timer(planetaryHourAnnotation.timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, DISPATCH_TIMER_STRICT);
//    dispatch_source_set_event_handler(planetaryHourAnnotation.timer, ^{
//        [[mapView viewForAnnotation:planetaryHourAnnotation] setHidden:TRUE];
//        [(MKMarkerAnnotationView *)[mapView viewForAnnotation:planetaryHourAnnotation] setGlyphText:[title substringWithRange:NSMakeRange(0, 1)]];
//        [(MKMarkerAnnotationView *)[mapView viewForAnnotation:planetaryHourAnnotation] setMarkerTintColor:(hour < HOURS_PER_SOLAR_TRANSIT) ? [UIColor yellowColor] : [UIColor blueColor]];
//        [(MKMarkerAnnotationView *)[mapView viewForAnnotation:planetaryHourAnnotation] setGlyphTintColor:(hour < HOURS_PER_SOLAR_TRANSIT) ? [UIColor orangeColor] : [UIColor whiteColor]];
//        
//        elapsedTimeCounter = (elapsedTimeCounter < 86400.0) ? elapsedTimeCounter + ((86400.0 / 60.0) / 60.0) : 0.0;
//        [planetaryHourAnnotation setCoordinate:planetaryHourLocation(location, nil, elapsedTimeCounter, hour)];
//        
//        [[mapView viewForAnnotation:planetaryHourAnnotation] prepareForDisplay];
//        [[mapView viewForAnnotation:planetaryHourAnnotation] setHidden:FALSE];
//        if ([mapView.selectedAnnotations containsObject:planetaryHourAnnotation] && mapView.selectedAnnotations.count == 1.)
//        {
////            if (!MKMapRectContainsPoint(mapView.visibleMapRect, MKMapPointForCoordinate(planetaryHourAnnotation.coordinate)))
//            [mapView setCenterCoordinate:planetaryHourAnnotation.coordinate animated:TRUE];
//        }
//    });
//    dispatch_resume(planetaryHourAnnotation.timer);
};

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
//    [mapView.selectedAnnotations enumerateObjectsUsingBlock:^(id<MKAnnotation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (![view isEqual:[mapView viewForAnnotation:obj]])
//            [mapView deselectAnnotation:obj animated:FALSE];
//        }];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
//    [mapView.annotations enumerateObjectsUsingBlock:^(id<MKAnnotation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([view isEqual:[mapView viewForAnnotation:obj]])
//            [mapView deselectAnnotation:obj animated:FALSE];
//    }];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (![lastUserLocation isEqual:userLocation])
    {
        [mapView removeAnnotations:[mapView annotations]];
        [self.modelController.events enumerateObjectsUsingBlock:^(EKEvent * _Nonnull event, NSUInteger hour, BOOL * _Nonnull stop) {
            addPlanetaryHourAnnotation(hour, event.title, event.notes, userLocation.location, mapView);
        }];
        lastUserLocation = userLocation;
    }
}

// MKMapViewDefaultAnnotationViewReuseIdentifier

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKMarkerAnnotationView *markerAnnotationView = [[MKMarkerAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MKMapViewDefaultAnnotationViewReuseIdentifier];
    [markerAnnotationView setDisplayPriority:MKFeatureDisplayPriorityRequired];
    [markerAnnotationView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [markerAnnotationView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [markerAnnotationView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [markerAnnotationView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]] && [annotation respondsToSelector:@selector(planetaryHour)])
    {
        [markerAnnotationView setGlyphText:[annotation.title substringWithRange:NSMakeRange(0, 1)]];
        [markerAnnotationView setMarkerTintColor:(((MKPointAnnotation *)annotation).planetaryHour.integerValue < HOURS_PER_SOLAR_TRANSIT) ? [UIColor yellowColor] : [UIColor blueColor]];
        [markerAnnotationView setGlyphTintColor:(((MKPointAnnotation *)annotation).planetaryHour.integerValue < HOURS_PER_SOLAR_TRANSIT) ? [UIColor orangeColor] : [UIColor whiteColor]];
    }
    
    return markerAnnotationView;
}

//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
//{
//    if (![overlay isKindOfClass:[MKPolyline class]]) {
//        return nil;
//    }
//
//    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
//    renderer.lineWidth = 1.0f;
//    renderer.strokeColor = [UIColor blueColor];
//    renderer.alpha = 0.5;
//
//    return renderer;
//}

#pragma mark - UIPageViewController delegate methods

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(orientation) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        
        UIViewController *currentViewController = self.pageViewController.viewControllers[0];
        NSArray *viewControllers = @[currentViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }
    
    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
    DataViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = nil;
    
    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
        viewControllers = @[currentViewController, nextViewController];
    } else {
        UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
        viewControllers = @[previousViewController, currentViewController];
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    
    return UIPageViewControllerSpineLocationMid;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<DataViewController *> *)pendingViewControllers
{
    [pendingViewControllers enumerateObjectsUsingBlock:^(DataViewController * _Nonnull dataViewController, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger index = [self.modelController indexOfViewController:dataViewController];
        [self.mapView.annotations enumerateObjectsUsingBlock:^(id<MKAnnotation>  _Nonnull annotation, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([annotation isKindOfClass:[MKPointAnnotation class]] && [annotation respondsToSelector:@selector(planetaryHour)])
            {
                if ([(MKPointAnnotation *)annotation planetaryHour].unsignedIntegerValue == index) {
                    [self.mapView.selectedAnnotations enumerateObjectsUsingBlock:^(id<MKAnnotation>  _Nonnull selectedAnnotation, NSUInteger idx, BOOL * _Nonnull stop) {
                        [self.mapView deselectAnnotation:selectedAnnotation animated:FALSE];
                    }];
                    [self.mapView setRegion:MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(10.0001, 10.0001))];
                    [self.mapView selectAnnotation:annotation animated:FALSE];
                    *stop = TRUE;
                }
            }
        }];
    }];
}

@end

