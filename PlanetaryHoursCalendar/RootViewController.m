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
    // Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    
    [PlanetaryHourDataSource.sharedDataSource calendarPlanetaryHoursForDate:nil location:nil completionBlock:^{
    
    }];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;

    DataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    self.pageViewController.dataSource = self.modelController;

    [self addChild:self.pageViewController withChildToRemove:nil];

    [self.pageViewController didMoveToParentViewController:self];
    
    // Planetary-hour polylines for map view
    double a = 6371000.0f;
    double b = 6356800.0f;
    double a_sqr = pow(a, 2.0f);
    double b_sqr = pow(b, 2.0f);
    double geodetic_latitude = degreesToRadians(PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate.latitude);
    double top_left = pow(a_sqr * cos(geodetic_latitude), 2.0f);
    double top_right = pow(b_sqr * sin(geodetic_latitude), 2.0f);
    double bottom_left = pow(a * cos(geodetic_latitude), 2.0f);
    double bottom_right = pow(b * sin(geodetic_latitude), 2.0f);
    double geocentric_radius = sqrt((top_left + top_right) / (bottom_left + bottom_right));
    
    double earth_circumference = (2.0f * M_PI) * cos(geodetic_latitude) * geocentric_radius;
    // TO-DO: Adjust per duration of planetary hour
//    __block double meters_per_planetary_hour = earth_circumference / 24.0;
    double meters_per_planetary_hour_day = ((earth_circumference * 0.5) * hourDurationRatios()[0].doubleValue) / 12.0;
    double meters_per_planetary_hour_night = ((earth_circumference * 0.5) * hourDurationRatios()[1].doubleValue) / 12.0;
    //    const double meters_per_planetary_hour_longitude = (meters_per_degree * 24.0);
//    const double meters_per_planetary_hour_longitude = (meters_per_degree * 24.0);
    CLLocationCoordinate2D coordinates[24];
    CLLocationCoordinate2D coordinate = PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate;
    Planet planetForDay = PlanetaryHourDataSource.sharedDataSource.pd([NSDate date]);
    for (NSUInteger hour = 0; hour < 24; hour++)
    {
        coordinate = [self translateCoord:coordinate MetersLat:0 MetersLong:(hour < 12) ? (hour == 0) ? 0 : meters_per_planetary_hour_day : meters_per_planetary_hour_night];//(hour < 12) ? hour * hourDurationRatios[0].doubleValue : hour * hourDurationRatios[1].doubleValue];
        coordinates[hour] = coordinate;
        MKPointAnnotation *planetaryHourAnnotation = [[MKPointAnnotation alloc] init];
        planetaryHourAnnotation.title = PlanetaryHourDataSource.sharedDataSource.ps(planetForDay + hour);
        planetaryHourAnnotation.subtitle = [NSString stringWithFormat:@"%lu", hour];
        planetaryHourAnnotation.coordinate = coordinates[hour];
        [self.mapView addAnnotation:planetaryHourAnnotation];
        
    }
    
//    planetaryHoursPolyline = [MKGeodesicPolyline polylineWithCoordinates:coordinates count:24];
//    [self.mapView addOverlay:planetaryHoursPolyline];
    
//    [self repositionPlanetaryHourAnnotationsUsingDistance:[NSNumber numberWithDouble:earth_circumference]];
}

NSArray<NSNumber *>*hourDurationRatios()
{
    FESSolarCalculator *solarCalculator = [[FESSolarCalculator alloc] initWithDate:[NSDate date] location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
    NSTimeInterval daySpan = [solarCalculator.sunset timeIntervalSinceDate:solarCalculator.sunrise];
    NSTimeInterval nightSpan = 86400.0f - daySpan;
//    NSArray<NSNumber *> *hourDurations = PlanetaryHourDataSource.sharedDataSource.hd(daySpan);
//    NSArray<NSNumber *> *hourDurationRatios = @[[NSNumber numberWithDouble:(hourDurations[0].doubleValue / hourDurations[1].doubleValue)],
//                                                [NSNumber numberWithDouble:(hourDurations[1].doubleValue / hourDurations[0].doubleValue)]];
    NSArray<NSNumber *> *hourDurationRatios = @[[NSNumber numberWithDouble:daySpan / nightSpan],
                                                [NSNumber numberWithDouble:nightSpan / daySpan]];
    
    return hourDurationRatios;
}

double degreesToRadians(float degrees)
{
    return degrees * (M_PI / 180.0f);
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
//    [CATransaction begin];
//    MKMapRect annotationsRect = MKMapRectMake(mapView.annotationVisibleRect.origin.x, mapView.annotationVisibleRect.origin.y, mapView.annotationVisibleRect.size.width, mapView.annotationVisibleRect.size.height);
////    MKMapRect unionRect = MKMapRectUnion(annotationsRect, MKMapRectWorld);
//    NSArray<MKPointAnnotation *> *annotations = [[mapView annotationsInMapRect:annotationsRect] copy];
//    [mapView removeAnnotations:annotations];
//    [CATransaction setCompletionBlock:^{
//        [mapView addAnnotations:annotations];
//    }];
////    [[mapView annotationsInMapRect:unionRect] enumerateObjectsUsingBlock:^(id<MKAnnotation>  _Nonnull obj, BOOL * _Nonnull stop) {
////        [[self.mapView viewForAnnotation:obj] setHidden:TRUE];
////    }];
//    [CATransaction commit];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    [CATransaction begin];
//    MKMapRect annotationsRect = MKMapRectMake(mapView.annotationVisibleRect.origin.x, mapView.annotationVisibleRect.origin.y, mapView.annotationVisibleRect.size.width, mapView.annotationVisibleRect.size.height);
//    [[mapView annotationsInMapRect:annotationsRect] enumerateObjectsUsingBlock:^(id<MKAnnotation>  _Nonnull obj, BOOL * _Nonnull stop) {
//        [[self.mapView viewForAnnotation:obj] setHidden:FALSE];
//    }];
//    [CATransaction commit];
}

- (void)repositionPlanetaryHourAnnotationsUsingDistance:(NSNumber *)earth_circumference {
    // distance / (86400.0 seconds per day / 24.0 distances)
    
//    FESSolarCalculator *solarCalculator = [[FESSolarCalculator alloc] initWithDate:[NSDate date] location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
//    NSTimeInterval daySpan = [solarCalculator.sunset timeIntervalSinceDate:solarCalculator.sunrise];
//    NSArray<NSNumber *> *hourDurations = PlanetaryHourDataSource.sharedDataSource.hd(daySpan);
//
    double meters_per_planetary_hour_day = ((earth_circumference.doubleValue * 0.5) * hourDurationRatios()[0].doubleValue) / 12.0;
    double meters_per_planetary_hour_night = ((earth_circumference.doubleValue * 0.5) * hourDurationRatios()[1].doubleValue) / 12.0;
    
    FESSolarCalculator *solarCalculator = [[FESSolarCalculator alloc] initWithDate:[NSDate date] location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
    NSTimeInterval daySpan = [solarCalculator.sunset timeIntervalSinceDate:solarCalculator.sunrise];
    NSArray<NSNumber *> *hourDurations = PlanetaryHourDataSource.sharedDataSource.hd(daySpan);
    double steps_per_planetary_hour_day = meters_per_planetary_hour_day / hourDurations[0].doubleValue;
    double steps_per_planetary_hour_night = meters_per_planetary_hour_night / hourDurations[1].doubleValue;// meters_per_planetary_hour_night / ((86400.0f * hourDurationRatios()[0].doubleValue) / (hourDurationRatios()[1].doubleValue * 12.0));
    NSLog(@"steps per day\t%f\t\tsteps per night\t%f", steps_per_planetary_hour_day, steps_per_planetary_hour_night);
//    CLLocationCoordinate2D coordinates[24];
    __block NSUInteger index = 0;
    Planet planetForDay = PlanetaryHourDataSource.sharedDataSource.pd([NSDate date]);
    
    NSArray<MKPointAnnotation *> *annotations = [self.mapView annotations];//annotationsInMapRect:annotationsRect] copy];
    
    [CATransaction begin];
        [self.mapView removeAnnotations:[self.mapView annotations]];
    [CATransaction setCompletionBlock:^{
        [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [self.mapView addAnnotations:annotations];
            }];
            for (MKPointAnnotation *obj in annotations)
            {
                // To-do: Calculate coordinates based on elapsed time since last update
                //        (so that annotations can be repositioned when region changes)
                double step = (index < 12) ? steps_per_planetary_hour_day : steps_per_planetary_hour_night;
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(obj.coordinate.latitude, obj.coordinate.longitude);
                [obj setCoordinate:[self translateCoord:coordinate MetersLat:0 MetersLong:step]];
                [obj setTitle:PlanetaryHourDataSource.sharedDataSource.ps(planetForDay + index)];
                index++;
            }
        [CATransaction commit];
    }];
    [CATransaction commit];
    [self performSelector:@selector(repositionPlanetaryHourAnnotationsUsingDistance:) withObject:earth_circumference afterDelay:1.0];
}

- (CLLocationCoordinate2D)translateCoord:(CLLocationCoordinate2D)coord MetersLat:(double)metersLat MetersLong:(double)metersLong{
    
    CLLocationCoordinate2D tempCoord;
    MKCoordinateRegion tempRegion = MKCoordinateRegionMakeWithDistance(coord, metersLat, metersLong);
    MKCoordinateSpan tempSpan = tempRegion.span;
    
    tempCoord.latitude = coord.latitude + tempSpan.latitudeDelta;
    tempCoord.longitude = coord.longitude + tempSpan.longitudeDelta;
    
    if (tempCoord.longitude > 180.0)
        tempCoord.longitude = -1.0 * (180.0 - (tempCoord.longitude - 180.0));
    else
        tempCoord.longitude = coord.longitude + tempSpan.longitudeDelta;

    return tempCoord;
}


CLLocationCoordinate2D MKCoordinateOffsetFromCoordinate(CLLocationCoordinate2D coordinate, CLLocationDistance offsetLatMeters, CLLocationDistance offsetLongMeters) {
    MKMapPoint offsetPoint = MKMapPointForCoordinate(coordinate);
    
    CLLocationDistance metersPerPoint = MKMetersPerMapPointAtLatitude(coordinate.latitude);
    double latPoints = offsetLatMeters / metersPerPoint;
    offsetPoint.y += latPoints;
    double longPoints = offsetLongMeters / metersPerPoint;
    offsetPoint.x += longPoints;
    
    CLLocationCoordinate2D offsetCoordinate = MKCoordinateForMapPoint(offsetPoint);
    return offsetCoordinate;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if (![overlay isKindOfClass:[MKPolyline class]]) {
        return nil;
    }
    
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
    renderer.lineWidth = 1.0f;
    renderer.strokeColor = [UIColor blueColor];
    renderer.alpha = 0.5;
    
    
    return renderer;
}

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//{
//    static NSString * PinIdentifier = @"Pin";
//
//    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
//    if (!annotationView) {
//        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
//    }
//
////    annotationView.image = [UIImage imageNamed:@"plane"];
////    planetaryHourSymbolTextLayer = [CATextLayer layer];
////    planetaryHourSymbolTextLayer.frame = annotationView.layer.bounds;
////    planetaryHourSymbolTextLayer.alignmentMode = kCAAlignmentCenter;
////    planetaryHourSymbolTextLayer.string = @"Planetary Hour";
////    [annotationView.layer addSublayer:planetaryHourSymbolTextLayer];
//
//    return annotationView;
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


@end
