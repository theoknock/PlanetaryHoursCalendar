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

@interface RootViewController ()
{
    MKGeodesicPolyline *planetaryHoursPolyline;
    NSUInteger planetaryHourAnnotationPosition;
    CATextLayer *planetaryHourSymbolTextLayer;
}

@property (readonly, strong, nonatomic) ModelController *modelController;
@end

@implementation RootViewController

@synthesize modelController = _modelController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [PlanetaryHourDataSource.sharedDataSource calendarPlanetaryHoursForDate:nil location:nil completionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
            self.pageViewController.delegate = self;
            
            DataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
            NSArray *viewControllers = @[startingViewController];
            [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            
            self.pageViewController.dataSource = self.modelController;
            
            [self addChild:self.pageViewController withChildToRemove:nil];
            
            [self.pageViewController didMoveToParentViewController:self];
            
            [self.mapView setRegion:MKCoordinateRegionMake(PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate, MKCoordinateSpanMake(0.01, 0.01)) animated:TRUE];
            
//            [self.mapView setPitchEnabled:TRUE];
//            MKMapCamera *mapCamera = [MKMapCamera cameraLookingAtCenterCoordinate:PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate fromDistance:(CLLocationDistance)500.0 pitch:45.0 heading:(CLLocationDirection)0.0];
//            [self.mapView setCamera:mapCamera animated:TRUE];
//            [self addPlanetaryHourAnnotations];
            [self positionPlanetaryHourAnnotations];
        });
    }];
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

//- (void)addPlanetaryHourAnnotations
//{
//    FESSolarCalculator *solarCalculator = [[FESSolarCalculator alloc] initWithDate:[NSDate date] location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
//    NSTimeInterval daySpan   = [solarCalculator.sunset timeIntervalSinceDate:solarCalculator.sunrise];
//    NSTimeInterval nightSpan = 86400.0f - daySpan;
//    NSTimeInterval dayPercentage   = daySpan   / 86400.0f;
//    NSTimeInterval nightPercentage = nightSpan / 86400.0f;
//    double mapSizeWorldWidthForDay   = MKMapSizeWorld.width * dayPercentage;
//    double mapSizeWorldWidthForNight = MKMapSizeWorld.width * nightPercentage;
//    double width_per_day_hour   = mapSizeWorldWidthForDay / 12.0;
//    double width_per_night_hour = mapSizeWorldWidthForNight / 12.0;
//    __block MKMapPoint coordinatesAtPoint = MKMapPointForCoordinate(PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate);
//    Planet planetForDay = PlanetaryHourDataSource.sharedDataSource.pd([NSDate date]);
//    [self.modelController.events enumerateObjectsUsingBlock:^(EKEvent * _Nonnull obj, NSUInteger hour, BOOL * _Nonnull stop) {
//        coordinatesAtPoint = MKMapPointMake((hour == 0) ? coordinatesAtPoint.x : (hour < 12) ? coordinatesAtPoint.x + width_per_day_hour : coordinatesAtPoint.x + width_per_night_hour, coordinatesAtPoint.y);
//        CLLocationCoordinate2D newCoordinates = MKCoordinateForMapPoint(coordinatesAtPoint);
//        MKPointAnnotation *planetaryHourAnnotation = [[MKPointAnnotation alloc] init];
//        planetaryHourAnnotation.title = PlanetaryHourDataSource.sharedDataSource.planetSymbolForPlanet(planetForDay + hour);
//        planetaryHourAnnotation.subtitle = [NSString stringWithFormat:@"Hour %lu", hour + 1];
//        planetaryHourAnnotation.coordinate = newCoordinates;
//        [self.mapView addAnnotation:planetaryHourAnnotation];
//    }];
//
//    [self repositionPlanetaryHourAnnotations];
//}
//
//- (void)repositionPlanetaryHourAnnotations
//{
//    FESSolarCalculator *solarCalculator = [[FESSolarCalculator alloc] initWithDate:[NSDate date] location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
//    NSTimeInterval daySpan   = [solarCalculator.sunset timeIntervalSinceDate:solarCalculator.sunrise];
//    NSTimeInterval nightSpan = 86400.0f - daySpan;
//    NSTimeInterval dayPercentage   = daySpan   / 86400.0f;
//    NSTimeInterval nightPercentage = nightSpan / 86400.0f;
//    double mapSizeWorldWidthForDay   = MKMapSizeWorld.width * dayPercentage;
//    double mapSizeWorldWidthForNight = MKMapSizeWorld.width * nightPercentage;
//    double width_per_day_hour   = mapSizeWorldWidthForDay / 12.0;
//    double width_per_night_hour = mapSizeWorldWidthForNight / 12.0;
//    double step_per_day_hour_second = (width_per_day_hour / 60.0) / 60.0;
//    double step_per_night_hour_second = (width_per_night_hour / 60.0) / 60.0;
//    for (MKPointAnnotation *annotation in self.mapView.annotations)
//    {
//        [[self.mapView viewForAnnotation:annotation] setHidden:TRUE];
//        MKMapPoint coordinatesAtPoint = MKMapPointForCoordinate(annotation.coordinate);
//        NSUInteger index = [self.mapView.annotations indexOfObject:annotation];
//        coordinatesAtPoint = MKMapPointMake((index < 12) ? coordinatesAtPoint.x - step_per_day_hour_second : coordinatesAtPoint.x - step_per_night_hour_second, coordinatesAtPoint.y);
//        CLLocationCoordinate2D newCoordinates = MKCoordinateForMapPoint(coordinatesAtPoint);
//        annotation.coordinate = newCoordinates;
//        [[self.mapView viewForAnnotation:annotation] setHidden:FALSE];
//        [self.mapView.selectedAnnotations indexOfObjectPassingTest:^BOOL(id<MKAnnotation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [self.mapView setRegion:MKCoordinateRegionMake(obj.coordinate, self.mapView.region.span) animated:TRUE];
//            *stop = TRUE;
//            return stop;
//        }];
//    }
//
//    [self performSelector:@selector(repositionPlanetaryHourAnnotations) withObject:nil afterDelay:1.0];
//}

void(^addPlanetaryHourAnnotation)(NSString *, NSString *, CLLocationCoordinate2D, CLLocationCoordinate2D, CLLocationCoordinate2D, MKMapView *) = ^(NSString *title, NSString *subtitle, CLLocationCoordinate2D coordinate, CLLocationCoordinate2D start_coordinate, CLLocationCoordinate2D end_coordinate, MKMapView *mapView)
{
    MKPointAnnotation *planetaryHourAnnotation = [[MKPointAnnotation alloc] init];
    planetaryHourAnnotation.title = title;
    planetaryHourAnnotation.subtitle = subtitle;
    planetaryHourAnnotation.coordinate = coordinate;
    [mapView addAnnotation:planetaryHourAnnotation];
    
    CLLocationCoordinate2D coordinates[2] = {start_coordinate, end_coordinate};
    MKGeodesicPolyline *planetaryHourTravelLine = [MKGeodesicPolyline polylineWithCoordinates:coordinates count:2];
    [mapView addOverlay:planetaryHourTravelLine];
    
};

void(^positionPlanetaryHourAnnotation)(NSUInteger , CLLocationCoordinate2D, MKMapView *) = ^(NSUInteger index, CLLocationCoordinate2D coordinate, MKMapView *mapView)
{
    [UIView animateWithDuration:1.0 animations:^{
        [[mapView viewForAnnotation:mapView.annotations[index]] setHidden:TRUE];
        mapView.annotations[index].coordinate = coordinate;
        [[mapView viewForAnnotation:mapView.annotations[index]] setHidden:FALSE];
    } completion:^(BOOL finished) {
        [mapView.selectedAnnotations indexOfObjectPassingTest:^BOOL(id<MKAnnotation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mapView setRegion:MKCoordinateRegionMake(obj.coordinate, mapView.region.span) animated:TRUE];
            *stop = TRUE;
            return stop;
        }];
    }];
};

- (void)positionPlanetaryHourAnnotations
{
    FESSolarCalculator *solarCalculator = [[FESSolarCalculator alloc] initWithDate:[NSDate date] location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
    NSTimeInterval daySpan   = [solarCalculator.sunset timeIntervalSinceDate:solarCalculator.sunrise];
    NSTimeInterval nightSpan = 86400.0f - daySpan;
    NSTimeInterval dayPercentage   = daySpan   / 86400.0f;
    NSTimeInterval nightPercentage = nightSpan / 86400.0f;
    double mapSizeWorldWidthForDay   = MKMapSizeWorld.width * dayPercentage;
    double mapSizeWorldWidthForNight = MKMapSizeWorld.width * nightPercentage;
    double width_per_day_hour   = mapSizeWorldWidthForDay / 12.0;
    double width_per_night_hour = mapSizeWorldWidthForNight / 12.0;
    double steps_per_day_hour_second = (width_per_day_hour / 60.0) / 60.0;
    double steps_per_night_hour_second = (width_per_night_hour / 60.0) / 60.0;
    __block MKMapPoint start_point = MKMapPointForCoordinate(PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate);
    [self.modelController.events enumerateObjectsUsingBlock:^(EKEvent * _Nonnull obj, NSUInteger hour, BOOL * _Nonnull stop) {
        MKMapPoint end_point = MKMapPointMake((hour == 0) ? start_point.x : (hour < 12) ? start_point.x + width_per_day_hour : start_point.x + width_per_night_hour, start_point.y);
        NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:solarCalculator.sunrise];
        double day_steps   = steps_per_day_hour_second   * elapsedTime;
        double night_steps = steps_per_night_hour_second * elapsedTime;
        MKMapPoint currentPoint = MKMapPointMake((hour < 12) ? end_point.x - day_steps : end_point.x - night_steps, end_point.y);
        CLLocationCoordinate2D planetaryHourCoordinate = MKCoordinateForMapPoint(currentPoint);
        __weak typeof(MKMapView *) w_mapView = self.mapView;
        @try {
            if (nil != self.mapView.annotations[hour])
                positionPlanetaryHourAnnotation(hour, planetaryHourCoordinate, w_mapView);
        } @catch (NSException *exception) {
            addPlanetaryHourAnnotation(PlanetaryHourDataSource.sharedDataSource.planetSymbolForPlanet(PlanetaryHourDataSource.sharedDataSource.pd([NSDate date]) + hour), [NSString stringWithFormat:@"Hour %lu", hour + 1], planetaryHourCoordinate, MKCoordinateForMapPoint(start_point), MKCoordinateForMapPoint(end_point), w_mapView);
        } @finally {
            start_point = end_point;
        }
        
    }];
    
    [self performSelector:@selector(positionPlanetaryHourAnnotations) withObject:0 afterDelay:1.0];
}

// MKMapViewDefaultAnnotationViewReuseIdentifier

//- (void)repositionPlanetaryHourAnnotationsUsingDistance:(NSNumber *)earth_circumference {
//    // distance / (86400.0 seconds per day / 24.0 distances)
//
////    FESSolarCalculator *solarCalculator = [[FESSolarCalculator alloc] initWithDate:[NSDate date] location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
////    NSTimeInterval daySpan = [solarCalculator.sunset timeIntervalSinceDate:solarCalculator.sunrise];
////    NSArray<NSNumber *> *hourDurations = PlanetaryHourDataSource.sharedDataSource.hd(daySpan);
////
//    double meters_per_planetary_hour_day = ((earth_circumference.doubleValue * 0.5) * hourDurationRatios()[0].doubleValue) / 12.0;
//    double meters_per_planetary_hour_night = ((earth_circumference.doubleValue * 0.5) * hourDurationRatios()[1].doubleValue) / 12.0;
//
//    FESSolarCalculator *solarCalculator = [[FESSolarCalculator alloc] initWithDate:[NSDate date] location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
//    NSTimeInterval daySpan = [solarCalculator.sunset timeIntervalSinceDate:solarCalculator.sunrise];
//    NSArray<NSNumber *> *hourDurations = PlanetaryHourDataSource.sharedDataSource.hd(daySpan);
//    double steps_per_planetary_hour_day = meters_per_planetary_hour_day / hourDurations[0].doubleValue;
//    double steps_per_planetary_hour_night = meters_per_planetary_hour_night / hourDurations[1].doubleValue;// meters_per_planetary_hour_night / ((86400.0f * hourDurationRatios()[0].doubleValue) / (hourDurationRatios()[1].doubleValue * 12.0));
//    NSLog(@"steps per day\t%f\t\tsteps per night\t%f", steps_per_planetary_hour_day, steps_per_planetary_hour_night);
////    CLLocationCoordinate2D coordinates[24];
//    __block NSUInteger index = 0;
//    Planet planetForDay = PlanetaryHourDataSource.sharedDataSource.pd([NSDate date]);
//
//    NSArray<MKPointAnnotation *> *annotations = [self.mapView annotations];//annotationsInMapRect:annotationsRect] copy];
//
//    [CATransaction begin];
//        [self.mapView removeAnnotations:[self.mapView annotations]];
//    [CATransaction setCompletionBlock:^{
//        [CATransaction begin];
//            [CATransaction setCompletionBlock:^{
//                [self.mapView addAnnotations:annotations];
//            }];
//            for (MKPointAnnotation *obj in annotations)
//            {
//                // To-do: Calculate coordinates based on elapsed time since last update
//                //        (so that annotations can be repositioned when region changes)
//                double step = (index < 12) ? steps_per_planetary_hour_day : steps_per_planetary_hour_night;
//                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(obj.coordinate.latitude, obj.coordinate.longitude);
//                [obj setCoordinate:[self translateCoord:coordinate MetersLat:0 MetersLong:step]];
//                [obj setTitle:PlanetaryHourDataSource.sharedDataSource.ps(planetForDay + index)];
//                index++;
//            }
//        [CATransaction commit];
//    }];
//    [CATransaction commit];
//    [self performSelector:@selector(repositionPlanetaryHourAnnotationsUsingDistance:) withObject:earth_circumference afterDelay:1.0];
//}

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

- (void)addChild:(UIViewController *)childToAdd withChildToRemove:(UIViewController *)childToRemove
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (childToRemove != nil)
    {
        if ([childToRemove isKindOfClass:[UIPageViewController class]]) {
            [childToRemove.view removeFromSuperview];
            [childToRemove removeFromParentViewController];
        }
    }
    
    if (childToAdd != nil)
    {
        [self addChildViewController:childToAdd];
        [childToAdd didMoveToParentViewController:self];
        
        if ([childToAdd isKindOfClass:[UIPageViewController class]]) {
            
            CGRect pageViewRect = self.containerView.bounds;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                pageViewRect = CGRectInset(pageViewRect, 40.0, 0.0);
            }
            childToAdd.view.frame = pageViewRect;
            
            [self.containerView addSubview:childToAdd.view];
        }
    }
    
    NSLog(@"Number of child view controllers: %lu", self.childViewControllers.count);
}


- (ModelController *)modelController {
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[ModelController alloc] init];
    }
    return _modelController;
}


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
//        [self positionPlanetaryHourAnnotations:index];
        //        NSUInteger annotationIndex = [self.mapView.annotations indexOfObjectPassingTest:^BOOL(id<MKAnnotation>  _Nonnull annotation, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSLog(@"idx\t%lu", idx);
//            return ([annotation.subtitle isEqualToString:[NSString stringWithFormat:@"Hour %lu", index + 1]]);
//        }];
//        NSLog(@"index\t%lu\t\tannotationIndex\t%lu", index, annotationIndex);
//        if (annotationIndex < self.mapView.annotations.count)
//        {
//
//        }
    }];
}

@end
