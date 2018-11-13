//
//  ModelController.h
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 10/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@protocol DateTimePickerViewControllerDelegate <NSObject>

- (void)dateTimePickerDidChangeDate:(NSTimeInterval)time;

@end

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

@property (readonly, strong, nonatomic) NSArray<EKEvent *> *events;
@property (weak) id<DateTimePickerViewControllerDelegate>delegate;

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end

