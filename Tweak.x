#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static UIColor *SpideyBlue(void) { return [UIColor colorWithRed:0.11 green:0.30 blue:0.85 alpha:1.0]; }
static UIColor *SpideyRed(void)  { return [UIColor colorWithRed:0.84 green:0.10 blue:0.13 alpha:1.0]; }

static void paintRed(id self) {
    @try {
        UILabel *pl = [self valueForKey:@"_percentageLabel"];
        if (pl) { pl.textColor = SpideyRed(); pl.layer.mask = nil; pl.hidden = NO; }
    } @catch (__unused NSException *e) {}
}

%hook _UIBatteryView

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
    paintRed(self);
}
- (void)_updateBodyColors {
    %orig;
    paintRed(self);
}
- (void)_updateBatteryFillColor {
    %orig;
    paintRed(self);
}
- (void)_updatePercentageFont {
    %orig;
    paintRed(self);
}

%end
