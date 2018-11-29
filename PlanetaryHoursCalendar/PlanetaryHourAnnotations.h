//
//  PlanetaryHourAnnotations.h
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 11/27/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

typedef CLLocationCoordinate2D(^UpdateLocation)(NSDate *date);

@interface MKPointAnnotation (MKPointAnnotation_PlanetaryHour)

- (instancetype)initWithPlanetaryHour:(NSInteger)hour;

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong, readonly) NSNumber *planetaryHour;
@property (nonatomic, strong) UpdateLocation updateLocationBlock;

@end

@interface PlanetaryHourAnnotations : NSArray<MKPointAnnotation *>
{
    dispatch_queue_t timerQueue;
    NSArray *annotationPool;
}

+ (nonnull PlanetaryHourAnnotations *)annotationsForLocation:(CLLocation *)location;

@property(readonly) NSUInteger count;
- (MKPointAnnotation *)objectAtIndex:(NSUInteger)index;

@property(readonly) double metersPerDayHour;
- (void)setMetersPerDayHour:(double)metersPerDayHour;
@property(readonly) double metersPerNightHour;
- (void)setMetersPerNightHour:(double)metersPerNightHour;
@property(assign, nonatomic, setter=setUserLocation:) CLLocation *userLocation;
@property(readonly) NSDate *sunrise;
- (void)setSunrise:(NSDate * _Nonnull)sunrise;
- (NSTimeInterval)elapsedTime:(NSDate *)date;
@end

NS_ASSUME_NONNULL_END
