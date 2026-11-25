#import <UIKit/UIKit.h>

static BOOL GMUBPHasUpdateButton(UIView *view) {
    if ([view isKindOfClass:[UIButton class]]) {
        NSString *title = [(UIButton *)view titleForState:UIControlStateNormal] ?: @"";
        if ([title localizedCaseInsensitiveContainsString:@"Update now"]) {
            return YES;
        }
    }

    NSString *label = view.accessibilityLabel ?: @"";
    if ([label localizedCaseInsensitiveContainsString:@"Update now"]) {
        return YES;
    }

    for (UIView *child in view.subviews) {
        if (GMUBPHasUpdateButton(child)) return YES;
    }

    return NO;
}

static UIView *GMUBPFindPromptView(UIView *view) {
    if ([view isKindOfClass:[UILabel class]]) {
        NSString *text = ((UILabel *)view).text ?: @"";

        if ([text localizedCaseInsensitiveContainsString:
             @"Update to the latest version"]) {
            return view;
        }
    }

    NSString *accessibilityText = view.accessibilityLabel ?: @"";

    if ([accessibilityText localizedCaseInsensitiveContainsString:
         @"Update to the latest version"]) {
        return view;
    }

    for (UIView *child in view.subviews) {
        UIView *found = GMUBPFindPromptView(child);
        if (found) return found;
    }

    return nil;
}

static void GMUBPScanView(UIWindow *window) {
    if (!window) return;

    UIView *prompt = GMUBPFindPromptView(window);

    if (!prompt || !GMUBPHasUpdateButton(window)) return;

    UIView *candidate = prompt;
    CGFloat requiredWidth = window.bounds.size.width * 0.90;

    while (candidate.superview &&
           candidate != window &&
           candidate.bounds.size.width < requiredWidth) {
        candidate = candidate.superview;
    }

    if (candidate == window) {
        candidate = prompt.superview;
    }

    if (candidate && candidate != window) {
        candidate.hidden = YES;
        candidate.userInteractionEnabled = NO;
    }
}

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{

            UIWindow *window = nil;

            for (UIWindow *w in UIApplication.sharedApplication.windows) {
                if (w.isKeyWindow) {
                    window = w;
                    break;
                }
            }

            if (window) GMUBPScanView(window);
        }
    );
}

%end

%hook UIView

- (void)layoutSubviews {
    %orig;

    UIWindow *window = self.window;

    if (window) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GMUBPScanView(window);
        });
    }
}

%end
