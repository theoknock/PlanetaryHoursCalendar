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
#import "PlanetaryHourAnnotations.h"

static void *PlanetaryHourAnnotationContext = &PlanetaryHourAnnotationContext;

@interface RootViewController ()
{
    MKUserLocation *lastUserLocation;
    dispatch_source_t coordinateUpdateTimer;
    dispatch_queue_t coordinateUpdateQueue;
    __block NSDate *lastDatePickerDate;
    SnappingSlider *snappingSlider;
}

@property (readonly, strong, nonatomic) ModelController *modelController;

@end

@implementation RootViewController

@synthesize modelController = _modelController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect snappingSlider_frame = CGRectMake(0.0, 0.0, self.mapView.bounds.size.width * 0.5, 50.0);
    snappingSlider = [[SnappingSlider alloc] initWithFrame:snappingSlider_frame title:@"Slider"];
    snappingSlider.delegate = self;
    CGPoint snappingSlider_center = CGPointMake(self.mapView.bounds.size.width * 0.5, self.mapView.bounds.size.height * 0.5);
    snappingSlider.center = snappingSlider_center;
    [snappingSlider setShouldContinueAlteringValueUntilGestureCancels:TRUE];
    [self.mapView addSubview:snappingSlider];
    
//    [self.datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventAllEvents];
    [self.datePicker setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.33]];
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
}

- (void)snappingSliderDidIncrementValue:(SnappingSlider *)snapSwitch
{
    [self.datePicker setDate:[self.datePicker.date dateByAddingTimeInterval:60 * 60]];
    NSEnumerator *enumerator = [self.mapView.annotations objectEnumerator];
    id<MKAnnotation> annotation;
    while ((annotation = [enumerator nextObject])) {
        if ([annotation isKindOfClass:[MKPointAnnotation class]] && [annotation respondsToSelector:@selector(updateLocationBlock)])
        {
            [(MKPointAnnotation *)annotation setCoordinate:((MKPointAnnotation *)annotation).updateLocationBlock(self.datePicker.date)];
        }
    }
}

- (void)snappingSliderDidDecrementValue:(SnappingSlider *)snapSwitch
{
    [self.datePicker setDate:[self.datePicker.date dateByAddingTimeInterval:-60 * 60]];
    NSEnumerator *enumerator = [self.mapView.annotations objectEnumerator];
    id<MKAnnotation> annotation;
    while ((annotation = [enumerator nextObject])) {
        if ([annotation isKindOfClass:[MKPointAnnotation class]] && [annotation respondsToSelector:@selector(updateLocationBlock)])
        {
            [(MKPointAnnotation *)annotation setCoordinate:((MKPointAnnotation *)annotation).updateLocationBlock(self.datePicker.date)];
        }
    }
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

//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
//{
//    if (![overlay isKindOfClass:[MKPolyline class]]) {
//        return nil;
//    }
//    
//    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
//    renderer.lineWidth = 3.0f;
//    renderer.strokeColor = [UIColor blueColor];
//    renderer.alpha = 0.5;
//    
//    return renderer;
//}



//typedef void(^PlanetaryHourAnnotationOriginCompletionBlock)(CLLocation *sunriseLocation, NSDate *sunriseDate);
//void(^planetaryHourAnnotationOrigin)(MKPointAnnotation *, CLLocation *, NSDate *, PlanetaryHourAnnotationOriginCompletionBlock) = ^(MKPointAnnotation *planetaryHourAnnotation, CLLocation *location, NSDate *date, PlanetaryHourAnnotationOriginCompletionBlock planetaryHourAnnotationOriginCompletionBlock) {
//    if ([planetaryHourAnnotation isKindOfClass:[MKPointAnnotation class]] && [planetaryHourAnnotation respondsToSelector:@selector(sunriseLocation)] && [planetaryHourAnnotation respondsToSelector:@selector(solarCalculation)])
//    {
////        NSTimeInterval elapsedTime = [date timeIntervalSinceDate:((MKPointAnnotation *)planetaryHourAnnotation).solarCalculation.sunrise];
////        if ((elapsedTime < 0 || elapsedTime > SECONDS_PER_DAY))
////        {
////            NSDate *earlierDate = [((MKPointAnnotation *)planetaryHourAnnotation).solarCalculation.sunrise earlierDate:date];
////            if ([earlierDate isEqualToDate:date] && elapsedTime > -SECONDS_PER_DAY)
////            {
////                NSLog(@"Subtracting one day from specified date...");
////                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
////                NSDateComponents *components = [[NSDateComponents alloc] init];
////                components.day = -1;
////                date = [calendar dateByAddingComponents:components toDate:date options:NSCalendarMatchNextTimePreservingSmallerUnits];
////            }
////            NSLog(@"Setting new sunrise date...");
//            [(MKPointAnnotation *)planetaryHourAnnotation setSunriseLocation:sunriseLocationForPlanetaryHour(location, date, ((MKPointAnnotation *)planetaryHourAnnotation).planetaryHour.doubleValue)];
//            [(MKPointAnnotation *)planetaryHourAnnotation setSolarCalculation:[[FESSolarCalculator alloc] initWithDate:date location:((MKPointAnnotation *)planetaryHourAnnotation).sunriseLocation]];
////        } else {
////            NSLog(@"Using stored sunrise date...");
////        }
//        planetaryHourAnnotationOriginCompletionBlock(((MKPointAnnotation *)planetaryHourAnnotation).sunriseLocation, ((MKPointAnnotation *)planetaryHourAnnotation).solarCalculation.sunrise);
//    }
//};

//- (IBAction)changeDate:(UIDatePicker *)sender {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    dispatch_async(PlanetaryHourDataSource.sharedDataSource.planetaryHourDataRequestQueue, ^{
//        [self.mapView.annotations enumerateObjectsUsingBlock:^(id<MKAnnotation>  _Nonnull planetaryHourAnnotation, NSUInteger hour, BOOL * _Nonnull stop) {
//            if ([planetaryHourAnnotation isKindOfClass:[MKPointAnnotation class]] && [planetaryHourAnnotation respondsToSelector:@selector(sunriseLocation)] && [planetaryHourAnnotation respondsToSelector:@selector(solarCalculation)])
//            {
////                positionPlanetaryHourAnnotation(sender.date, (MKPointAnnotation *)planetaryHourAnnotation);
//            }
//        }];
//    });
//}

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
                
// draw polyline here
//MKMapPoint planetaryHourMapPoint = MKMapPointForCoordinate(planetaryHourAnnotation.coordinate);
//MKMapPoint userLocation = MKMapPointForCoordinate(mapView.userLocation.location.coordinate);
//MKMapPoint top = MKMapPointMake(planetaryHourMapPoint.x, 0.f);
//MKMapPoint bottom = MKMapPointMake(planetaryHourMapPoint.x, MKMapSizeWorld.height);
//MKMapPoint* pointArray = malloc(sizeof(MKMapPoint) * 2);
//pointArray[0] = planetaryHourMapPoint;
//pointArray[1] = userLocation;
//
//MKPolyline *polyline = [MKPolyline polylineWithPoints:pointArray count:2];
//[mapView addOverlay:polyline];

void(^addPlanetaryHourAnnotation)(NSDate *, NSInteger, NSString *, NSString *, CLLocation *, MKMapView *) = ^(NSDate *date, NSInteger hour, NSString *title, NSString *subtitle, CLLocation *location, MKMapView *mapView)
{
    MKPointAnnotation *planetaryHourAnnotation = [[MKPointAnnotation alloc] initWithPlanetaryHour:hour];
    planetaryHourAnnotation.title = title;
    planetaryHourAnnotation.subtitle = subtitle;
    
    [mapView addAnnotation:planetaryHourAnnotation];
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
//    if (![lastUserLocation isEqual:userLocation])
//    {
//        [mapView removeAnnotations:[mapView annotations]];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [mapView addAnnotations:[PlanetaryHourAnnotations annotationsForLocation:userLocation.location]];
        [PlanetaryHourDataSource.sharedDataSource calendarPlanetaryHoursForDate:[NSDate date] location:userLocation.location completionBlock:^{
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
//        [self.modelController.events enumerateObjectsUsingBlock:^(EKEvent * _Nonnull event, NSUInteger hour, BOOL * _Nonnull stop) {
//            addPlanetaryHourAnnotation([NSDate date], hour, event.title, event.notes, userLocation.location, mapView);
//        }];
    });
//        lastUserLocation = userLocation;
//    }
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
//        positionPlanetaryHourAnnotation(self.datePicker.date, annotation);
//        NSLog(@"self.datePicker.date == %@", self.datePicker.date.description);
    }
    
    return markerAnnotationView;
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

