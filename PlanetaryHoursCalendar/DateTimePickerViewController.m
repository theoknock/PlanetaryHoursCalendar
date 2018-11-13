//
//  DateTimePickerViewController.m
//  PlanetaryHoursCalendar
//
//  Created by Xcode Developer on 11/13/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "DateTimePickerViewController.h"

@interface DateTimePickerViewController ()

@end

@implementation DateTimePickerViewController

@synthesize pickerDate = _pickerDate, pickerTime = _pickerTime;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addObserver:self forKeyPath:@"pickerDate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
    [self addObserver:self forKeyPath:@"pickerTime" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"pickerDate"])
    {
        [self.datePickerView setDate:_pickerDate animated:TRUE];
    } else if ([keyPath isEqualToString:@"pickerTime"])
    {
        
    }
}

- (IBAction)dateDidChange:(id)sender {
    [self.delegate datePickerDidChange:[self pickerDate]];
}

- (IBAction)timeDidChange:(id)sender {
    [self.delegate timePickerDidChange:[self.timePickerView.date timeIntervalSinceDate:self.datePickerView.date]];
}

- (void)setPickerDate:(NSDate *)pickerDate
{
    _pickerDate = pickerDate;
}

- (NSDate *)pickerDate
{
    return _pickerDate;
}

- (void)setPickerTime:(NSTimeInterval)pickerTime
{
    _pickerTime = pickerTime;
}

- (NSTimeInterval)pickerTime
{
    return [self.datePickerView.date timeIntervalSinceDate:[self.timePickerView date]];
}

@end
