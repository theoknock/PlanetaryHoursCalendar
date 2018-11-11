//
//  MKPointAnnotation+MKPointAnnotation_DispatchTimer.m
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 11/6/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "MKPointAnnotation+MKPointAnnotation_DispatchTimer.h"

@implementation MKPointAnnotation (MKPointAnnotation_DispatchTimer)

@dynamic timer, hour, selected;

- (void)setTimer:(dispatch_source_t)timer
{
    objc_setAssociatedObject(self, @selector(timer), timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (dispatch_source_t)timer
{
    return objc_getAssociatedObject(self, @selector(timer));
}

- (void)setHour:(NSNumber *)hour
{
    objc_setAssociatedObject(self, @selector(hour), hour, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)hour
{
    return objc_getAssociatedObject(self, @selector(hour));
}

-(void)setSelected:(NSNumber *)selected
{
    objc_setAssociatedObject(self, @selector(selected), selected, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)selected
{
    return objc_getAssociatedObject(self, @selector(selected));
}

@end
