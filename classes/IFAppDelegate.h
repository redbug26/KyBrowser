//
//  IFAppDelegate.h


#import <UIKit/UIKit.h>

@class KWebViewController;

@interface IFAppDelegate : UIResponder <UIApplicationDelegate> {
    KWebViewController *controller;
}

@property (strong, nonatomic) UIWindow *window;

@end
