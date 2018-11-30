//
//  PlanetaryHourAnnotations.m
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 11/27/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "PlanetaryHourAnnotations.h"
#import "FESSolarCalculator.h"

#define SECONDS_PER_DAY 86400.00f
#define HOURS_PER_SOLAR_TRANSIT 12.0f
#define HOURS_PER_DAY 24
#define NUMBER_OF_PLANETS 7

@implementation MKPointAnnotation (MKPointAnnotation_PlanetaryHour)

- (instancetype)initWithPlanetaryHour:(NSInteger)hour
{
    if (self == [super init])
    {
        [self setPlanetaryHour:[NSNumber numberWithInteger:hour]];
    }
    
    return self;
}

@dynamic planetaryHour, timer, updateLocationBlock;

- (void)setPlanetaryHour:(NSNumber *)planetaryHour
{
    objc_setAssociatedObject(self, @selector(planetaryHour), planetaryHour, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)planetaryHour
{
    return objc_getAssociatedObject(self, @selector(planetaryHour));
}

- (void)setTimer:(dispatch_source_t)timer
{
    objc_setAssociatedObject(self, @selector(timer), timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (dispatch_source_t)timer
{
    return objc_getAssociatedObject(self, @selector(timer));
}

- (void)setUpdateLocationBlock:(UpdateLocation)updateLocationBlock
{
    objc_setAssociatedObject(self, @selector(updateLocationBlock), updateLocationBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UpdateLocation)updateLocationBlock
{
    return objc_getAssociatedObject(self, @selector(updateLocationBlock));
}

@end


@implementation PlanetaryHourAnnotations

static PlanetaryHourAnnotations *annotations = NULL;
+ (nonnull PlanetaryHourAnnotations *)annotationsForLocation:(CLLocation *)location
{
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
                      if (!annotations)
                      {
//                          NSMutableArray<MKPointAnnotation *> *array = [NSMutableArray arrayWithCapacity:24];
//                          for (NSInteger i = 0; i < 24; i++)
//                          {
//                              MKPointAnnotation *annotation = [[MKPointAnnotation alloc] initWithPlanetaryHour:i];
//                              [array addObject:annotation];
//                          }
                          annotations = [[self alloc] init];//WithArray:(NSArray<MKPointAnnotation *> *)array];
                          [annotations setUserLocation:location];
                          [annotations setSharedProperties:[NSDate date]];
                      }
                  });
    
    return annotations;
}

- (NSUInteger)count
{
    return 24;
}

@synthesize sunrise = _sunrise, userLocation = _userLocation, metersPerDayHour = _metersPerDayHour, metersPerNightHour = _metersPerNightHour;

- (CLLocation *)userLocation
{
    return _userLocation;
}

- (void)setUserLocation:(CLLocation *)userLocation
{
    _userLocation = userLocation;
}

- (FESSolarCalculator *)solarCalculationForDate:(NSDate *)date location:(CLLocation *)location
{

    if (!date) date = [NSDate date];
  FESSolarCalculator *solarCalculator = [[FESSolarCalculator alloc] initWithDate:date location:location];
    
    NSDate *earlierDate = [solarCalculator.sunrise earlierDate:date];
    if ([earlierDate isEqualToDate:date])
    {
        NSCalendar *calendar =  [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.day = -1;
        NSDate *yesterday = [calendar dateByAddingComponents:components toDate:date options:NSCalendarMatchNextTimePreservingSmallerUnits];
        solarCalculator = [[FESSolarCalculator alloc] initWithDate:yesterday location:location];
    }
    
    return solarCalculator;
}


- (void)setSharedProperties:(NSDate *)date
{
    if (!date) date = [NSDate date];
    self.solarCalculator = [[FESSolarCalculator alloc] initWithDate:date location:_userLocation];
    
    NSDate *earlierDate = [self.solarCalculator.sunrise earlierDate:date];
    if ([earlierDate isEqualToDate:date])
    {
        NSCalendar *calendar =  [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.day = -1;
        NSDate *yesterday = [calendar dateByAddingComponents:components toDate:date options:NSCalendarMatchNextTimePreservingSmallerUnits];
        self.solarCalculator = [[FESSolarCalculator alloc] initWithDate:yesterday location:_userLocation];
    }
    
    NSTimeInterval seconds_in_day         = [self.solarCalculator.sunset timeIntervalSinceDate:self.solarCalculator.sunrise];
    NSTimeInterval seconds_in_night       = SECONDS_PER_DAY - seconds_in_day;
    double earth_rotation_mps             = MKMapSizeWorld.width / SECONDS_PER_DAY;
    double meters_per_day                 = seconds_in_day   * earth_rotation_mps;
    double meters_per_night               = seconds_in_night * earth_rotation_mps;
    [self setMetersPerDayHour:meters_per_day / HOURS_PER_SOLAR_TRANSIT];
    [self setMetersPerNightHour:meters_per_night / HOURS_PER_SOLAR_TRANSIT];
    [self setSunrise:self.solarCalculator.sunrise];
}

- (NSTimeInterval)elapsedTime:(NSDate *)date
{
    NSTimeInterval elapsedTime = [date timeIntervalSinceDate:_sunrise];
    
    if (elapsedTime < 0 || elapsedTime > SECONDS_PER_DAY)
    {
        if (elapsedTime > -SECONDS_PER_DAY)
        {
            NSDate *earlierDate = [_sunrise earlierDate:date];
            if ([earlierDate isEqualToDate:date])
            {
                NSLog(@"Subtracting one day...");
                NSCalendar *calendar =  [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *components = [[NSDateComponents alloc] init];
                components.day = -1;
                date = [calendar dateByAddingComponents:components toDate:date options:NSCalendarMatchNextTimePreservingSmallerUnits];
            }
        }
        
        self.solarCalculator = [[FESSolarCalculator alloc] initWithDate:date location:_userLocation];
        NSLog(@"Changing sunrise date...");
        [self setSunrise:self.solarCalculator.sunrise];
        NSTimeInterval seconds_in_day         = [self.solarCalculator.sunset timeIntervalSinceDate:self.solarCalculator.sunrise];
        NSTimeInterval seconds_in_night       = SECONDS_PER_DAY - seconds_in_day;
        double earth_rotation_mps             = MKMapSizeWorld.width / SECONDS_PER_DAY;
        double meters_per_day                 = seconds_in_day   * earth_rotation_mps;
        double meters_per_night               = seconds_in_night * earth_rotation_mps;
        [self setMetersPerDayHour:meters_per_day / HOURS_PER_SOLAR_TRANSIT];
        [self setMetersPerNightHour:meters_per_night / HOURS_PER_SOLAR_TRANSIT];
        
        elapsedTime = [date timeIntervalSinceDate:_sunrise];
    }
    
    return elapsedTime;
}

- (NSDate *)sunrise
{
    return _sunrise;
}

- (void)setSunrise:(NSDate *)sunrise
{
    _sunrise = sunrise;
}

- (double)metersPerDayHour
{
    return _metersPerDayHour;
}

- (void)setMetersPerDayHour:(double)metersPerDayHour
{
    _metersPerDayHour = metersPerDayHour;
}

- (double)metersPerNightHour
{
    return _metersPerNightHour;
}

- (void)setMetersPerNightHour:(double)metersPerNightHour
{
    _metersPerNightHour = metersPerNightHour;
}

- (NSArray *)annotationPool
{
    if (!annotationPool)
    {
        NSMutableArray<MKPointAnnotation *> *array = [NSMutableArray arrayWithCapacity:24];
          for (NSInteger index = 0; index < 24; index++)
          {
              
              MKPointAnnotation *annotation = [[MKPointAnnotation alloc] initWithPlanetaryHour:index];
                                               
              MKMapPoint user_location_map_point = MKMapPointForCoordinate(_userLocation.coordinate);
              MKMapPoint planetary_hour_origin = MKMapPointMake((index < HOURS_PER_SOLAR_TRANSIT)
                                                                ? user_location_map_point.x + (_metersPerDayHour * annotation.planetaryHour.doubleValue)
                                                                : user_location_map_point.x + ((_metersPerDayHour * 12) + (_metersPerNightHour * (annotation.planetaryHour.integerValue % 12))), user_location_map_point.y);
              MKMapPoint planetary_hour_origin_offset = MKMapPointMake(planetary_hour_origin.x - ([self elapsedTime:[NSDate date]] * MKMapSizeWorld.width / SECONDS_PER_DAY), planetary_hour_origin.y);
              CLLocationCoordinate2D planetary_hour_origin_offset_coordinate = MKCoordinateForMapPoint(planetary_hour_origin_offset);
              [annotation setCoordinate:planetary_hour_origin_offset_coordinate];
              
             [annotation setUpdateLocationBlock:^CLLocationCoordinate2D(NSDate * _Nonnull date) {
                 
                MKMapPoint planetary_hour_origin_offset = MKMapPointMake(planetary_hour_origin.x - ([self elapsedTime:date] * MKMapSizeWorld.width / SECONDS_PER_DAY), planetary_hour_origin.y);
                  CLLocationCoordinate2D planetary_hour_origin_offset_coordinate = MKCoordinateForMapPoint(planetary_hour_origin_offset);
                  
                  return planetary_hour_origin_offset_coordinate;
              }];
              
//              [annotation setTimer:dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue)];
//              dispatch_source_set_timer(annotation.timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 1.0 * NSEC_PER_SEC);
//              dispatch_source_set_event_handler(annotation.timer, ^{
//                  MKMapPoint planetary_hour_origin_offset = MKMapPointMake(planetary_hour_origin.x - ([self elapsedTime:[NSDate date]] * MKMapSizeWorld.width / SECONDS_PER_DAY), planetary_hour_origin.y);
//                  CLLocationCoordinate2D planetary_hour_origin_offset_coordinate = MKCoordinateForMapPoint(planetary_hour_origin_offset);
//                  
//                  [annotation setCoordinate:planetary_hour_origin_offset_coordinate];
//              });
//              dispatch_resume(annotation.timer);
              
              [array addObject:annotation];
          }
        annotationPool = array;
    }
    
    return annotationPool;
}

- (MKPointAnnotation *)objectAtIndex:(NSUInteger)index
{
    return [[self annotationPool] objectAtIndex:index];
}

- (instancetype)init
{
    if (self == [super init])
    {
        timerQueue = dispatch_queue_create_with_target("Planetary Hour Data Request Queue", DISPATCH_QUEUE_CONCURRENT, dispatch_get_main_queue());
    }
    
    return self;
}

@end
