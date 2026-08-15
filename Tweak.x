#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Spider-Man palette: battery icon blue, percentage red.
static UIColor *SpideyBlue(void) { return [UIColor colorWithRed:0.11 green:0.30 blue:0.85 alpha:1.0]; } // #1B4DD9-ish
static UIColor *SpideyRed(void)  { return [UIColor colorWithRed:0.84 green:0.10 blue:0.13 alpha:1.0]; } // #D71920-ish

// ---- Battery icon -> BLUE ----
%hook _UIBatteryView
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
- (void)_updateColors {
    %orig;
    @try {
        [(id)self setValue:SpideyBlue() forKey:@"_bodyColor"];
        [(id)self setValue:SpideyBlue() forKey:@"_pinColor"];
    } @catch (__unused NSException *e) {}
}
%end

// ---- Percentage text -> RED (only the % label, not the clock) ----
%hook _UIStatusBarStringView
- (void)setText:(NSString *)text {
    %orig;
    if (text && [text containsString:@"%"]) {
        @try { [(id)self setValue:SpideyRed() forKey:@"_textColor"]; } @catch (__unused NSException *e) {}
    }
}
%end

// ---- load marker: lets us confirm injection after install ----
%ctor {
    @autoreleasepool {
        @try {
            NSString *s = [NSString stringWithFormat:@"loaded in %@ pid=%d\n_UIBatteryView=%@ _UIStatusBarStringView=%@\n",
                [NSProcessInfo processInfo].processName, getpid(),
                objc_getClass("_UIBatteryView") ? @"yes":@"no",
                objc_getClass("_UIStatusBarStringView") ? @"yes":@"no"];
            [s writeToFile:@"/var/jb/tmp/spidey_loaded.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
        } @catch (__unused NSException *e) {}
    }
}
