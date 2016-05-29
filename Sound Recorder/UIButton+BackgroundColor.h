//
//  UIButton+BackgroundColor.h
//  Sound Recorder
//
//  Created by Lukasz Komorowski on 29.05.2016.
//  Copyright © 2016 Lukasz Komorowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (BackgroundColor)

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

@end
