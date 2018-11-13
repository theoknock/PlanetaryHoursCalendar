//
//  PlanetaryHourDataSource.h
//  JBPlanetaryHourCalculator
//
//  Created by Xcode Developer on 10/23/18.
//  Copyright © 2018 Xcode Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, Planet) {
    Sun,
    Moon,
    Mars,
    Mercury,
    Jupiter,
    Venus,
    Saturn
};

typedef NS_ENUM(NSUInteger, Day) {
    SUN,
    MON,
    TUE,
    WED,
    THU,
    FRI,
    SAT
};

typedef NS_ENUM(NSUInteger, Meridian) {
    AM,
    PM
};

typedef NS_ENUM(NSUInteger, SolarTransit) {
    Sunrise,
    Sunset
};

typedef NS_ENUM(NSUInteger, PlanetaryHourDataKey) {
    PlanetaryHourSymbolDataKey,
    PlanetaryHourNameDataKey,
    PlanetaryHourBeginDataKey,
    PlanetaryHourEndDataKey,
    PlanetaryHourLocationDataKey
};

typedef void(^CachedSunriseSunsetDataWithCompletionBlock)(NSArray<NSDate *> *sunriseSunsetDates);
typedef void(^CachedSunriseSunsetData)(CLLocation * _Nullable, NSDate  * _Nullable , CachedSunriseSunsetDataWithCompletionBlock);

//typedef void(^CurrentPlanetaryHourCompletionBlock)(NSDictionary *currentPlanetaryHour);
//typedef void(^CurrentPlanetaryHourBlock)(CLLocation * _Nullable location, CurrentPlanetaryHourCompletionBlock currentPlanetaryHour);

typedef void(^CalendarForEventStoreCompletionBlock)(EKCalendar *calendar);
typedef void(^CalendarForEventStore)(EKEventStore *eventStore, CalendarForEventStoreCompletionBlock completionBlock);
typedef void(^CalendarPlanetaryHourEventsCompletionBlock)(void);
typedef void(^CalendarPlanetaryHours)(NSArray <NSDate *> *dates, CLLocation *location, CalendarPlanetaryHourEventsCompletionBlock completionBlock);

//typedef NSDictionary *(^PlanetaryHourCompletionBlock)(NSDictionary *planetaryHour);
//typedef void(^PlanetaryHourEvent)(NSUInteger hour, NSArray <NSDate *> *dates, CLLocation *location, PlanetaryHourCompletionBlock completionBlock);

typedef void(^PlanetaryHourEventCompletionBlock)(EKEvent *planetaryHourEvent);
typedef NSDictionary *(^PlanetaryHourEventBlock)(NSUInteger hour, NSDate * _Nullable date, CLLocation * _Nullable location, PlanetaryHourEventCompletionBlock planetaryHourEventCompletionBlock);

typedef NSString *(^PlanetSymbolForDay)(NSDate * _Nullable date);
typedef NSString *(^PlanetSymbolForHour)(NSDate * _Nullable date, NSUInteger hour);
typedef NSString *(^PlanetSymbolForPlanet)(Planet planet);
typedef NSString *(^PlanetNameForDay)(NSDate * _Nullable date);
typedef NSString *(^PlanetNameForHour)(NSDate * _Nullable date, NSUInteger hour);

typedef CLLocation *(^PlanetaryHourLocation)(CLLocation * _Nullable location, NSDate * _Nullable date, NSUInteger hour);

//typedef NSArray<NSNumber *> *(^HourDurations)(NSTimeInterval daySpan);

#define SECONDS_PER_DAY 86400.00f
#define HOURS_PER_SOLAR_TRANSIT 12.0f
#define HOURS_PER_DAY 24
#define NUMBER_OF_PLANETS 7


@interface PlanetaryHourDataSource : NSObject <CLLocationManagerDelegate>

+ (nonnull PlanetaryHourDataSource *)sharedDataSource;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSDateFormatter *RFC3339DateFormatter;

//@property (strong, nonatomic) HourDurations hd;
//@property (copy) Planet(^PlanetForDay)(NSDate *date);
@property (copy) NSString *(^planetSymbolForDay)(NSDate * _Nullable date);
@property (copy) NSString *(^planetSymbolForHour)(NSDate * _Nullable date, NSUInteger hour);
@property (copy) NSString *(^planetSymbolForPlanet)(Planet planet);
@property (copy) NSString *(^planetNameForDay)(NSDate * _Nullable date);
@property (copy) NSString *(^planetNameForHour)(NSDate * _Nullable date, NSUInteger hour);
@property (copy) CLLocation *(^planetaryHourLocation)(CLLocation * _Nullable location, NSDate * _Nullable date, NSUInteger hour);
//@property (copy) NSArray<NSNumber *> *(^hourDurations)(NSTimeInterval daySpan);
@property (strong, nonatomic) dispatch_queue_t planetaryHourDataRequestQueue;

//- (void)planetaryHours:(_Nullable NSRangePointer *)hours date:(nullable NSDate *)date location:(nullable CLLocation *)location withCompletion:(void(^)(NSArray<NSDictionary *> *))planetaryHoursData;
//- (void)planetaryHour:(NSUInteger)hour date:(nullable NSDate *)date location:(nullable CLLocation *)location withCompletion:(void(^)(NSDictionary *))planetaryHourData;
//- (void)planetaryHour:(NSUInteger)hour date:(nullable NSDate *)date location:(nullable CLLocation *)location objectForKey:(PlanetaryHourDataKey)planetaryHourDataKey withCompletion:(void(^)(NSString *))planetaryHourDataObject;
//
//@property (copy) NSDictionary *(^planetaryHour)(Planet planet, NSTimeInterval hourDuration, NSUInteger hour, NSDate *start, CLLocationCoordinate2D coordinate);
//@property (copy) void(^currentPlanetaryHour)(CLLocation * _Nullable location, CurrentPlanetaryHourCompletionBlock currentPlanetaryHour);

@property (copy) void(^calendarForEventStore)(EKEventStore *eventStore, CalendarForEventStoreCompletionBlock completionBlock);
@property (copy) void(^calendarPlanetaryHours)(NSDate * _Nullable date, CLLocation * _Nullable location, CalendarPlanetaryHourEventsCompletionBlock completionBlock);
//@property (copy) NSArray *(^planetaryHoursEvents)(NSDate * _Nullable date, CLLocation * _Nullable location);
- (NSArray *)planetaryHoursEventsForDate:(nullable NSDate *)date location:(nullable CLLocation *)location;
@property (copy) void(^planetaryHourEventBlock)(NSUInteger hour, NSDate * _Nullable date, CLLocation * _Nullable location, PlanetaryHourEventCompletionBlock planetaryHourCompletionBlock);

- (void)calendarPlanetaryHoursForDate:(nullable NSDate *)date location:(nullable CLLocation *)location completionBlock:(CalendarPlanetaryHourEventsCompletionBlock)completionBlock;

+ (NSArray<NSString *> *)planetaryHourDataKeys;

@end

NS_ASSUME_NONNULL_END
