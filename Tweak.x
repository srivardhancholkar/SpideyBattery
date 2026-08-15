#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

static UIColor *SpideyBlue(void) { return [UIColor colorWithRed:0.11 green:0.30 blue:0.85 alpha:1.0]; }
static UIColor *SpideyRed(void)  { return [UIColor colorWithRed:0.84 green:0.10 blue:0.13 alpha:1.0]; }

static void forceSpidey(id self) {
    @try {
        // kill the cutout so the number is normal text, not a knockout
        [self setValue:@(NO) forKey:@"_batteryTextIsCutout"];
        // remove any masks that punch the number out of the fill
        for (NSString *k in @[@"_fillLayer", @"_percentFillLayer", @"_bodyLayer"]) {
            @try { CALayer *l = [self valueForKey:k]; if (l && l.mask) l.mask = nil; } @catch (__unused NSException *e) {}
        }
        // color the percentage label red, make sure it's visible
        UILabel *pl = [self valueForKey:@"_percentageLabel"];
        if (pl) {
            pl.textColor = SpideyRed();
            pl.hidden = NO;
            pl.layer.mask = nil;
        }
    } @catch (__unused NSException *e) {}
}

%hook _UIBatteryView
- (void)setBodyColor:(UIColor *)color {
    UIColor *c = SpideyBlue();
    %orig(c);
}
- (void)setFillColor:(UIColor *)color {
    UIColor *c = SpideyBlue();
    %orig(c);
}
- (void)layoutSubviews {
    %orig;
    forceSpidey(self);
}
- (void)_updateBatteryFillColor {
    %orig;
    forceSpidey(self);
}
- (void)_updateBodyColors {
    %orig;
    forceSpidey(self);
}
%end
