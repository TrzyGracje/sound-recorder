//
//  SRMainViewController.m
//  Sound Recorder
//
//  Created by Lukasz Komorowski on 29.05.2016.
//  Copyright © 2016 Lukasz Komorowski. All rights reserved.
//

#import "SRMainViewController.h"
#import "SRRecordingHelper.h"
#import "UIButton+BackgroundColor.h"
#import "UIColor+CustomColors.h"
#import "UIView+Shortcuts.h"

static int recordingDuration = 20;

@interface SRMainViewController ()

@property (weak, nonatomic) IBOutlet UIView *recordingExternalView;
@property (weak, nonatomic) IBOutlet UIButton *recordingInternalView;
@property (weak, nonatomic) IBOutlet UIStackView *timeLeftStackView;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordingExternalViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordingInternalViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordingViewVerticalMargin;

@property (strong, nonatomic) NSTimer *timeLeftTimer;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSDate *benchmarking;
@property (strong, nonatomic) SRRecordingHelper *recordingHelper;

@end

@implementation SRMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self.recordingHelper setupRecording];
}

- (void)dealloc {
    [self stopRecording];
}

#pragma mark - UI

- (void)setupUI {
    CGFloat recordingExternalViewTargetWidth = MIN(self.view.width, self.view.height) / 3.0;
    CGFloat recordingViewRingBorderWidth = self.recordingExternalViewWidth.constant - self.recordingInternalViewWidth.constant;

    self.recordingExternalViewWidth.constant = recordingExternalViewTargetWidth;
    self.recordingInternalViewWidth.constant = recordingExternalViewTargetWidth - recordingViewRingBorderWidth;
    [self.view.subviews makeObjectsPerformSelector:@selector(layoutIfNeeded)];

    self.recordingExternalView.layer.cornerRadius = self.recordingExternalViewWidth.constant / 2.0;
    self.recordingExternalView.layer.borderColor = [UIColor santasGrayColor].CGColor;
    self.recordingExternalView.layer.borderWidth = 1.0;

    self.recordingInternalView.layer.cornerRadius = (self.recordingExternalViewWidth.constant - 10.0) / 2.0;
    [self.recordingInternalView setBackgroundColor:[UIColor redOrangeColor] forState:UIControlStateNormal];

    self.timeLeftStackView.alpha = 0.0;

    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = 1;
    numberFormatter.minimumFractionDigits = 1;
    self.timeLeftValueLabel.text = [numberFormatter stringFromNumber:@(recordingDuration)];
}

#pragma mark - recording

- (void)startRecording {
    [self.recordingHelper startRecording];
    [self startTimer];
}

- (void)stopRecording {
    [self stopTimer];
    [self.recordingHelper stopRecording];
}

#pragma timer

- (void)startTimer {
    [self stopTimer];

    self.startDate = [NSDate date];
    self.timeLeftTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                          target:self
                                                        selector:@selector(updateTimer)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void)updateTimer {
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.startDate];
    NSTimeInterval timeIntervalCountDown = recordingDuration - timeInterval;
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeIntervalCountDown];
    NSLog(@"%.1f", timeIntervalCountDown);
    NSString *timeString = [self.dateFormatter stringFromDate:timerDate];
    self.timeLeftValueLabel.text = (timeIntervalCountDown <= 0) ? @"0.0" : timeString;

    if (timeIntervalCountDown <= 0) {
        [self stopRecording];
        NSLog(@"Time: %f", -[self.benchmarking timeIntervalSinceNow]);
    }
}

- (void)stopTimer {
    if (self.timeLeftTimer) {
        [self.timeLeftTimer invalidate];
        self.timeLeftTimer = nil;
    }
}

#pragma mark - actions

- (IBAction)recordClicked:(UIButton *)sender {
    self.benchmarking = [NSDate date];
    [self fireStartAnimation];
}

#pragma mark - animations

- (void)fireStartAnimation {
    CFTimeInterval animationDuration = 0.3;
    [UIView animateWithDuration:animationDuration
        animations:^{
          self.recordingExternalViewWidth.constant = MIN(self.view.width, self.view.height) / 1.5;
          self.recordingInternalViewWidth.constant = 0;
          [self.view layoutIfNeeded];

          self.recordingInternalView.alpha = 0.0;
          self.infoLabel.alpha = 0.0;
          self.timeLeftStackView.alpha = 1.0;
        }
        completion:^(BOOL finished) {
          self.recordingExternalView.layer.borderWidth = 0;
          [self drawCircle];
          [self startRecording];
        }];

    [self animateChangeOfCornerRadius:self.recordingExternalViewWidth.constant / 2.0
                              forView:self.recordingExternalView
                         withDuration:animationDuration];

    [self animateChangeOfBorderWidth:1.5
                             forView:self.recordingExternalView
                        withDuration:animationDuration];

    //    [self animateChangeOfBorderColor:[UIColor redOrangeColor]
    //                             forView:self.recordingExternalView
    //                        withDuration:animationDuration];

    [self animateChangeOfCornerRadius:0
                              forView:self.recordingInternalView
                         withDuration:animationDuration];
}

- (void)animateChangeOfCornerRadius:(CGFloat)cornerRadius forView:(UIView *)view withDuration:(CFTimeInterval)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:view.layer.cornerRadius];
    animation.toValue = [NSNumber numberWithFloat:cornerRadius];
    animation.duration = duration;

    view.layer.cornerRadius = cornerRadius;
    [view.layer addAnimation:animation forKey:@"cornerRadius"];
}

- (void)animateChangeOfBorderWidth:(CGFloat)borderWidth forView:(UIView *)view withDuration:(CFTimeInterval)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = (id) @(view.layer.borderWidth);
    animation.toValue = (id) @(borderWidth);
    animation.duration = duration;

    view.layer.borderWidth = borderWidth;
    [view.layer addAnimation:animation forKey:@"borderWidth"];
}

//- (void)animateChangeOfBorderColor:(UIColor *)borderColor forView:(UIView *)view withDuration:(CFTimeInterval)duration {
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    animation.fromValue = (id)view.layer.borderColor;
//    animation.toValue = (id)borderColor.CGColor;
//    animation.duration = duration;
//
//    view.layer.borderColor = borderColor.CGColor;
//    [view.layer addAnimation:animation forKey:@"borderColor"];
//}

- (void)drawCircle {
    CAShapeLayer *circle = [CAShapeLayer layer];
    CGFloat circleRadius = self.recordingExternalViewWidth.constant;
    CGRect circleLayerFrame = CGRectMake(0, 0, circleRadius, circleRadius);
    circle.path = [UIBezierPath bezierPathWithRoundedRect:circleLayerFrame cornerRadius:circleRadius / 2.0].CGPath;
    circle.strokeColor = [UIColor santasGrayColor].CGColor;
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.lineWidth = 1.5;
    circle.strokeStart = 1.0;

    [self.recordingExternalView.layer addSublayer:circle];

    [CATransaction begin];
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    drawAnimation.duration = recordingDuration;
    drawAnimation.repeatCount = 1.0;
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    drawAnimation.toValue = [NSNumber numberWithFloat:1.0];
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    [CATransaction setCompletionBlock:^{
        //      stop recording ??
    }];

    [circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    [CATransaction commit];
}

#pragma mark - getters / setters

- (SRRecordingHelper *)recordingHelper {
    if (_recordingHelper == nil) {
        _recordingHelper = [SRRecordingHelper sharedInstance];
    }
    return _recordingHelper;
}

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.dateFormat = @"s.S";
    }
    return _dateFormatter;
}

@end
