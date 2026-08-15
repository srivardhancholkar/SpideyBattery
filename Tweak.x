#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static UIColor *SpideyBlue(void) { return [UIColor colorWithRed:0.11 green:0.30 blue:0.85 alpha:1.0]; }
static UIColor *SpideyRed(void)  { return [UIColor colorWithRed:0.84 green:0.10 blue:0.13 alpha:1.0]; }

%hook _UIBatteryView

// battery icon -> blue
- (void)setBodyColor:(UIColor *)color {
    UIColor *c = SpideyBlue();
    %orig(c);
}
- (void)setPinColor:(UIColor *)color {
    UIColor *c = SpideyBlue();
    %orig(c);
}
- (void)setFillColor:(UIColor *)color {
    UIColor *c = SpideyBlue();
    %orig(c);
}

// percentage number (label inside the battery) -> solid red
- (void)layoutSubviews {
    @try { [(id)self setValue:@(NO) forKey:@"_batteryTextIsCutout"]; } @catch (__unused NSException *e) {}
    %orig;
    @try {
        UILabel *pl = [(id)self valueForKey:@"_percentageLabel"];
        if (pl) { pl.textColor = SpideyRed(); }
    } @catch (__unused NSException *e) {}
}
- (void)_updateBodyColors {
    @try { [(id)self setValue:@(NO) forKey:@"_batteryTextIsCutout"]; } @catch (__unused NSException *e) {}
    %orig;
    @try {
        UILabel *pl = [(id)self valueForKey:@"_percentageLabel"];
        if (pl) { pl.textColor = SpideyRed(); }
    } @catch (__unused NSException *e) {}
}

%end
