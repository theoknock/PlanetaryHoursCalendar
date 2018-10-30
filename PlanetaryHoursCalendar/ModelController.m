//
//  ModelController.m
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 10/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "ModelController.h"
#import "DataViewController.h"
#import "PlanetaryHourDataSource.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


@interface ModelController ()

@property (readonly, strong, nonatomic) NSArray<EKEvent *> *events;
@end

@implementation ModelController

EKCalendar * _Nullable (^planetaryHourCalendar)(EKEventStore *) = ^(EKEventStore *eventStore)
{
    printf("\n%s\n", __PRETTY_FUNCTION__);
    
    __block EKCalendar *calendar = NULL;
    
    EKEventStore *es = [[EKEventStore alloc] init];
    NSArray <EKCalendar *> *calendars = [es calendarsForEntityType:EKEntityTypeEvent];
    [calendars enumerateObjectsUsingBlock:^(EKCalendar * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.title isEqualToString:@"Planetary Hour"]) {
            NSLog(@"Planetary Hour calendar found.");
            calendar = obj;
            *stop = TRUE;
        } else {
            
        }
    }];
    
    return calendar;
    
//    if (calendar == nil)
//    {
//        calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:eventStore];
//        calendar.title = @"Planetary Hour";
//        calendar.source = eventStore.sources[1];
//    } else {
//        calendar = [eventStore defaultCalendarForNewEvents];
//    }
//
//    __autoreleasing NSError *error;
//    if ([eventStore saveCalendar:calendar commit:YES error:&error])
//    {
//        return calendar;
//    } else {
//        NSLog(@"Error saving new calendar: %@\nUsing default calendar for new events...", error.localizedDescription);
//        return [eventStore defaultCalendarForNewEvents];
//    }
};


- (instancetype)init {
    self = [super init];
    if (self) {
        // Create the data model.
        _events = [PlanetaryHourDataSource.sharedDataSource planetaryHoursEventsForDate:nil location:nil];
        
    }
    return self;
}

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    // Return the data view controller for the given index.
    if (([self.events count] == 0) || (index >= [self.events count])) {
        return nil;
    }

    // Create a new view controller and pass suitable data.
    DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
    dataViewController.dataObject = self.events[index];
    return dataViewController;
}


- (NSUInteger)indexOfViewController:(DataViewController *)viewController {
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return [self.events indexOfObject:viewController.dataObject];
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.events count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
