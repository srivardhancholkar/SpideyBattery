#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <string.h>

static UIColor *SpideyBlue(void) { return [UIColor colorWithRed:0.11 green:0.30 blue:0.85 alpha:1.0]; }
static UIColor *SpideyRed(void)  { return [UIColor colorWithRed:0.84 green:0.10 blue:0.13 alpha:1.0]; }

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
%end

%hook _UIStatusBarStringView
- (void)setText:(NSString *)text {
    %orig;
    if (text && [text containsString:@"%"]) {
        @try { [(id)self setValue:SpideyRed() forKey:@"_textColor"]; } @catch (__unused NSException *e) {}
    }
}
%end

static void dumpClass(NSMutableString *s, const char *clsname) {
    Class c = objc_getClass(clsname);
    if (!c) { [s appendFormat:@"\n(class %s NOT FOUND)\n", clsname]; return; }
    [s appendFormat:@"\n===== %s methods =====\n", clsname];
    unsigned mc=0; Method *ms=class_copyMethodList(c,&mc);
    for(unsigned i=0;i<mc;i++) [s appendFormat:@"%s\n", sel_getName(method_getName(ms[i]))];
    free(ms);
    [s appendFormat:@"----- %s ivars -----\n", clsname];
    unsigned ic=0; Ivar *iv=class_copyIvarList(c,&ic);
    for(unsigned i=0;i<ic;i++) [s appendFormat:@"%s\n", ivar_getName(iv[i])];
    free(iv);
}

%ctor {
    @autoreleasepool {
        @try {
            NSMutableString *s = [NSMutableString string];
            [s appendFormat:@"proc=%@\n", [NSProcessInfo processInfo].processName];
            unsigned int n=0; Class *all=objc_copyClassList(&n);
            [s appendString:@"== classes containing 'battery' ==\n"];
            for(unsigned i=0;i<n;i++){ const char*cn=class_getName(all[i]); if(cn&&strcasestr(cn,"battery")) [s appendFormat:@"%s\n",cn]; }
            free(all);
            dumpClass(s,"_UIBatteryView");
            [s writeToFile:@"/var/jb/tmp/spidey_dump.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
        } @catch (__unused NSException *e) {}
    }
}
