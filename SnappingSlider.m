//
//  SnappingSlider.m
//  Obscura
//
//  Created by James Bush on 6/9/18.
//  Copyright © 2018 James Bush. All rights reserved.
//

#import "SnappingSlider.h"
#import "PlanetaryHourAnnotations.h"

@implementation SnappingSlider

static UIDynamicAnimator *(^dynamicAnimator)(UIView *, CGPoint, UIDynamicAnimator *) = ^(UIView *dynamicItem, CGPoint snappingPoint, UIDynamicAnimator *dynamicButtonAnimator) {
    [dynamicButtonAnimator removeAllBehaviors];
    
    UISnapBehavior *sb = [[UISnapBehavior alloc] initWithItem:dynamicItem snapToPoint:snappingPoint];
    [sb setDamping:0.25];
    
    
    UIDynamicItemBehavior *dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[dynamicItem]];
    [dynamicItemBehavior setAllowsRotation:FALSE];
    
    UIDynamicBehavior *db = [[UIDynamicBehavior alloc] init];
    [db addChildBehavior:sb];
    [db addChildBehavior:dynamicItemBehavior];
    
    [dynamicButtonAnimator addBehavior:db];
    
    return dynamicButtonAnimator;
};

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title
{
    if (self == [super initWithFrame:frame])
    {
        [self setup];
        [self setNeedsLayout];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self == [super initWithCoder:aDecoder])
    {
        [self setup];
        [self setNeedsLayout];
    }
    
    return self;
}

- (void)setup
{
    sliderValueChangesQueue = dispatch_queue_create_with_target("Slider Value Changes Queue", DISPATCH_QUEUE_CONCURRENT, dispatch_get_main_queue());
    self.incrementAndDecrementLabelFont = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18.0];
    self.incrementAndDecrementLabelTextColor = [UIColor whiteColor];
    self.incrementAndDecrementBackgroundColor = [UIColor colorWithRed:0.36 green:0.65 blue:0.65 alpha:1.0];
    self.sliderColor = [UIColor colorWithRed:0.42 green:0.76 blue:0.74 alpha:1];
    self.sliderTitleFont = [UIFont fontWithName:@"TrebuchetMS-Bold" size: 15.0];
    self.sliderTitleColor = [UIColor whiteColor];
    self.sliderTitleText = @"";
    self.sliderCornerRadius = 3.0;
    
    sliderContainer = [[UIView alloc] initWithFrame:CGRectZero];
    minusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    plusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    sliderView = [[UIView alloc] initWithFrame:CGRectZero];
    sliderViewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    touchesBeganPoint = CGPointZero;
    
    sliderPanGestureRecogniser = [UIPanGestureRecognizer new];
    
    [sliderContainer setBackgroundColor:self.backgroundColor];
    
    minusLabel.text = @"-";
    minusLabel.textAlignment = NSTextAlignmentCenter;
    [sliderContainer addSubview:minusLabel];
    
    plusLabel.text = @"+";
    plusLabel.textAlignment = NSTextAlignmentCenter;
    [sliderContainer addSubview:plusLabel];
    
    [sliderContainer addSubview:sliderView];
    
    sliderViewLabel.userInteractionEnabled = FALSE;
    sliderViewLabel.textAlignment = NSTextAlignmentCenter;
    sliderViewLabel.textColor = self.sliderTitleColor;
    [sliderView addSubview:sliderViewLabel];
    
    [sliderPanGestureRecogniser addTarget:self action:@selector(handleGesture:)];
    [sliderView addGestureRecognizer:sliderPanGestureRecogniser];
    
    center_point = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    sliderContainer.center = center_point;
    [self addSubview:sliderContainer];
    self.clipsToBounds = TRUE;
    
    dynamicButtonAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    snappingPoint = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
}



- (void)layoutSubviews
{
    [super layoutSubviews];

    sliderContainer.frame = self.frame;
    sliderContainer.center = center_point;
    sliderContainer.backgroundColor = self.incrementAndDecrementBackgroundColor;
    
    CGRect minusLabel_frame = CGRectMake(0.0, 0.0, self.bounds.size.width * 0.25, self.bounds.size.height);
    minusLabel.frame = minusLabel_frame;
    CGPoint minusLabel_center = CGPointMake(CGRectGetMidX(minusLabel.bounds), CGRectGetMidY(minusLabel.bounds));
    minusLabel.center = minusLabel_center;
    minusLabel.backgroundColor = self.incrementAndDecrementBackgroundColor;
    minusLabel.font = self.incrementAndDecrementLabelFont;
    minusLabel.textColor = self.incrementAndDecrementLabelTextColor;
        
    plusLabel.frame = minusLabel_frame;
    CGPoint plusLabel_center = CGPointMake(self.bounds.size.width - plusLabel.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    plusLabel.center = plusLabel_center;
    plusLabel.backgroundColor = self.incrementAndDecrementBackgroundColor;
    plusLabel.font = self.incrementAndDecrementLabelFont;
    plusLabel.textColor = self.incrementAndDecrementLabelTextColor;
    
    CGRect sliderView_frame = CGRectMake(0.0, 0.0, CGRectGetMidX(self.bounds), self.bounds.size.height);
    sliderView.frame = sliderView_frame;
    sliderView.center = center_point;
    sliderView.backgroundColor = self.sliderColor;
        
    CGRect sliderViewLabel_frame = CGRectMake(0.0, 0.0, CGRectGetWidth(sliderView.bounds), CGRectGetHeight(sliderView.bounds));
    sliderViewLabel.frame = sliderViewLabel_frame;
    CGPoint sliderViewLabel_center = CGPointMake(CGRectGetMidX(sliderViewLabel.bounds), CGRectGetMidY(sliderViewLabel.bounds));
    sliderViewLabel.center = sliderViewLabel_center;
    sliderViewLabel.backgroundColor = self.sliderColor;
    sliderViewLabel.font = self.sliderTitleFont;
    sliderViewLabel.text = self.sliderTitleText;
        
    self.layer.cornerRadius = self.sliderCornerRadius;

    if (snappingPoint.x != self.center.x)
    {
        dynamicButtonAnimator = dynamicAnimator(sliderView, snappingPoint, dynamicButtonAnimator);
    }
}

- (IBAction)handleGesture:(UIPanGestureRecognizer *)sender
{
        if ([sender isKindOfClass:[UIPanGestureRecognizer class]])
        {
           switch (sender.state) {
                case UIGestureRecognizerStateBegan:
                {
                    dragged = TRUE;
                    isCurrentDraggingSlider = TRUE;
                    touchesBeganPoint = [sliderPanGestureRecogniser translationInView:sliderView];
                    [dynamicButtonAnimator removeAllBehaviors];
                    lastDelegateFireOffset = (self.bounds.size.width * 0.5) + ((touchesBeganPoint.x + touchesBeganPoint.x) * 0.40);
                    
                    break;
                }
                    
                case UIGestureRecognizerStateChanged:
                {
                    [valueChangingTimer invalidate];
                    
                    CGPoint translationInView = [sliderPanGestureRecogniser translationInView:sliderView];
                    CGFloat translatedCenterX = (self.bounds.size.width * 0.5) + ((touchesBeganPoint.x + translationInView.x) * 0.40);
                    sliderView.center = CGPointMake(translatedCenterX, sliderView.center.y);
                    
                    if (translatedCenterX < lastDelegateFireOffset) {
                        
                        if (fabs(lastDelegateFireOffset - translatedCenterX) >= (sliderView.bounds.size.width * 0.15)) {
                            
                            if (dragged)
                            {
                                [self.delegate snappingSliderDidDecrementValue:self];
                                lastDelegateFireOffset = translatedCenterX;
                                dragged = self.shouldContinueAlteringValueUntilGestureCancels;
                            }
                        }
                    }
                    else {
                        
                        if (fabs(lastDelegateFireOffset - translatedCenterX) >= (sliderView.bounds.size.width * 0.15)) {
                            
                            if (dragged)
                            {
                                [self.delegate snappingSliderDidIncrementValue:self];
                                lastDelegateFireOffset = translatedCenterX;
                                dragged = self.shouldContinueAlteringValueUntilGestureCancels;
                            }
                        }
                    }
                    
                    if (self.shouldContinueAlteringValueUntilGestureCancels) {
                        if (translatedCenterX < lastDelegateFireOffset)
                            dispatch_async(sliderValueChangesQueue, ^{
                              [self.delegate snappingSliderDidDecrementValue:self];
                            });
                        else
                            dispatch_async(sliderValueChangesQueue, ^{
                                [self.delegate snappingSliderDidIncrementValue:self];
                            });
//                        valueChangingTimer = [NSTimer timerWithTimeInterval:0.7 target:self selector:@selector(handleTimer:) userInfo:nil repeats:TRUE];
                    }
                    
                    break;
                }
                    
                case UIGestureRecognizerStateEnded:
                {
                    dynamicButtonAnimator = dynamicAnimator(sliderView, snappingPoint, dynamicButtonAnimator);
                    
                    isCurrentDraggingSlider = FALSE;
                    lastDelegateFireOffset = self.center.x;
                    [valueChangingTimer invalidate];
                    
                    break;
                }
                    
                case UIGestureRecognizerStateFailed:
                {
                    break;
                }
                    
                case UIGestureRecognizerStateCancelled:
                {
                    break;
                }
                    
                case UIGestureRecognizerStatePossible:
                {
                    break;
                }
                    
                default:
                    break;
            }
        }
}
    
- (void)handleTimer:(NSTimer *)timer
{
    if (CGRectGetMidX(sliderView.frame) > CGRectGetMidX(self.bounds))
    {
        [self.delegate snappingSliderDidIncrementValue:self];
    } else {
        [self.delegate snappingSliderDidDecrementValue:self];
    }
}

@end
