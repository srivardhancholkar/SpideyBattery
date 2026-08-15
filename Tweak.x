#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static UIColor *SpideyBlue(void) { return [UIColor colorWithRed:0.11 green:0.30 blue:0.85 alpha:1.0]; }
static UIColor *SpideyRed(void)  { return [UIColor colorWithRed:0.84 green:0.10 blue:0.13 alpha:1.0]; }

%hook _UIBatteryView

// force the percentage to render as normal text (not a knockout of the fill)
- (BOOL)_batteryTextIsCutout { return NO; }

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
    @try {
        UILabel *pl = [(id)self valueForKey:@"_percentageLabel"];
        if (pl) { pl.textColor = SpideyRed(); pl.layer.mask = nil; pl.hidden = NO; }
    } @catch (__unused NSException *e) {}
}
- (void)_updateBatteryFillColor {
    %orig;
    @try {
        UILabel *pl = [(id)self valueForKey:@"_percentageLabel"];
        if (pl) { pl.textColor = SpideyRed(); }
    } @catch (__unused NSException *e) {}
}

%end
