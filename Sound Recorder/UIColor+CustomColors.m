//
//  UIColor+CustomColors.m
//  Sound Recorder
//
//  Created by Lukasz Komorowski on 29.05.2016.
//  Copyright © 2016 Lukasz Komorowski. All rights reserved.
//

#import "UIColor+CustomColors.h"
#import "UIColor+HexRGB.h"

@implementation UIColor (CustomColors)

+ (UIColor *)turquoiseColor {
    return [UIColor colorWithHex:@"55EFCB"];
}

+ (UIColor *)mayaBlueColor {
    return [UIColor colorWithHex:@"5BCAFF"];
}

+ (UIColor *)santasGrayColor {
    return [UIColor colorWithHex:@"9BA6B2"];
}

+ (UIColor *)dullRedColor {
    return [UIColor colorWithHex:@"C73E3C"];
}

+ (UIColor *)redOrangeColor {
    return [UIColor colorWithHex:@"FF3B30"];
}

+ (UIColor *)troutColor {
    return [UIColor colorWithHex:@"4E535F"];
}

@end
