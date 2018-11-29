//
//  MKPointAnnotation+MKPointAnnotation_DispatchTimer.h
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 11/6/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <objc/runtime.h>
#import "PlanetaryHourDataSource.h"
#import "FESSolarCalculator.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKPointAnnotation (MKPointAnnotation_DispatchTimer)

- (instancetype)initWithPlanetaryHour:(NSInteger)hour updateLocationUsingBlock:(dispatch_block_t)updateLocationBlock;

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) NSNumber *planetaryHour;
@property (nonatomic, strong) CLLocation *sunriseLocation;
@property (nonatomic, strong) FESSolarCalculator *solarCalculation;
@property (nonatomic, strong) dispatch_block_t updateLocationBlock;

@end

NS_ASSUME_NONNULL_END
