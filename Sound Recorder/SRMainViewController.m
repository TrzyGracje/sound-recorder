//
//  SRMainViewController.m
//  Sound Recorder
//
//  Created by Lukasz Komorowski on 29.05.2016.
//  Copyright © 2016 Lukasz Komorowski. All rights reserved.
//

#import "SRMainViewController.h"
#import "UIButton+BackgroundColor.h"
#import "UIColor+CustomColors.h"
#import "UIView+Shortcuts.h"

@interface SRMainViewController ()

@property (weak, nonatomic) IBOutlet UIView *recordingExternalView;
@property (weak, nonatomic) IBOutlet UIButton *recordingInternalView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordingExternalViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordingInternalViewWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordingViewVerticalMargin;

@end

@implementation SRMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - UI

- (void)setupUI {
    CGFloat recordingExternalViewTargetWidth = MIN(self.view.width, self.view.height) / 3.0;
    CGFloat recordingViewBorderCircleWidth = self.recordingExternalViewWidth.constant - self.recordingInternalViewWidth.constant;

    self.recordingExternalViewWidth.constant = recordingExternalViewTargetWidth;
    self.recordingInternalViewWidth.constant = recordingExternalViewTargetWidth - recordingViewBorderCircleWidth;
    [self.view.subviews makeObjectsPerformSelector:@selector(layoutIfNeeded)];

    self.recordingExternalView.layer.cornerRadius = self.recordingExternalViewWidth.constant / 2.0;
    self.recordingExternalView.layer.borderColor = [UIColor santasGrayColor].CGColor;
    self.recordingExternalView.layer.borderWidth = 1.0;

    self.recordingInternalView.layer.cornerRadius = (self.recordingExternalViewWidth.constant - 10.0) / 2.0;
    [self.recordingInternalView setBackgroundColor:[UIColor redOrangeColor]
                                          forState:UIControlStateNormal];
    [self.recordingInternalView setBackgroundColor:[UIColor dullRedColor]
                                          forState:UIControlStateHighlighted];
}

#pragma mark - actions

- (IBAction)recordClicked:(UIButton *)sender {
    CFTimeInterval animationDuration = 0.3;

    [UIView animateWithDuration:animationDuration animations:^{
      self.recordingExternalViewWidth.constant = MIN(self.view.width, self.view.height) / 1.5;
      self.recordingInternalViewWidth.constant = 0;
      [self.view layoutIfNeeded];

      self.recordingInternalView.alpha = 0.0;
    }];

    [self animateChangeOfCornerRadius:self.recordingExternalViewWidth.constant / 2.0
                              forView:self.recordingExternalView
                         withDuration:animationDuration];

    [self animateChangeOfBorderColor:[UIColor whiteColor]
                             forView:self.recordingExternalView
                        withDuration:animationDuration];

    [self animateChangeOfCornerRadius:0
                              forView:self.recordingInternalView
                         withDuration:animationDuration];
}

#pragma mark - animations

- (void)animateChangeOfCornerRadius:(CGFloat)cornerRadius forView:(UIView *)view withDuration:(CFTimeInterval)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:view.layer.cornerRadius];
    animation.toValue = [NSNumber numberWithFloat:cornerRadius];
    animation.duration = duration;

    view.layer.cornerRadius = cornerRadius;
    [view.layer addAnimation:animation forKey:@"cornerRadius"];
}

- (void)animateChangeOfBorderColor:(UIColor *)borderColor forView:(UIView *)view withDuration:(CFTimeInterval)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = (id)view.layer.borderColor;
    animation.toValue = (id)borderColor.CGColor;
    animation.duration = duration;

    view.layer.borderColor = borderColor.CGColor;
    [view.layer addAnimation:animation forKey:@"borderColor"];
}


@end
