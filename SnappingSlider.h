//
//  SnappingSlider.h
//  Obscura
//
//  Created by James Bush on 6/9/18.
//  Copyright © 2018 James Bush. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SnappingSliderDelegate <NSObject>

- (void)snappingSliderDidIncrementValue:(UISlider *)snappingSlider;
- (void)snappingSliderDidDecrementValue:(UISlider *)snappingSlider;

@end

typedef UIDynamicAnimator *_Nonnull(^SnapBehavior)(UIView *dynamicItem, CGPoint snappingPoint, UIDynamicAnimator *dynamicAnimator);

@interface SnappingSlider : UIView <UIDynamicItem>
{
    UIView *sliderContainer;
    UILabel *minusLabel;
    UILabel *plusLabel;
    UIView *sliderView;
    UILabel *sliderViewLabel;
    
    BOOL dragged;
    BOOL isCurrentDraggingSlider;
    CGFloat lastDelegateFireOffset;
    CGPoint touchesBeganPoint;
    NSTimer *valueChangingTimer;
    
    UIPanGestureRecognizer *sliderPanGestureRecogniser;
    UIDynamicAnimator *dynamicButtonAnimator;
    UIDynamicBehavior *dynamicBehavior;

    CGPoint snappingPoint;
    CGPoint center_point;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

@property (weak) id<SnappingSliderDelegate>delegate;
@property BOOL shouldContinueAlteringValueUntilGestureCancels;
@property (strong, nonatomic) UIFont *incrementAndDecrementLabelFont;
@property (strong, nonatomic) UIColor *incrementAndDecrementLabelTextColor;
@property (strong, nonatomic) UIColor *incrementAndDecrementBackgroundColor;
@property (strong, nonatomic) UIColor *sliderColor;
@property (strong, nonatomic) UIFont *sliderTitleFont;
@property (strong, nonatomic) UIColor *sliderTitleColor;
@property (strong, nonatomic) NSString *sliderTitleText;
@property CGFloat sliderCornerRadius;

@end

NS_ASSUME_NONNULL_END

