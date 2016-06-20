//
//  SRMainViewController.m
//  Sound Recorder
//
//  Created by Lukasz Komorowski on 29.05.2016.
//  Copyright © 2016 Lukasz Komorowski. All rights reserved.
//

#import "SRMainViewController.h"
#import "SRRecordingHelper.h"
#import "SRStorageHelper.h"
#import "SRStorageHelper.h"
#import "UIButton+BackgroundColor.h"
#import "UIColor+CustomColors.h"
#import "UIView+Shortcuts.h"

static int recordingDuration = 4;

@interface SRMainViewController ()<SRRecordinghelperDelegate>

@property (weak, nonatomic) IBOutlet UIView *recordingExternalView;
@property (weak, nonatomic) IBOutlet UIButton *recordingInternalView;
@property (weak, nonatomic) IBOutlet UIStackView *timeLeftStackView;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadingLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordingExternalViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordingInternalViewWidth;

@property (strong, nonatomic) NSTimer *timeLeftTimer;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) SRRecordingHelper *recordingHelper;

@end

@implementation SRMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupRecordingHelper];
}

- (void)dealloc {
    [self stopRecording];
}

#pragma mark - UI

- (void)setupUI {
    CGFloat divider = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 5.0 : 3.0;
    CGFloat recordingExternalViewTargetWidth = MIN(self.view.width, self.view.height) / divider;
    self.recordingExternalViewWidth.constant = recordingExternalViewTargetWidth;
    self.recordingInternalViewWidth.constant = recordingExternalViewTargetWidth - 10; // 10 is the margin between internal and external view
    [self.view.subviews makeObjectsPerformSelector:@selector(layoutIfNeeded)];

    self.recordingExternalView.layer.cornerRadius = self.recordingExternalViewWidth.constant / 2.0;
    self.recordingExternalView.layer.borderColor = [UIColor santasGrayColor].CGColor;
    self.recordingExternalView.layer.borderWidth = 1.0;

    self.recordingInternalView.layer.cornerRadius = (self.recordingExternalViewWidth.constant - 10.0) / 2.0;
    [self.recordingInternalView setBackgroundColor:[UIColor redOrangeColor] forState:UIControlStateNormal];

    self.timeLeftStackView.alpha = 0.0;
    self.uploadingLabel.alpha = 0.0;

    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = 1;
    numberFormatter.minimumFractionDigits = 1;
    numberFormatter.decimalSeparator = @".";
    self.timeLeftValueLabel.text = [numberFormatter stringFromNumber:@(recordingDuration)];
}

- (void)restoreInitialUIState {
    [self.uploadingLabel.layer removeAllAnimations];
    [self setupUI];
    [UIView animateWithDuration:1.0
                     animations:^{
                       self.recordingInternalView.alpha = 1.0;
                       self.infoLabel.alpha = 1.0;
                       self.timeLeftStackView.alpha = 0.0;
                     }
                     completion:nil];
}

#pragma mark - recording

- (void)setupRecordingHelper {
    self.recordingHelper.delegate = self;
    [self.recordingHelper setup];
}

- (void)startRecording {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
      [self.recordingHelper startRecording];
    });
    [self startTimer];
}

- (void)stopRecording {
    [self stopTimer];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
      [self.recordingHelper stopRecording];
    });
}

- (void)audioRecorderDidFinishRecording {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self showUploadingLabelWithCompletion:^{
        [self firePulseAnimation];
        [[SRStorageHelper sharedInstance]
            uploadFileWithSuccess:^{
              [self restoreInitialUIState];
            }
            failure:^(NSError *error) {
              UIAlertController *alert = [UIAlertController
                  alertControllerWithTitle:@"Uploading error"
                                   message:error.localizedDescription
                            preferredStyle:UIAlertControllerStyleAlert];

              UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                 [self restoreInitialUIState];
                                                               }];

              [alert addAction:okAction];
              [self presentViewController:alert animated:YES completion:nil];
            }];
      }];
    });
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
    NSString *timeString = [self.dateFormatter stringFromDate:timerDate];
    self.timeLeftValueLabel.text = (timeIntervalCountDown <= 0) ? @"0.0" : timeString;

    if (timeIntervalCountDown <= 0) {
        [self stopRecording];
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
          [self fireProgressAnimation];
          [self startRecording];
        }];

    [self animateChangeOfCornerRadius:self.recordingExternalViewWidth.constant / 2.0
                              forView:self.recordingExternalView
                         withDuration:animationDuration];

    [self animateChangeOfBorderWidth:1.5
                             forView:self.recordingExternalView
                        withDuration:animationDuration];

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

- (void)fireProgressAnimation {
    CAShapeLayer *circle = [CAShapeLayer layer];
    CGFloat circleRadius = self.recordingExternalView.frame.size.width;
    CGRect circleLayerFrame = CGRectMake(0, 0, circleRadius, circleRadius);
    circle.path = [UIBezierPath bezierPathWithRoundedRect:circleLayerFrame cornerRadius:circleRadius / 2.0].CGPath;
    circle.strokeColor = [UIColor santasGrayColor].CGColor;
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.lineWidth = 1.5;
    circle.strokeStart = 1.0;

    [self.recordingExternalView.layer addSublayer:circle];

    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    drawAnimation.duration = recordingDuration;
    drawAnimation.repeatCount = 1.0;
    drawAnimation.fromValue = @(0);
    drawAnimation.toValue = @(1);
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    [circle addAnimation:drawAnimation forKey:@"strokeStart"];
}

- (void)showUploadingLabelWithCompletion:(void (^)())completionBlock {
    [UIView animateWithDuration:0.3
        animations:^{
          self.timeLeftStackView.alpha = 0.0;
        }
        completion:^(BOOL finished) {
          completionBlock();
        }];
}

- (void)firePulseAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 1.0;
    animation.repeatCount = HUGE_VALF;
    animation.autoreverses = YES;
    animation.fromValue = @(0);
    animation.toValue = @(1);

    [self.uploadingLabel.layer addAnimation:animation forKey:@"opacity"];
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
