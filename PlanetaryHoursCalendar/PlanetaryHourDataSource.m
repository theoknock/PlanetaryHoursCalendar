//
//  PlanetaryHourDataSource.m
//  JBPlanetaryHourCalculator
//
//  Created by Xcode Developer on 10/23/18.
//  Copyright © 2018 Xcode Developer. All rights reserved.
//

#import "PlanetaryHourDataSource.h"
#import "FESSolarCalculator.h"

NSString * const kPlanetaryHourSymbolDataKey   = @"PlanetaryHourSymbolDataKey";
NSString * const kPlanetaryHourNameDataKey     = @"PlanetaryHourNameDataKey";
NSString * const kPlanetaryHourBeginDataKey    = @"PlanetaryHourBeginDataKey";
NSString * const kPlanetaryHourEndDataKey      = @"PlanetaryHourEndDataKey";
NSString * const kPlanetaryHourLocationDataKey = @"PlanetaryHourLocationDataKey";

@interface PlanetaryHourDataSource ()

@end

@implementation PlanetaryHourDataSource

static PlanetaryHourDataSource *sharedDataSource = NULL;
+ (nonnull PlanetaryHourDataSource *)sharedDataSource
{
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
                      if (!sharedDataSource)
                      {
                          printf("\n%s\n", __PRETTY_FUNCTION__);
                          sharedDataSource = [[self alloc] init];
                      }
                  });
    
    return sharedDataSource;
}

- (instancetype)init
{
    if (self == [super init])
    {
        self.planetaryHourDataRequestQueue = dispatch_queue_create_with_target("Planetary Hour Data Request Queue", DISPATCH_QUEUE_CONCURRENT, dispatch_get_main_queue());
        
        self.locationManager = [[CLLocationManager alloc] init];
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager setDelegate:(id<CLLocationManagerDelegate> _Nullable)self];
    }
    
    return self;
}


//static NSArray<NSString *> *_planetaryHourDataKeys = NULL;
//+ (NSArray<NSString *> *)planetaryHourDataKeys {
//    return @[kPlanetaryHourSymbolDataKey, kPlanetaryHourNameDataKey, kPlanetaryHourBeginDataKey, kPlanetaryHourEndDataKey, kPlanetaryHourLocationDataKey];
//}

NSString *(^planetSymbolForPlanet)(Planet) = ^(Planet planet) {
    planet = planet % NUMBER_OF_PLANETS;
    switch (planet) {
        case Sun:
            return @"☉";
            break;
        case Moon:
            return @"☽";
            break;
        case Mars:
            return @"♂︎";
            break;
        case Mercury:
            return @"☿";
            break;
        case Jupiter:
            return @"♃";
            break;
        case Venus:
            return @"♀︎";
            break;
        case Saturn:
            return @"♄";
            break;
        default:
            break;
    }
};

Planet(^planetForDay)(NSDate * _Nullable) = ^(NSDate * _Nullable date) {
    if (!date) date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    Planet planet = [calendar component:NSCalendarUnitWeekday fromDate:date] - 1;
    
    return planet;
};

Planet(^planetForHour)(NSDate * _Nullable, NSUInteger) = ^(NSDate * _Nullable date, NSUInteger hour) {
    hour = hour % HOURS_PER_DAY;
    Planet planet = (planetForDay(date) + hour) % NUMBER_OF_PLANETS;
    
    return planet;
};

NSString *(^planetNameForDay)(NSDate * _Nullable) = ^(NSDate * _Nullable date)
{
    Day day = (Day)planetForDay(date);
    switch (day) {
        case SUN:
            return @"Sun";
            break;
        case MON:
            return @"Moon";
            break;
        case TUE:
            return @"Mars";
            break;
        case WED:
            return @"Mercury";
            break;
        case THU:
            return @"Jupiter";
            break;
        case FRI:
            return @"Venus";
            break;
        case SAT:
            return @"Saturn";
            break;
        default:
            break;
    }
};

NSString *(^planetSymbolForDay)(NSDate * _Nullable) = ^(NSDate * _Nullable date) {
    return planetSymbolForPlanet(planetForDay(date));
};

NSString *(^planetNameForHour)(NSDate * _Nullable, NSUInteger) = ^(NSDate * _Nullable date, NSUInteger hour)
{
    switch (planetForHour(date, hour)) {
        case Sun:
            return @"Sun";
            break;
        case Moon:
            return @"Moon";
            break;
        case Mars:
            return @"Mars";
            break;
        case Mercury:
            return @"Mercury";
            break;
        case Jupiter:
            return @"Jupiter";
            break;
        case Venus:
            return @"Venus";
            break;
        case Saturn:
            return @"Saturn";
            break;
        default:
            break;
    }
};

NSString *(^planetSymbolForHour)(NSDate * _Nullable, NSUInteger) = ^(NSDate * _Nullable date, NSUInteger hour) {
    return planetSymbolForPlanet(planetForHour(date, hour));
};

//CLLocation *(^planetaryHourLocation)(CLLocation * _Nullable, NSDate * _Nullable, NSUInteger) = ^(CLLocation * _Nullable location, NSDate * _Nullable date, NSUInteger hour) {
//    if (!date) date = [NSDate date];
//    hour = hour % HOURS_PER_DAY;
//    if (!location) location = locator().location;
//    FESSolarCalculator *solarCalculator = [[FESSolarCalculator alloc] initWithDate:date location:location];
//    NSTimeInterval daySpan   = [solarCalculator.sunset timeIntervalSinceDate:solarCalculator.sunrise];
//    NSTimeInterval nightSpan = 86400.0f - daySpan;
//    NSTimeInterval dayPercentage   = daySpan   / 86400.0f;
//    NSTimeInterval nightPercentage = nightSpan / 86400.0f;
//    double mapSizeWorldWidthForDay   = MKMapSizeWorld.width * dayPercentage;
//    double mapSizeWorldWidthForNight = MKMapSizeWorld.width * nightPercentage;
//    double width_per_day_hour   = mapSizeWorldWidthForDay / 12.0;
//    double width_per_night_hour = mapSizeWorldWidthForNight / 12.0;
////    double steps_per_day_hour_second = (width_per_day_hour / 60.0) / 60.0;
////    double steps_per_night_hour_second = (width_per_night_hour / 60.0) / 60.0;
////    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:solarCalculator.sunrise];
//    MKMapPoint location_point = MKMapPointForCoordinate(location.coordinate);
//    MKMapPoint start_point = MKMapPointMake((hour < 12) ? location_point.x + (width_per_day_hour * hour) : (location_point.x + mapSizeWorldWidthForDay) + (width_per_night_hour * (hour % 12)), location_point.y);
//    CLLocationCoordinate2D start_coordinate = MKCoordinateForMapPoint(start_point);
//    CLLocation *coordinate = [[CLLocation alloc] initWithLatitude:start_coordinate.latitude longitude:start_coordinate.latitude];
//    
//    return coordinate;
//};

#pragma mark <CLLocationManagerDelegate methods>

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s\n%@", __PRETTY_FUNCTION__, error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
//    NSLog(@"%s\t\t\nLocation services authorization status code:\t%d", __PRETTY_FUNCTION__, status);
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        NSLog(@"%s\nFailure to authorize location services", __PRETTY_FUNCTION__);
    }
    else
    {
        CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
        if (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse ||
            authStatus == kCLAuthorizationStatusAuthorizedAlways)
        {
            //[manager requestLocation];
            [manager startMonitoringSignificantLocationChanges];
            NSLog(@"Location services authorized");
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"User location\t%f", locations.lastObject.coordinate.longitude);
//    CLLocation *currentLocation = [locations lastObject];
//    if ((self.lastLocation == nil) || (((self.lastLocation.coordinate.latitude != currentLocation.coordinate.latitude) || (self.lastLocation.coordinate.longitude != currentLocation.coordinate.longitude)) && ((currentLocation.coordinate.latitude != 0.0) || (currentLocation.coordinate.longitude != 0.0)))) {
//        self.lastLocation = [[CLLocation alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
//        NSLog(@"%s", __PRETTY_FUNCTION__);
//        //    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlanetaryHoursDataSourceUpdatedNotification"
//        //                                                        object:nil
//        //                                                      userInfo:nil];
//    }
}

- (void)dealloc
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
    sharedDataSource = nil;
}

#pragma mark - String-matching methods


NSString *(^planetName)(Planet) = ^(Planet planet) {
//    printf("\n%s\n", __PRETTY_FUNCTION__);
    
    switch (planet) {
        case Sun:
            return @"Sun";
            break;
        case Moon:
            return @"Moon";
            break;
        case Mars:
            return @"Mars";
            break;
        case Mercury:
            return @"Mercury";
            break;
        case Jupiter:
            return @"Jupiter";
            break;
        case Venus:
            return @"Venus";
            break;
        case Saturn:
            return @"Saturn";
            break;
        default:
            break;
    }
};

UIColor *(^planetColor)(Planet) = ^(Planet planet) {
    printf("\n%s\n", __PRETTY_FUNCTION__);
    
    switch (planet) {
        case Sun:
            return [UIColor yellowColor];
            break;
        case Moon:
            return [UIColor whiteColor];
            break;
        case Mars:
            return [UIColor redColor];
            break;
        case Mercury:
            return [UIColor brownColor];
            break;
        case Jupiter:
            return [UIColor orangeColor];
            break;
        case Venus:
            return [UIColor greenColor];
            break;
        case Saturn:
            return [UIColor grayColor];
            break;
        default:
            break;
    }
};

#pragma mark - EventKit-related methods for calendaring and/or generating planetary hour events

//
//NSArray *(^datesWithData)(NSData *) = ^(NSData *urlSessionData)
//{
//    printf("%s\n", __PRETTY_FUNCTION__);
//
//    // Create midnight date object for current day
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSString *midnightDateString = [NSString stringWithFormat:@"%lu-%lu-%lu'T'00:00:00+00:00",
//                                    (long)[calendar component:NSCalendarUnitYear fromDate:[NSDate date]],
//                                    (long)[calendar component:NSCalendarUnitMonth fromDate:[NSDate date]],
//                                    (long)[calendar component:NSCalendarUnitDay fromDate:[NSDate date]]];
//
//
//    __autoreleasing NSError *error;
//    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:urlSessionData options:NSJSONReadingMutableLeaves error:&error];
//    NSDateFormatter *RFC3339DateFormatter = [[NSDateFormatter alloc] init];
//    RFC3339DateFormatter.locale = [NSLocale currentLocale];
//    RFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
//    RFC3339DateFormatter.timeZone = [NSTimeZone localTimeZone];
//    NSDate *midnight = [RFC3339DateFormatter dateFromString:midnightDateString];
//    NSDate *sunrise = [RFC3339DateFormatter dateFromString:[[responseDict objectForKey:@"results"] objectForKey:@"sunrise"]];
//    NSDate *sunset  = [RFC3339DateFormatter dateFromString:[[responseDict objectForKey:@"results"] objectForKey:@"sunset"]];
//    NSDate *solarNoon  = [RFC3339DateFormatter dateFromString:[[responseDict objectForKey:@"results"] objectForKey:@"solar_noon"]];
//    NSDate *civilTwilightBegin  = [RFC3339DateFormatter dateFromString:[[responseDict objectForKey:@"results"] objectForKey:@"civil_twilight_begin"]];
//    NSDate *civilTwilightEnd  = [RFC3339DateFormatter dateFromString:[[responseDict objectForKey:@"results"] objectForKey:@"civil_twilight_end"]];
//    NSDate *nauticalTwilightBegin  = [RFC3339DateFormatter dateFromString:[[responseDict objectForKey:@"results"] objectForKey:@"nautical_twilight_begin"]];
//    NSDate *nauticalTwilightEnd  = [RFC3339DateFormatter dateFromString:[[responseDict objectForKey:@"results"] objectForKey:@"nautical_twilight_end"]];
//    NSDate *astronomicalTwilightBegin  = [RFC3339DateFormatter dateFromString:[[responseDict objectForKey:@"results"] objectForKey:@"astronomical_twilight_begin"]];
//    NSDate *astronomicalTwlightEnd  = [RFC3339DateFormatter dateFromString:[[responseDict objectForKey:@"results"] objectForKey:@"astronomical_twilight_end"]];
//
//    return @[midnight, astronomicalTwilightBegin, nauticalTwilightBegin, civilTwilightBegin, sunrise, solarNoon, sunset, civilTwilightEnd, nauticalTwilightEnd, astronomicalTwlightEnd];
//};


// The request and response blocks are separated from the cached data/cache data block
// so that multiple third-party data providers can be supported; distinct request and response blocks will be made for each service supported;
// if one returns nil, then another can be tried
NSArray *(^responseSunriseSunsetOrg)(NSData *) = ^(NSData *data) {
    printf("\n%s\n", __PRETTY_FUNCTION__);
    __autoreleasing NSError *error;
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSDateFormatter *RFC3339DateFormatter = [[NSDateFormatter alloc] init];
    RFC3339DateFormatter.locale = [NSLocale currentLocale];
    RFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    RFC3339DateFormatter.timeZone = [NSTimeZone systemTimeZone];
    NSDate *sunrise = [RFC3339DateFormatter dateFromString:[[responseDict objectForKey:@"results"] objectForKey:@"sunrise"]];
    NSDate *sunset  = [RFC3339DateFormatter dateFromString:[[responseDict objectForKey:@"results"] objectForKey:@"sunset"]];
    NSArray *sunriseSunsetDates = @[sunrise, sunset];
    
    NSLog(@"Response:\t%@\t\t%@", sunrise.description, sunset.description);
    
    return sunriseSunsetDates;
};

NSURLRequest *(^requestSunriseSunsetOrg)(CLLocationCoordinate2D, NSDate *) = ^(CLLocationCoordinate2D coordinate, NSDate *date) {
    printf("\n%s\n", __PRETTY_FUNCTION__);
    if (!date) date = [NSDate date];
    NSString *urlString = [NSString stringWithFormat:@"http://api.sunrise-sunset.org/json?lat=%f&lng=%f&date=%ld-%ld-%ld&formatted=0",
                           coordinate.latitude,
                           coordinate.longitude,
                           (long)[[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:date],
                           (long)[[NSCalendar currentCalendar] component:NSCalendarUnitMonth fromDate:date],
                           (long)[[NSCalendar currentCalendar] component:NSCalendarUnitDay fromDate:date]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:(NSTimeInterval)(10.0 * NSEC_PER_SEC)];
    
    return request;
};
//
//
//

void(^cachedSunriseSunsetData)(CLLocation * _Nullable, NSDate * _Nullable, CachedSunriseSunsetDataWithCompletionBlock) = ^(CLLocation * _Nullable location, NSDate * _Nullable date, CachedSunriseSunsetDataWithCompletionBlock sunriseSunsetData)
{
    NSURLRequest *request = requestSunriseSunsetOrg(location.coordinate, date);
    NSData *cachedData = [[[NSURLCache sharedURLCache] cachedResponseForRequest:request] data];
    if (cachedData) {
        printf("\n%s\n", __PRETTY_FUNCTION__);
        NSArray<NSDate *> *sunriseSunsetDates = responseSunriseSunsetOrg(cachedData);
        sunriseSunsetData(sunriseSunsetDates);
    } else {
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error)
            {
                NSLog(@"Error getting response:\t%@", error);
            } else {
                printf("\n%s\n", __PRETTY_FUNCTION__);
                NSDictionary *solarDataIdentifiers = @{@"location" : [NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude], @"date" : date};
                NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data userInfo:solarDataIdentifiers storagePolicy:NSURLCacheStorageAllowed];
                [[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:request];
                NSData *cachedData = [[[NSURLCache sharedURLCache] cachedResponseForRequest:request] data];
                NSArray<NSDate *> *sunriseSunsetDates = responseSunriseSunsetOrg(cachedData);
    
                sunriseSunsetData(sunriseSunsetDates);
            }
        }] resume];
    }
};

//NSDictionary *(^planetaryHourData)(NSArray<NSNumber *> *, NSUInteger, NSArray<NSDate *> *, CLLocationCoordinate2D) = ^(NSArray<NSNumber *> *hourDurations, NSUInteger hour, NSArray<NSDate *> *dates, CLLocationCoordinate2D coordinate)
//{
//    NSUInteger index = (hour < HOURS_PER_SOLAR_TRANSIT) ? 0 : 1;
//    NSTimeInterval startTimeInterval = hourDurations[index].doubleValue * hour;
//    NSDate *startTime                = [[NSDate alloc] initWithTimeInterval:startTimeInterval sinceDate:dates[index]];
//    NSTimeInterval endTimeInterval   = hourDurations[index].doubleValue * (hour + 1);
//    NSDate *endTime                  = [[NSDate alloc] initWithTimeInterval:endTimeInterval sinceDate:dates[index]];
//    Planet dailyPlanet               = planetForDay(dates[index]);
//    NSDictionary *planetaryHour      = @{kPlanetaryHourBeginDataKey    : [startTime description],
//                                         kPlanetaryHourEndDataKey      : [endTime description],
//                                         kPlanetaryHourLocationDataKey : [NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude],
//                                         kPlanetaryHourSymbolDataKey   : planetSymbolForHour(dailyPlanet, hour),
//                                         kPlanetaryHourNameDataKey     : planetNameForHour(dailyPlanet, hour)};
//
//    return planetaryHour;
//};

//- (void)planetaryHours:(_Nullable NSRangePointer *)hours date:(nullable NSDate *)date location:(nullable CLLocation *)location withCompletion:(void(^)(NSArray<NSDictionary *> *))planetaryHoursData;
//{
//    location = (CLLocationCoordinate2DIsValid(location.coordinate)) ? locationManager.location : location;
//    cachedSunriseSunsetData(location, [NSDate date],
//                            ^(NSArray<NSDate *> * _Nonnull sunriseSunsetDates) {
//                                __block NSMutableArray<NSDictionary *> *planetaryHoursArray = [[NSMutableArray alloc] initWithCapacity:24];
//                                __block dispatch_block_t planetaryHoursDictionaries;
//
//                                NSTimeInterval daySpan = [sunriseSunsetDates.firstObject timeIntervalSinceDate:sunriseSunsetDates.lastObject];
//                                NSTimeInterval dayHourDuration = daySpan / HOURS_PER_SOLAR_TRANSIT;
//                                NSTimeInterval nightSpan = fabs(SECONDS_PER_DAY - daySpan);
//                                NSTimeInterval nightHourDuration = nightSpan / HOURS_PER_SOLAR_TRANSIT;
//                                NSArray<NSNumber *> *hourDurations = @[[NSNumber numberWithDouble:dayHourDuration], [NSNumber numberWithDouble:nightHourDuration]];
//
//                                void(^planetaryHoursDictionary)(void) = ^(void) {
//                                    [planetaryHoursArray addObject:planetaryHourData(hourDurations, planetaryHoursArray.count, sunriseSunsetDates, location.coordinate)];
//                                    if (planetaryHoursArray.count < HOURS_PER_DAY) /*(sizeof(planetaryHoursArray) / sizeof([NSMutableArray class]))) */ planetaryHoursDictionaries();
//                                    else planetaryHoursData(planetaryHoursArray);
//                                };
//
//                                planetaryHoursDictionaries = ^{
//                                    planetaryHoursDictionary();
//                                };
//                                planetaryHoursDictionaries();
//                            });
//
//}
//
//- (void)planetaryHour:(NSUInteger)hour date:(nullable NSDate *)date location:(nullable CLLocation *)location withCompletion:(void(^)(NSDictionary *))planetaryHour;
//{
//    location = (CLLocationCoordinate2DIsValid(location.coordinate)) ? locationManager.location : location;
//    cachedSunriseSunsetData(location, (!date) ? [NSDate date] : date,
//                            ^(NSArray<NSDate *> * _Nonnull sunriseSunsetDates) {
//                                NSTimeInterval daySpan = [sunriseSunsetDates.lastObject timeIntervalSinceDate:sunriseSunsetDates.firstObject];
//                                NSTimeInterval dayHourDuration = daySpan / HOURS_PER_SOLAR_TRANSIT;
//                                NSTimeInterval nightSpan = fabs(SECONDS_PER_DAY - daySpan);
//                                NSTimeInterval nightHourDuration = nightSpan / HOURS_PER_SOLAR_TRANSIT;
//                                NSLog(@"(%@\t-\t%@) / 12\t=\t%f", sunriseSunsetDates.firstObject, sunriseSunsetDates.lastObject, dayHourDuration);
//
//                                NSArray<NSNumber *> *hourDurations = @[[NSNumber numberWithDouble:dayHourDuration], [NSNumber numberWithDouble:nightHourDuration]];
//                                planetaryHour(planetaryHourData(hourDurations, hour, sunriseSunsetDates, location.coordinate));
//                            });
//}
//
//- (void)planetaryHour:(NSUInteger)hour date:(nullable NSDate *)date location:(nullable CLLocation *)location objectForKey:(PlanetaryHourDataKey)planetaryHourDataKey withCompletion:(void(^)(NSString *))planetaryHourDataObject;
//{
//    planetaryHourDataKey = planetaryHourDataKey % 5;
//    [self planetaryHour:hour date:date location:location withCompletion:^(NSDictionary * _Nonnull planetaryHourData) {
//        //        planetaryHourDataObject(planetaryHourData[planetaryHourDataKey]);
//    }];
//}

//void(^currentPlanetaryHourAtLocation)(CLLocation * _Nullable, CurrentPlanetaryHourCompletionBlock) = ^(CLLocation * _Nullable location, CurrentPlanetaryHourCompletionBlock currentPlanetaryHour)
//{
//    location = (CLLocationCoordinate2DIsValid(location.coordinate)) ? locationManager.location : location;
//    cachedSunriseSunsetData(location, [NSDate date],
//                            ^(NSArray<NSDate *> * _Nonnull sunriseSunsetDates, NSArray<NSNumber *> * _Nonnull hourDurations) {
//                                __block NSUInteger hour = 0;
//                                __block dispatch_block_t planetaryHoursDictionaries;
//                                
//                                void(^planetaryHoursDictionary)(NSInteger) = ^(NSInteger index) {
//                                    NSTimeInterval startTimeInterval = hourDurations[index].doubleValue * hour;
//                                    NSDate *startTime                = [[NSDate alloc] initWithTimeInterval:startTimeInterval sinceDate:sunriseSunsetDates[index]];
//                                    NSTimeInterval endTimeInterval   = hourDurations[index].doubleValue * (hour + 1);
//                                    NSDate *endTime                  = [[NSDate alloc] initWithTimeInterval:endTimeInterval sinceDate:sunriseSunsetDates[index]];
//                                    
//                                    NSDateInterval *dateInterval = [[NSDateInterval alloc] initWithStartDate:startTime endDate:endTime];
//                                    if (![dateInterval containsDate:[NSDate date]])
//                                    {
//                                        hour++;
//                                        planetaryHoursDictionaries();
//                                    } else {
//                                        currentPlanetaryHour(planetaryHourData(hourDurations, hour, sunriseSunsetDates, location.coordinate));
//                                    }
//                                };
//                                
//                                planetaryHoursDictionaries = ^{
//                                    planetaryHoursDictionary((hour < HOURS_PER_SOLAR_TRANSIT) ? 0 : 1);
//                                };
//                                planetaryHoursDictionaries();
//                            });
//};
//
//void(^planetaryHourBlock)(NSUInteger, NSDate * _Nullable, CLLocation * _Nullable, PlanetaryHourCompletionBlock) = ^(NSUInteger hour, NSDate * _Nullable date, CLLocation * _Nullable location, PlanetaryHourCompletionBlock planetaryHourCompletionBlock)
//{
//    location = (CLLocationCoordinate2DIsValid(location.coordinate)) ? locationManager.location : location;
//    cachedSunriseSunsetData(location, (!date) ? [NSDate date] : date,
//                            ^(NSArray<NSDate *> * _Nonnull sunriseSunsetDates, NSArray<NSNumber *> * _Nonnull hourDurations) {
//                                planetaryHourCompletionBlock(planetaryHourData(hourDurations, hour, sunriseSunsetDates, location.coordinate));
//                            });
////    return ^NSDictionary *(NSDictionary *currentPlanetaryHourData) {
////        return planetaryHourData(hourDurations, hour, sunriseSunsetDates, location.coordinate));
////    };
//};

//- (NSDictionary *)planetaryDataForHour:(NSUInteger) hour date:(NSArray<NSDate *> *)sunriseSunsetDates location:(CLLocation *)location
//{
//    return planetaryHourData([NSArray new], hour, sunriseSunsetDates, location.coordinate);
//}



#pragma mark - EventKit

void(^calendarForEventStore)(EKEventStore *, CalendarForEventStoreCompletionBlock) = ^(EKEventStore *eventStore, CalendarForEventStoreCompletionBlock completionBlock)
{
    NSArray <EKCalendar *> *calendars = [eventStore calendarsForEntityType:EKEntityTypeEvent];
    [calendars enumerateObjectsUsingBlock:^(EKCalendar * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.title isEqualToString:@"Planetary Hour"]) {
            NSLog(@"Planetary Hour calendar found.");
            completionBlock(obj);
            *stop = TRUE;
        } else if (calendars.count == (idx + 1))
        {
            EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:eventStore];
            calendar.title = @"Planetary Hour";
            calendar.source = eventStore.sources[1];
            __autoreleasing NSError *error;
            if ([eventStore saveCalendar:calendar commit:YES error:&error])
            {
                completionBlock(calendar);
            } else {
                NSLog(@"Error saving new calendar: %@\nUsing default calendar for new events...", error.localizedDescription);
                completionBlock([eventStore defaultCalendarForNewEvents]);
            }
        }
    }];
};

//static NSDateFormatter *timeFormatter = NULL;
//- (NSDateFormatter *)timeFormatter
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if (!timeFormatter) {
//            timeFormatter = [[NSDateFormatter alloc] init];
////            [timeFormatter setDateStyle:NSDateFormatterShortStyle];
//            [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
//        }
//    });
//
//    return timeFormatter;
//}

NSArray<NSNumber *> *(^hourDurations)(NSTimeInterval) = ^(NSTimeInterval daySpan)
{
    NSTimeInterval dayHourDuration = daySpan / HOURS_PER_SOLAR_TRANSIT;
    NSTimeInterval nightSpan = fabs(SECONDS_PER_DAY - daySpan);
    NSTimeInterval nightHourDuration = nightSpan / HOURS_PER_SOLAR_TRANSIT;
    NSArray<NSNumber *> *hourDurations = @[[NSNumber numberWithDouble:dayHourDuration], [NSNumber numberWithDouble:nightHourDuration]];
    
    return hourDurations;
};

EKEvent *(^planetaryHourEvent)(NSUInteger, EKEventStore *, EKCalendar *, NSArray<NSNumber *> *, FESSolarCalculator *, CLLocationCoordinate2D) = ^(NSUInteger hour, EKEventStore *eventStore, EKCalendar *calendar, NSArray<NSNumber *> *hourDurations, FESSolarCalculator *dates, CLLocationCoordinate2D coordinate)
{
    Meridian meridian                = (hour < HOURS_PER_SOLAR_TRANSIT) ? AM : PM;
    SolarTransit transit             = (hour < HOURS_PER_SOLAR_TRANSIT) ? Sunrise : Sunset;
    NSString *symbol                 = planetSymbolForHour(dates.sunrise, hour);
    NSString *name                   = planetNameForHour(dates.sunrise, hour);
    NSString *hour_ordinal           = [NSString stringWithFormat:@"Hour %lu (%@)", hour + 1, (hour < 12) ? @"Day" : @"Night"];
    hour = hour % 12;
    NSTimeInterval startTimeInterval = hourDurations[meridian].doubleValue * hour;
    NSDate *startTime                = [[NSDate alloc] initWithTimeInterval:startTimeInterval sinceDate:(transit == Sunrise) ? dates.sunrise : dates.sunset];
    NSTimeInterval endTimeInterval   = hourDurations[meridian].doubleValue * (hour + 1);
    NSDate *endTime                  = [[NSDate alloc] initWithTimeInterval:endTimeInterval sinceDate:(transit == Sunrise) ? dates.sunrise : dates.sunset];
    
    EKEvent *event     = [EKEvent eventWithEventStore:eventStore];
    event.timeZone     = [NSTimeZone localTimeZone];
    event.calendar     = calendar;
    event.title        = [NSString stringWithFormat:@"%@ %@", symbol, name];
    event.availability = EKEventAvailabilityFree;
    event.alarms       = @[[EKAlarm alarmWithAbsoluteDate:startTime]];
    event.location     = [NSString stringWithFormat:@"%f\t%f", coordinate.latitude, coordinate.longitude];
    event.notes        = [NSString stringWithFormat:@"%@", hour_ordinal];
    event.startDate    = startTime;
    event.endDate      = endTime;
    event.allDay       = NO;
    
    return event;
};

- (void)calendarPlanetaryHoursForDate:(nullable NSDate *)date location:(nullable CLLocation *)location completionBlock:(CalendarPlanetaryHourEventsCompletionBlock)completionBlock {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
//        NSLog(@"Request for access to entity type event %@", (granted) ? @"granted" : @"denied");
        if (granted)
        {
//            NSLog(@"Access to event store granted.");
            calendarForEventStore(eventStore, ^(EKCalendar *calendar) {
                FESSolarCalculator *solarCalculation = [self solarCalculationForDate:date location:location];
                NSTimeInterval daySpan = [solarCalculation.sunset timeIntervalSinceDate:solarCalculation.sunrise];
                NSArray<NSNumber *> *durations = hourDurations(daySpan);
                for (long hour = 0; hour < HOURS_PER_DAY; hour++)
                {
                    __autoreleasing NSError *error;
                    if ([eventStore saveEvent:planetaryHourEvent(hour, eventStore, calendar, durations, solarCalculation, location.coordinate) span:EKSpanThisEvent error:&error])
                    {
//                        NSLog(@"Event %lu saved.", (hour + 1));
                    } else {
                        NSLog(@"Error saving event: %@", error.description);
                    }
                }
                completionBlock();
            });
        } else {
            NSLog(@"Access to event store denied: %@", error.description);
        }
    }];
        }

//- (NSArray *)planetaryHoursEventsForDate:(NSDate *)date location:(CLLocation *)location
//{
//    location = (CLLocationCoordinate2DIsValid(location.coordinate)) ? locationManager.location : location;
//    date     = (!date) ? [NSDate date] : date;
//    //cachedSunriseSunsetData(location, date, ^(NSArray<NSDate *> * _Nonnull sunriseSunsetDates) {
//    EDSunriseSet *sunriset = [[EDSunriseSet alloc] initWithDate:date timezone:[NSTimeZone localTimeZone] latitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude];
//    NSLog(@"sunriseset.sunset\t%@\t\tsunriseset.sunrise\t%@", sunriset.sunset, sunriset.sunrise);
//    NSTimeInterval daySpan = [sunriset.sunset timeIntervalSinceDate:sunriset.sunrise];
//    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:24];
//    EKEventStore *eventStore = [[EKEventStore alloc] init];
//    for (long hour = 0; hour < HOURS_PER_DAY; hour++)
//    {
//        [tempArray addObject:planetaryHourEvent(hour, eventStore, nil, hourDurations(daySpan), @[sunriset.sunrise, sunriset.sunset], location)];
//    }
//    
//    return (NSArray *)tempArray;
//}

- (NSArray *)planetaryHoursEventsForDate:(NSDate *)date location:(CLLocation *)location
{
    FESSolarCalculator *solarCalculation = [self solarCalculationForDate:date location:location];
    NSTimeInterval daySpan = [solarCalculation.sunset timeIntervalSinceDate:solarCalculation.sunrise];
    NSArray<NSNumber *> *durations = hourDurations(daySpan);
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:24];
    for (NSInteger hour = 0; hour < 24; hour++)
    {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        EKEvent *event     = planetaryHourEvent(hour, eventStore, nil, durations, solarCalculation, location.coordinate);
        
//        event.calendar     = nil;
//        event.title        = @"title";
//        event.availability = EKEventAvailabilityFree;
//        event.location     = @"location";
//        event.notes        = @"notes";
//        event.startDate    = [NSDate date];
//        event.endDate      = [NSDate dateWithTimeIntervalSinceReferenceDate:86400];
//        event.allDay       = NO;
        
        [tempArray addObject:event];
    }
    
    return (NSArray *)tempArray;
}
//
//void(^planetaryHourEventBlock)(NSUInteger, NSDate * _Nullable, CLLocation * _Nullable, PlanetaryHourEventCompletionBlock) = ^(NSUInteger hour, NSDate * _Nullable date, CLLocation * _Nullable location, PlanetaryHourEventCompletionBlock completionBlock)
//{
//    NSLog(@"EVENT FOR HOUR:\t%lu\n%s", hour + 1, __PRETTY_FUNCTION__);
//    location = (CLLocationCoordinate2DIsValid(location.coordinate)) ? locationManager.location : location;
//    date     = (!date) ? [NSDate date] : date;
//    hour     = hour % 24;
//    cachedSunriseSunsetData(location, date, ^(NSArray<NSDate *> * _Nonnull dates) {
//        EKEventStore *eventStore = [[EKEventStore alloc] init];
//        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
//            if (granted)
//            {
//                calendarForEventStore(eventStore, ^(EKCalendar *calendar) {
//                    NSDateInterval *dateSpan = [[NSDateInterval alloc] initWithStartDate:dates.firstObject endDate:dates.lastObject];
//                    EKEvent *event = planetaryHourEvent(hour, eventStore, calendar, hourDurations(dateSpan), dates, location);
//                    __autoreleasing NSError *error;
//                    if ([eventStore saveEvent:event span:EKSpanThisEvent error:&error])
//                    {
//                        NSLog(@"Event %lu saved.", (hour + 1));
//                        completionBlock(event);
//                    } else {
//                        NSLog(@"Error saving event: %@", error.description);
//                    }
//                });
//            } else {
//                NSLog(@"Access to event store denied: %@", error.description);
//            }
//        }];
//    });
//};


//NSPredicate *predicate = [sut predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
//
//NSArray *events = [sut eventsMatchingPredicate:predicate];
//
//if (events && events.count > 0) {
//
//    NSLog(@"Deleting Events...");
//
//    [events enumerateObjectsUsingBlock:^(EKEvent *event, NSUInteger idx, BOOL *stop) {
//
//        NSLog(@"Removing Event: %@", event);
//        NSError *error;
//        if ( ! [sut removeEvent:event span:EKSpanFutureEvents commit:NO error:&error]) {
//
//            NSLog(@"Error in delete: %@", error);
//
//        }
//
//    }];
//
//    [sut commit:NULL];
//
//} else {
//
//    NSLog(@"No Events to Delete.");
//}

//        solarTransitPeriodData(solarTransitPeriodDataURL(currentLocation), ^(NSArray <NSDate *> *dates) {
//            [self.delegate createEventWithDateSpan:dates location:currentLocation completion:^{
//                self.lastLocation = nil;
//            }];
//        });

- (FESSolarCalculator *)solarCalculationForDate:(NSDate *)date location:(CLLocation *)location
{
    location = (!location) ? self.locationManager.location : location;
    date     = (!date) ? [NSDate date] : date;
    FESSolarCalculator *solarCalculator = [[FESSolarCalculator alloc] initWithDate:date location:location];
    
    NSDate *earlierDate = [solarCalculator.sunrise earlierDate:date];
    if ([earlierDate isEqualToDate:date])
    {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.day = -1;
        NSDate *yesterday = [calendar dateByAddingComponents:components toDate:date options:NSCalendarMatchNextTimePreservingSmallerUnits];
        solarCalculator = [[FESSolarCalculator alloc] initWithDate:yesterday location:location];
    }
    
    return solarCalculator;
}

@end
