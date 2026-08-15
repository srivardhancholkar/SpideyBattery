#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static UIColor *SpideyBlue(void) { return [UIColor colorWithRed:0.11 green:0.30 blue:0.85 alpha:1.0]; }
static UIColor *SpideyRed(void)  { return [UIColor colorWithRed:0.84 green:0.10 blue:0.13 alpha:1.0]; }

static void dumpState(UIView *bv) {
    @try {
        NSMutableString *s = [NSMutableString string];
        id pl = nil, sp = nil, cut = nil;
        @try { pl = [(id)bv valueForKey:@"_percentageLabel"]; } @catch(...){}
        @try { sp = [(id)bv valueForKey:@"_showsPercentage"]; } @catch(...){}
        @try { cut = [(id)bv valueForKey:@"_batteryTextIsCutout"]; } @catch(...){}
        [s appendFormat:@"showsPercentage=%@ cutout=%@\n", sp, cut];
        if (pl) {
            [s appendFormat:@"percentageLabel class=%@ text=%@ textColor=%@ hidden=%d alpha=%.2f\n",
                [pl class], [pl respondsToSelector:@selector(text)]?[pl text]:@"?",
                [pl respondsToSelector:@selector(textColor)]?[pl textColor]:@"?",
                [pl respondsToSelector:@selector(isHidden)]?[pl isHidden]:-1,
                [pl respondsToSelector:@selector(alpha)]?[pl alpha]:-1.0];
        } else { [s appendString:@"percentageLabel = nil\n"]; }
        // battery subviews
        [s appendString:@"-- battery subviews --\n"];
        for (UIView *v in bv.subviews) {
            NSString *t = [v isKindOfClass:[UILabel class]] ? [(UILabel*)v text] : @"";
            [s appendFormat:@"  %@ '%@'\n", [v class], t];
        }
        // sibling views (percentage shown outside battery?)
        [s appendString:@"-- superview subviews --\n"];
        for (UIView *v in bv.superview.subviews) {
            NSString *t = @"";
            if ([v respondsToSelector:@selector(text)]) { @try { t = [(id)v text]; } @catch(...){} }
            [s appendFormat:@"  %@ '%@'\n", [v class], t?:@""];
        }
        [s writeToFile:@"/var/jb/tmp/spidey_pct.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
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
    dumpState((UIView *)self);
}
%end
