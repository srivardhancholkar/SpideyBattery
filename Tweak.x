#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static char kSpidey;
static UIColor *SpideyBlue(void) { return [UIColor colorWithRed:0.11 green:0.30 blue:0.85 alpha:1.0]; }
static UIColor *SpideyRed(void)  { return [UIColor colorWithRed:0.84 green:0.10 blue:0.13 alpha:1.0]; }

// Any label we've tagged can never be recolored away from red.
%hook UILabel
- (void)setTextColor:(UIColor *)color {
    if (objc_getAssociatedObject(self, &kSpidey)) {
        UIColor *r = SpideyRed();
        %orig(r);
    } else {
        %orig;
    }
}
%end

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
    @try {
        UILabel *pl = [(id)self valueForKey:@"_percentageLabel"];
        if (pl) {
            objc_setAssociatedObject(pl, &kSpidey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            pl.layer.mask = nil;
            pl.hidden = NO;
            pl.textColor = SpideyRed();
        }
    } @catch (__unused NSException *e) {}
}

%end
