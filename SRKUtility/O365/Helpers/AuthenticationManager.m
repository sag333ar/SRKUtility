/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "AuthenticationManager.h"


// ENTER: Set your application's clientId and redirect URI here. You get
// these when you register your application in Azure AD.

NSString * const Office365DidConnectNotification = @"Office365DidConnectNotification";
NSString * const Office365DidDisconnectNotification = @"Office365DidDisconnectNotification";

@interface AuthenticationManager ()

@property (strong,    nonatomic) ADAuthenticationContext *authContext;
@property (readonly, nonatomic) NSURL    *redirectURL;
@property (readonly, nonatomic) NSString *authority;
@property (readonly, nonatomic) NSString *clientId;

@end

NSString *cl_redirectURL;
NSString *cl_authority;
NSString *cl_clientId;

@implementation AuthenticationManager

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // These are settings that you need to set based on your
        // client registration in Azure AD.
        _redirectURL = [NSURL URLWithString:[AuthenticationManager getRedirectURL]];
        _authority = [AuthenticationManager getAuthority];
        _clientId = [AuthenticationManager getClientID];
    }
    
    return self;
}

+ (void)setRedirectURL: (NSString *)redirectURL {
	cl_redirectURL = redirectURL;
}

+ (void)setClientID: (NSString *)ClientID {
	cl_clientId = ClientID;
}

+ (void)setAuthority: (NSString *)authority {
	cl_authority = authority;
}

+ (NSString *)getAuthority {
	return cl_authority;
}

+ (NSString *)getClientID {
	return cl_clientId;
}

+ (NSString *)getRedirectURL {
	return cl_redirectURL;
}

// Use a single authentication manager for the application.
+ (AuthenticationManager *)sharedInstance
{
    static AuthenticationManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    // Initialize the AuthenticationManager only once.
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AuthenticationManager alloc] init];
    });
    
    return sharedInstance;
}

// Acquire access and refresh tokens from Azure AD for the user
- (void)acquireAuthTokenWithResourceId:(NSString *)resourceId
                     completionHandler:(void (^)(ADAuthenticationResult *result, NSError *error))completionBlock
{
    ADAuthenticationError *ADerror;
    self.authContext = [ADAuthenticationContext authenticationContextWithAuthority:self.authority
                                                                             error:&ADerror];
    
    // The first time this application is run, the [ADAuthenticationContext acquireTokenWithResource]
    // manager will send a request to the AUTHORITY (see the const at the top of this file) which
    // will redirect you to a login page. You will provide your credentials and the response will
    // contain your refresh and access tokens. The second time this application is run, and assuming
    // you didn't clear your token cache, the authentication manager will use the access or refresh
    // token in the cache to authenticate client requests.
    // This will result in a call to the service if you need to get an access token.
    [self.authContext acquireTokenWithResource:resourceId
                                      clientId:self.clientId
                                   redirectUri:self.redirectURL
                               completionBlock:^(ADAuthenticationResult *result) {
                                   if (AD_SUCCEEDED != result.status) {
                                       
                                       NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                                       [errorDetail setValue:@"Failed to acquire a token" forKey:NSLocalizedDescriptionKey];
                                       
                                       //let's pick a unique error code of 100
                                       NSError *error = [NSError errorWithDomain:@"O365-iOS-Profile"
                                                                            code:100 userInfo:errorDetail];
                                
                                       completionBlock(nil, error);
                                   }
                                   else {
                                       
                                       // Saving the logged in user's userId.
                                       NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                       [userDefaults setObject:result.tokenCacheStoreItem.userInformation.userId
                                                        forKey:@"LogInUser"];
                                       [userDefaults synchronize];
        
                                       completionBlock(result, nil);
                                   }
                               }];
    
}

-(void)clearCredentials {
	
	id<ADTokenCacheStoring> cache = [ADAuthenticationSettings sharedInstance].defaultTokenCacheStore;
	ADAuthenticationError *error;
	
	// Clear the token cache.
	if ([[cache allItemsWithError:&error] count] > 0)
		[cache removeAllWithError:&error];
	
	// Remove all the cookies from this application's sandbox. ADAL will try to
	// get to access tokens based on auth code in the cookie.
	NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (NSHTTPCookie *cookie in cookieStore.cookies) {
		[cookieStore deleteCookie:cookie];
	}
	
	// Clear user defaults in case you change target tenant.
	NSDictionary *keys = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	for (NSString *key in keys)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	}
	
	//Notification for when app is disconnected from O365
	[[NSNotificationCenter defaultCenter]postNotificationName:Office365DidDisconnectNotification object:nil];
}

@end

// *********************************************************
//
// O365-iOS-Profile, https://github.com/OfficeDev/O365-iOS-Profile
//
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// MIT License:
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// *********************************************************
