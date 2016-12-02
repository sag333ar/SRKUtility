//
//  MSGraphUserInfo.h
//  O365-iOS-Microsoft-Graph-SDK
//

#import <Foundation/Foundation.h>
#import "AuthenticationProvider.h"
#import <MSGraphSDK/MSGraphSDK.h>
#import <Foundation/Foundation.h>

@interface MSGraphUserInfo : NSObject
+ (void)getMSGraphUserInfo:(AuthenticationProvider *)provider completion:(void (^)(MSGraphUser *response, NSError *error))handler;
@end
