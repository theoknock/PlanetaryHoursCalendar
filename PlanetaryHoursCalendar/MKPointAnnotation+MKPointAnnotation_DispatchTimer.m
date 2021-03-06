//
//  MKPointAnnotation+MKPointAnnotation_DispatchTimer.m
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 11/6/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "MKPointAnnotation+MKPointAnnotation_DispatchTimer.h"

@implementation MKPointAnnotation (MKPointAnnotation_DispatchTimer)

- (instancetype)initWithPlanetaryHour:(NSInteger)hour updateLocationUsingBlock:(dispatch_block_t)updateLocationBlock
{
    if (self == [super init])
    {
        [self setPlanetaryHour:[NSNumber numberWithInteger:hour]];
        [self setUpdateLocationBlock:updateLocationBlock];
    }
    
    return self;
}

@dynamic timer, planetaryHour, sunriseLocation, solarCalculation, updateLocationBlock;

- (void)setTimer:(dispatch_source_t)timer
{
    objc_setAssociatedObject(self, @selector(timer), timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (dispatch_source_t)timer
{
    return objc_getAssociatedObject(self, @selector(timer));
}

- (void)setPlanetaryHour:(NSNumber *)planetaryHour
{
    objc_setAssociatedObject(self, @selector(planetaryHour), planetaryHour, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)planetaryHour
{
    return objc_getAssociatedObject(self, @selector(planetaryHour));
}

- (void)setSunriseLocation:(CLLocation *)sunriseLocation
{
    objc_setAssociatedObject(self, @selector(sunriseLocation), sunriseLocation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CLLocation *)sunriseLocation
{
    return objc_getAssociatedObject(self, @selector(sunriseLocation));
}

- (void)setSolarCalculation:(FESSolarCalculator *)solarCalculation
{
    objc_setAssociatedObject(self, @selector(solarCalculation), solarCalculation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FESSolarCalculator *)solarCalculation
{
    return objc_getAssociatedObject(self, @selector(solarCalculation));
}

- (void)setUpdateLocationBlock:(dispatch_block_t)updateLocationBlock
{
    objc_setAssociatedObject(self, @selector(updateLocationBlock), updateLocationBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (dispatch_block_t)updateLocationBlock
{
    return objc_getAssociatedObject(self, @selector(updateLocationBlock));
}

@end
