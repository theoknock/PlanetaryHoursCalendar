//
//  MKPointAnnotation+MKPointAnnotation_DispatchTimer.m
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 11/6/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "MKPointAnnotation+MKPointAnnotation_DispatchTimer.h"

@implementation MKPointAnnotation (MKPointAnnotation_DispatchTimer)

@dynamic timer, planetaryHour;

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

@end
