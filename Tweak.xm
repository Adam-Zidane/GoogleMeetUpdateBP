\
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static BOOL GMUBPContainsUpdatePrompt(UIView *view) {
    if ([view isKindOfClass:[UILabel class]]) {
        NSString *text = ((UILabel *)view).text ?: @"";
        if ([text localizedCaseInsensitiveContainsString:@"Update to the latest version"]) {
            return YES;
        }
    }

    NSString *accessibilityText = view.accessibilityLabel ?: @"";
    if ([accessibilityText localizedCaseInsensitiveContainsString:@"Update to the latest version"]) {
        return YES;
    }

    if ([view isKindOfClass:[UIButton class]]) {
        NSString *title = [(UIButton *)view titleForState:UIControlStateNormal] ?: @"";
        if ([title localizedCaseInsensitiveContainsString:@"Update now"]) {
            return YES;
        }
    }

    for (UIView *child in view.subviews) {
        if (GMUBPContainsUpdatePrompt(child)) return YES;
    }
    return NO;
}

static BOOL GMUBPHasUpdateButton(UIView *view) {
    if ([view isKindOfClass:[UIButton class]]) {
        NSString *title = [(UIButton *)view titleForState:UIControlStateNormal] ?: @"";
        if ([title localizedCaseInsensitiveContainsString:@"Update now"]) return YES;
    }
    NSString *label = view.accessibilityLabel ?: @"";
    if ([label localizedCaseInsensitiveContainsString:@"Update now"]) return YES;
    for (UIView *child in view.subviews) {
        if (GMUBPHasUpdateButton(child)) return YES;
    }
    return NO;
}

static UIView *GMUBPFindPromptView(UIView *view) {
    if ([view isKindOfClass:[UILabel class]]) {
        NSString *text = ((UILabel *)view).text ?: @"";
        if ([text localizedCaseInsensitiveContainsString:@"Update to the latest version"]) return view;
    }
    NSString *accessibilityText = view.accessibilityLabel ?: @"";
    if ([accessibilityText localizedCaseInsensitiveContainsString:@"Update to the latest version"]) return view;
    for (UIView *child in view.subviews) {
        UIView *found = GMUBPFindPromptView(child);
        if (found) return found;
    }
    return nil;
}

static void GMUBPScanView(UIView *window) {
    if (!window || !window.window) return;

    UIView *prompt = GMUBPFindPromptView(window);
    if (!prompt || !GMUBPHasUpdateButton(window)) return;

    // Walk upward from the heading to the full-screen prompt container.
    UIView *candidate = prompt;
    CGFloat requiredWidth = window.bounds.size.width * 0.90;
    while (candidate.superview &&
           candidate != window &&
           candidate.bounds.size.width < requiredWidth) {
        candidate = candidate.superview;
    }

    // Never hide the UIWindow itself.
    if (candidate == window) candidate = prompt.superview;
    if (candidate && candidate != window) {
        candidate.hidden = YES;
        candidate.userInteractionEnabled = NO;
    }
}

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        for (UIWindow *window in UIApplication.sharedApplication.windows) {
            if (window.isKeyWindow) { keyWindow = window; break; }
        }
        if (keyWindow) GMUBPScanView(keyWindow);
    });
}

%end

%hook UIView

- (void)layoutSubviews {
    %orig;
    // The prompt may be assembled after the initial controller presentation.
    if (self.window) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GMUBPScanView(self);
        });
    }
}

%end
