//
//  DateTimePickerViewController.h
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 11/13/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DateTimePickerViewControllerDelegate <NSObject>

@required
- (void)datePickerDidChange:(NSDate *)date;
- (void)timePickerDidChange:(NSTimeInterval)time;
- (NSDate *)pickerDate;
- (NSTimeInterval)pickerTime;

@end

@interface DateTimePickerViewController : UIViewController

@property (weak) id<DateTimePickerViewControllerDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePickerView;
@property (assign, nonatomic, setter=setPickerDate:) NSDate *pickerDate;
@property (assign, nonatomic, setter=setPickerTime:) NSTimeInterval pickerTime;

@end

NS_ASSUME_NONNULL_END
