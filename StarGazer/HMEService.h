//
//  HMEService.h
//  StarGazer
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ARSCNView;

@interface HMEService : NSObject

@property (nonatomic, class, nullable) UIWindowScene *windowScene;

+ (void)runSupportingCodeForView:(ARSCNView *)view;

@end
