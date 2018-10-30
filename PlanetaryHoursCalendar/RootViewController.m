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

@interface RootViewController ()
{
    MKGeodesicPolyline *flightPathPolyline;
    MKPointAnnotation *planeAnnotation;
    NSUInteger planeAnnotationPosition;
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
    const double meters_per_planetary_hour = earth_circumference / 24.0;
//    const double meters_per_planetary_hour_longitude = (meters_per_degree * 24.0);
    CLLocationCoordinate2D coordinates[24];
    Planet planetForDay = PlanetaryHourDataSource.sharedDataSource.pd([NSDate date]);
    for (NSUInteger hour = 0; hour < 24; hour++)
    {
        coordinates[hour] = [self translateCoord:PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate MetersLat:0 MetersLong:meters_per_planetary_hour * hour];
        
        MKPointAnnotation *planetaryHourAnnotation = [[MKPointAnnotation alloc] init];
        planetaryHourAnnotation.title = NSLocalizedString(PlanetaryHourDataSource.sharedDataSource.ps(planetForDay + hour), nil);
        planetaryHourAnnotation.coordinate = coordinates[hour];
        [self.mapView addAnnotation:planetaryHourAnnotation];
        
    }
    
    flightPathPolyline = [MKGeodesicPolyline polylineWithCoordinates:coordinates count:24];
    [self.mapView addOverlay:flightPathPolyline];
    
//    [self updatePlanePosition];
}

double degreesToRadians(float degrees)
{
    return degrees * (M_PI / 180.0f);
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


- (void)updatePlanePosition {
    static NSUInteger const step = 5;
    
    if (planeAnnotationPosition + step >= flightPathPolyline.pointCount) {
        return;
    }
    
    planeAnnotationPosition += step;
    MKMapPoint nextMapPoint = flightPathPolyline.points[planeAnnotationPosition];
    
    planeAnnotation.coordinate = MKCoordinateForMapPoint(nextMapPoint);
    
    [self performSelector:@selector(updatePlanePosition) withObject:nil afterDelay:0.03];
}

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
