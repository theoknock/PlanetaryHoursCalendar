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

typedef NSString *(^PlanetSymbol)(Planet planet);
typedef Planet(^PlanetForDay)(NSDate *date);

#define SECONDS_PER_DAY 86400.00f
#define HOURS_PER_SOLAR_TRANSIT 12.0f
#define HOURS_PER_DAY 24.0f
#define NUMBER_OF_PLANETS 7


@interface PlanetaryHourDataSource : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) PlanetSymbol ps;
@property (strong, nonatomic) PlanetForDay pd;
@property (copy) Planet(^PlanetForDay)(NSDate *date);
@property (copy) NSString *(^planetSymbol)(Planet planet);
@property (strong, nonatomic) dispatch_queue_t planetaryHourDataRequestQueue;
@property (class, strong, nonatomic, readonly) NSArray<NSString *> *planetaryHourDataKeys;

//- (void)planetaryHours:(_Nullable NSRangePointer *)hours date:(nullable NSDate *)date location:(nullable CLLocation *)location withCompletion:(void(^)(NSArray<NSDictionary *> *))planetaryHoursData;
//- (void)planetaryHour:(NSUInteger)hour date:(nullable NSDate *)date location:(nullable CLLocation *)location withCompletion:(void(^)(NSDictionary *))planetaryHourData;
//- (void)planetaryHour:(NSUInteger)hour date:(nullable NSDate *)date location:(nullable CLLocation *)location objectForKey:(PlanetaryHourDataKey)planetaryHourDataKey withCompletion:(void(^)(NSString *))planetaryHourDataObject;
//
//@property (copy) NSDictionary *(^planetaryHour)(Planet planet, NSTimeInterval hourDuration, NSUInteger hour, NSDate *start, CLLocationCoordinate2D coordinate);
//@property (copy) void(^currentPlanetaryHour)(CLLocation * _Nullable location, CurrentPlanetaryHourCompletionBlock currentPlanetaryHour);

@property (copy) void(^calendarForEventStore)(EKEventStore *eventStore, CalendarForEventStoreCompletionBlock completionBlock);
@property (copy) void(^calendarPlanetaryHours)(NSDate * _Nullable date, CLLocation * _Nullable location, CalendarPlanetaryHourEventsCompletionBlock completionBlock);
//@property (copy) NSArray *(^planetaryHoursEvents)(NSDate * _Nullable date, CLLocation * _Nullable location);
- (NSArray *)planetaryHoursEventsForDate:(NSDate *)date location:(CLLocation *)location;
@property (copy) void(^planetaryHourEventBlock)(NSUInteger hour, NSDate * _Nullable date, CLLocation * _Nullable location, PlanetaryHourEventCompletionBlock planetaryHourCompletionBlock);

- (void)calendarPlanetaryHoursForDate:(nullable NSDate *)date location:(nullable CLLocation *)location completionBlock:(CalendarPlanetaryHourEventsCompletionBlock)completionBlock;
+ (nonnull PlanetaryHourDataSource *)sharedDataSource;

+ (NSArray<NSString *> *)planetaryHourDataKeys;

@end

NS_ASSUME_NONNULL_END
