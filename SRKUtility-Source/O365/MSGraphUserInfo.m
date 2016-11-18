//
//  MSGraphUserInfo.m
//  O365-iOS-Microsoft-Graph-SDK
//

#import "MSGraphUserInfo.h"

@implementation MSGraphUserInfo

+ (void)getMSGraphUserInfo:(AuthenticationProvider *)provider completion:(void (^)(MSGraphUser *response, NSError *error))handler {
	[MSGraphClient setAuthenticationProvider:provider.authProvider];
	MSGraphClient *client = [MSGraphClient client];
	[[[client me]request]getWithCompletion:^(MSGraphUser *response, NSError *error) {
		handler(response, error);
	}];
}

@end
