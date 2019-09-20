//
//  HMEService.m
//  StarGazer
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>
#import "HMEService.h"

@implementation HMEService
static UIWindowScene *_windowScene = nil;


+ (void)runSupportingCodeForView:(ARSCNView *)view {
    NSObject *presentation = [view.session valueForKey:@"_presentation"];

    NSBundle *starBoardFoundation = [NSBundle bundleWithPath: @"/System/Library/PrivateFrameworks/StarBoardFoundation.framework"];
    [starBoardFoundation load];

    NSBundle *arDisplayDevice = [NSBundle bundleWithPath: @"/System/Library/PrivateFrameworks/ARDisplayDevice.framework"];
    [arDisplayDevice load];

    NSObject *hmeConfig = [[starBoardFoundation classNamed: @"SRHMEConfig"] alloc];
    [hmeConfig setValue:@"io.apple" forKey:@"_vendorId"];
    [hmeConfig setValue:@"io.good" forKey:@"_deviceId"];
    [hmeConfig setValue:@"" forKey:@"_metadata"];

    NSObject *boardController = [presentation valueForKey:@"boardController"];


    if (HMEService.windowScene) {
        [boardController performSelector:NSSelectorFromString(@"starBoardSceneConnected:") withObject:HMEService.windowScene];
    }

    [boardController performSelector:NSSelectorFromString(@"setCurrentConfig:") withObject:hmeConfig];
}

+ (void)setWindowScene:(UIWindowScene *)windowScene {
    _windowScene = windowScene;
}

+ (UIWindowScene *)windowScene {
    return _windowScene;
}

@end
