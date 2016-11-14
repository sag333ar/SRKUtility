/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "O365UnifiedEndpointOperations.h"
#import "BasicUserInfo.h"
#import "ManagerInfo.h"
#import "DirectReport.h"
#import "User.h"
#import "MembershipGroup.h"
#import "AuthenticationManager.h"

@interface O365UnifiedEndpointOperations ()

@property (readonly, nonatomic) NSString    *baseURL;
@property (readonly, nonatomic) NSString   *resourceID;

@end

@implementation O365UnifiedEndpointOperations

- (instancetype)initWithBaseURL: (NSString *)baseURL resourceID:(NSString *) resourceID tenantString: (NSString *)tenantString {
    self = [super init];
    
    if (self) {
        _baseURL = [NSString stringWithFormat:@"%@%@", baseURL, tenantString];
        _resourceID = resourceID;
    }
    
    return self;
}

//Fetches all the users from the Active Directory
- (void)fetchAllUsersWithCompletionHandler:(void (^)(NSArray *, NSError *)) completionHandler {

    AuthenticationManager *authenticationManager = [AuthenticationManager sharedInstance];
    
    [authenticationManager acquireAuthTokenWithResourceId:_resourceID
                                        completionHandler:^(ADAuthenticationResult *result, NSError *error) {
                                            if (error) {
                                                completionHandler(nil,error);
                                                return;
                                            }
                                            
                                            
                                            NSString *accessToken = result.tokenCacheStoreItem.accessToken;
                                            
                                            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                                            NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration:
                                                                                 config delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
                                            
                                            NSString *requestURL = [NSString stringWithFormat:@"%@%@", _baseURL, @"users?$filter=userType%20eq%20'Member'"];
                                            
                                            
                                            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestURL]];
                                            
                                            
                                            NSString *authorization = [NSString stringWithFormat:@"Bearer %@", accessToken];
                                            
                                            
                                            [theRequest setValue:authorization forHTTPHeaderField:@"Authorization"];
                                            
                                            [theRequest setValue:@"application/json;odata.metadata=minimal;odata.streaming=true" forHTTPHeaderField:@"accept"];
                                            
                                            
                                            [[delegateFreeSession dataTaskWithRequest:theRequest
                                                                    completionHandler:^(NSData *data, NSURLResponse *response,
                                                                                        NSError *error) {
                                                                        
                                                                        if (error) {
                                                                            completionHandler(nil,error);
                                                                            return;
                                                                        }

                                                                        NSDictionary *jsonPayload = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                    options:0
                                                                                                                                      error:NULL];
                                                                        
                                                                            NSMutableArray *users = [[NSMutableArray alloc] init];
                                                                        
                                                                        for (NSDictionary *userData in jsonPayload[@"value"]) {
                                                                            
                                                                            NSString *objectId;
                                                                            
                                                                            if(userData[@"id"])
                                                                            {
                                                                                objectId = userData[@"id"];
                                                                            }
                                                                            else
                                                                            {
                                                                                objectId = @"";
                                                                            }
                                                                            
                                                                            NSString *displayName;
                                                                            
                                                                            if(userData[@"displayName"] && userData[@"displayName"] != [NSNull null])
                                                                            {
                                                                                displayName = userData[@"displayName"];
                                                                            }
                                                                            else
                                                                            {
                                                                                displayName = @"";
                                                                            }
                                                                            
                                                                            NSString *jobTitle;
                                                                            
                                                                            if(userData[@"jobTitle"] && userData[@"jobTitle"] != [NSNull null])
                                                                            {
                                                                                jobTitle = userData[@"jobTitle"];
                                                                            }
                                                                            else
                                                                            {
                                                                                jobTitle = @"";
                                                                            }
                                                                            
                                                                            User *user = [[User alloc] initWithId:objectId
                                                                                                            displayName:displayName
                                                                                                            jobTitle:jobTitle];
                                                                            [users addObject:user];
                                                                            
                                                                        }
                                                                        
                                                                        
                                                                        completionHandler(users, error);
                                                                    }] resume];
                                            
                                        }];
  
}

//Fetches the basic user information from Active Directory
- (void)fetchBasicUserInfoForUserId:(NSString *)userObjectID
                  completionHandler:(void (^)(BasicUserInfo *, NSError *))completionHandler {
    
    AuthenticationManager *authenticationManager = [AuthenticationManager sharedInstance];
    
    [authenticationManager acquireAuthTokenWithResourceId:_resourceID
                                        completionHandler:^(ADAuthenticationResult *result, NSError *error) {
                                            if (error) {
                                                completionHandler(nil,error);
                                                return;
                                            }


                                            NSString *accessToken = result.tokenCacheStoreItem.accessToken;

                                            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                                            NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration:
                                                                                 config delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
                                        
                                            NSString *requestURL = [NSString stringWithFormat:@"%@%@%@%@", _baseURL, @"users/", userObjectID, @"?$select=id,displayName,state,country,department,jobTitle,businessPhones,mobilePhone,mail"];
                                            
                                            
                                            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestURL]];


                                            NSString *authorization = [NSString stringWithFormat:@"Bearer %@", accessToken];


                                            [theRequest setValue:authorization forHTTPHeaderField:@"Authorization"];

                                            [theRequest setValue:@"application/json;odata.metadata=minimal;odata.streaming=true" forHTTPHeaderField:@"accept"];


                                            [[delegateFreeSession dataTaskWithRequest:theRequest
                                                                    completionHandler:^(NSData *data, NSURLResponse *response,
                                                                                        NSError *error) {
                                                                        if (error) {
                                                                            completionHandler(nil,error);
                                                                            return;
                                                                        }

                                                                        NSDictionary *jsonPayload = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                    options:0
                                                                                                                                      error:NULL];
                                                                        
                                                                        NSString *objectId;
                                                                        
                                                                        if(jsonPayload[@"id"])
                                                                        {
                                                                            objectId = jsonPayload[@"id"];
                                                                        }
                                                                        else
                                                                        {
                                                                            objectId = @"";
                                                                        }
                                                                        
                                                                        NSString *displayName;
                                                                        
                                                                        if(jsonPayload[@"displayName"] && jsonPayload[@"displayName"] != [NSNull null])
                                                                        {
                                                                            displayName = jsonPayload[@"displayName"];
                                                                        }
                                                                        else
                                                                        {
                                                                            displayName = @"";
                                                                        }
                                                                        
                                                                        NSString *state;
                                                                        
                                                                        if(jsonPayload[@"state"] && jsonPayload[@"state"] != [NSNull null])
                                                                        {
                                                                            state = jsonPayload[@"state"];
                                                                        }
                                                                        else
                                                                        {
                                                                            state = @"";
                                                                        }
                                                                        
                                                                        NSString *country;
                                                                        
                                                                        if(jsonPayload[@"country"] && jsonPayload[@"country"] != [NSNull null])
                                                                        {
                                                                            country = jsonPayload[@"country"];
                                                                        }
                                                                        else
                                                                        {
                                                                            country = @"";
                                                                        }
                                                                        
                                                                        NSString *department;
                                                                        
                                                                        if(jsonPayload[@"department"] && jsonPayload[@"department"] != [NSNull null])
                                                                        {
                                                                            department = jsonPayload[@"department"];
                                                                        }
                                                                        else
                                                                        {
                                                                            department = @"";
                                                                        }
                                                                        
                                                                        NSString *jobTitle;
                                                                        
                                                                        if(jsonPayload[@"jobTitle"] && jsonPayload[@"jobTitle"] != [NSNull null])
                                                                        {
                                                                            jobTitle = jsonPayload[@"jobTitle"];
                                                                        }
                                                                        else
                                                                        {
                                                                            jobTitle = @"";
                                                                        }
                                                                        
                                                                        NSString *phone;
                                                                        
                                                                        if(jsonPayload[@"businessPhones"] && jsonPayload[@"businessPhones"] != [NSNull null])
                                                                        {
                                                                            NSArray *businessPhones = jsonPayload[@"businessPhones"];
                                                                            phone = businessPhones.firstObject;
                                                                        }

                                                                        if (phone.length == 0 && jsonPayload[@"mobilePhone"] && jsonPayload[@"mobilePhone"] != [NSNull null])
                                                                        {
                                                                            phone = jsonPayload[@"mobilePhone"];
                                                                        }
                                                                        else
                                                                        {
                                                                            phone = @"";
                                                                        }
                                                                        
                                                                        NSString *email;
                                                                        
                                                                        if(jsonPayload[@"mail"] && jsonPayload[@"mail"] != [NSNull null])
                                                                        {
                                                                            email = jsonPayload[@"mail"];
                                                                        }
                                                                        else
                                                                        {
                                                                            email = @"";
                                                                        }
               
                                                                        

                                                                        BasicUserInfo *basicUserInfo = [[BasicUserInfo alloc] initWithId:objectId
                                                                                                                             displayName:displayName
                                                                                                                                    state:state
                                                                                                                                 country:country
                                                                                                                              department:department
                                                                                                                                jobTitle:jobTitle
                                                                                                                                   phone:phone
                                                                                                                                   email:email];

                                                                        completionHandler(basicUserInfo, error);
                                                                    }] resume];

                                        }];

}

//Fetches the thumbnail photo from Active Directory
- (void)fetchThumbnailForUserId:(NSString *)userObjectID
                completionHandler:(void (^)(UIImage *image, NSError *error))completionHandler
{
    AuthenticationManager *authenticationManager = [AuthenticationManager sharedInstance];

    [authenticationManager acquireAuthTokenWithResourceId:_resourceID
                                        completionHandler:^(ADAuthenticationResult *result, NSError *error) {
                                            if (error) {
                                                completionHandler(nil,error);
                                                return;
                                            }

                                            NSString *accessToken = result.tokenCacheStoreItem.accessToken;

                                            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                                            NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration:
                                                                                 config delegate: nil delegateQueue: [NSOperationQueue mainQueue]];

                                            NSString *requestURL = [NSString stringWithFormat:@"%@%@%@%@", _baseURL, @"users/", userObjectID, @"/photo/$value"];

                                            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestURL]];


                                            NSString *authorization = [NSString stringWithFormat:@"Bearer %@", accessToken];


                                            [theRequest setValue:authorization forHTTPHeaderField:@"Authorization"];


                                            [[delegateFreeSession dataTaskWithRequest:theRequest
                                                                    completionHandler:^(NSData *data, NSURLResponse *response,
                                                                                        NSError *error) {
                                                                        
                                                                        UIImage *image = [UIImage imageWithData:data];

                                                                        completionHandler(image, nil);
                                                                    }] resume];
                                            
                                        }];
}

//Fetches the user's hire date from SharePoint
-(void)fetchHireDateForUserId:(NSString *)userObjectID completionHandler:(void (^)(NSString *, NSError *))completionHandler {
    
    AuthenticationManager *authenticationManager = [AuthenticationManager sharedInstance];
    
    [authenticationManager acquireAuthTokenWithResourceId:_resourceID
                                        completionHandler:^(ADAuthenticationResult *result, NSError *error) {
                                            if (error) {
                                                completionHandler(nil,error);
                                                return;
                                            }
                                            
                                            
                                            NSString *accessToken = result.tokenCacheStoreItem.accessToken;
                                            
                                            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                                            NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration:
                                                                                 config delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
                                            
                                            NSString *requestURL = [NSString stringWithFormat:@"%@%@%@%@", _baseURL, @"users/", userObjectID, @"?$select=hireDate"];
                                            
                                            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestURL]];
                                            
                                            
                                            NSString *authorization = [NSString stringWithFormat:@"Bearer %@", accessToken];
                                            
                                            
                                            [theRequest setValue:authorization forHTTPHeaderField:@"Authorization"];
                                            
                                            [theRequest setValue:@"application/json;odata.metadata=minimal;odata.streaming=true" forHTTPHeaderField:@"accept"];
                                            
                                            
                                            [[delegateFreeSession dataTaskWithRequest:theRequest
                                                                    completionHandler:^(NSData *data, NSURLResponse *response,
                                                                                        NSError *error) {
                                                                        
                                                                        NSDictionary *jsonPayload = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                    options:0
                                                                                                                                      error:NULL];
                                                                        
                                                                        NSString *hireDate = jsonPayload[@"hireDate"];
                                                                    
                                                                        completionHandler(hireDate, error);
                                                                    }] resume];
                                            
                                        }];

}

//Fetches the user's #tags from SharePoint
-(void)fetchTagsForUserId:(NSString *)userObjectID completionHandler:(void (^)(NSArray *, NSError *))completionHandler {

    AuthenticationManager *authenticationManager = [AuthenticationManager sharedInstance];
    
    [authenticationManager acquireAuthTokenWithResourceId:_resourceID
                                        completionHandler:^(ADAuthenticationResult *result, NSError *error) {
                                            if (error) {
                                                completionHandler(nil,error);
                                                return;
                                            }
                                            
                                            
                                            NSString *accessToken = result.tokenCacheStoreItem.accessToken;
                                            
                                            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                                            NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration:
                                                                                 config delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
                                            
                                            NSString *requestURL = [NSString stringWithFormat:@"%@%@%@%@", _baseURL, @"users/", userObjectID, @"?$select=Tags"];
                                            
                                            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestURL]];
                                            
                                            
                                            NSString *authorization = [NSString stringWithFormat:@"Bearer %@", accessToken];
                                            
                                            
                                            [theRequest setValue:authorization forHTTPHeaderField:@"Authorization"];
                                            
                                            [theRequest setValue:@"application/json;odata.metadata=minimal;odata.streaming=true" forHTTPHeaderField:@"accept"];
                                            
                                            
                                            [[delegateFreeSession dataTaskWithRequest:theRequest
                                                                    completionHandler:^(NSData *data, NSURLResponse *response,
                                                                                        NSError *error) {

                                                                        NSDictionary *jsonPayload = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                    options:0
                                                                                                                                      error:NULL];
                                                                        
                                                                        NSArray *tags = jsonPayload[@"tags"];
                                                                        
                                                                        completionHandler(tags, error);
                                                                    }] resume];
                                            
                                        }];

}


//Fetches the user's manager info from Active Directory
-(void)fetchManagerInfoForUserId:(NSString *)userObjectID completionHandler:(void (^)(ManagerInfo *, NSError *))completionHandler {

    AuthenticationManager *authenticationManager = [AuthenticationManager sharedInstance];
    
    [authenticationManager acquireAuthTokenWithResourceId:_resourceID
                                        completionHandler:^(ADAuthenticationResult *result, NSError *error) {
                                            if (error) {
                                                completionHandler(nil,error);
                                                return;
                                            }
                                            
                                            
                                            NSString *accessToken = result.tokenCacheStoreItem.accessToken;
                                            
                                            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                                            NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration:
                                                                                 config delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
                                            
                                            NSString *requestURL = [NSString stringWithFormat:@"%@%@%@%@", _baseURL, @"users/", userObjectID, @"/manager"];
                                            
                                            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestURL]];
                                            
                                            
                                            NSString *authorization = [NSString stringWithFormat:@"Bearer %@", accessToken];
                                            
                                            
                                            [theRequest setValue:authorization forHTTPHeaderField:@"Authorization"];
                                            
                                            [theRequest setValue:@"application/json;odata.metadata=minimal;odata.streaming=true" forHTTPHeaderField:@"accept"];
                                            
                                            
                                            [[delegateFreeSession dataTaskWithRequest:theRequest
                                                                    completionHandler:^(NSData *data, NSURLResponse *response,
                                                                                        NSError *error) {
                                                                
                                                                        
                                                                        NSDictionary *jsonPayload = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                    options:0
                                                                                                                                      error:NULL];
                                                                    
        
                                                                        NSString *objectId;
                                                                        
                                                                        if(jsonPayload[@"id"] && jsonPayload[@"id"] != [NSNull null])
                                                                        {
                                                                            objectId = jsonPayload[@"id"];
                                                                        }
                                                                        else
                                                                        {
                                                                            objectId = @"";
                                                                        }
                                                                        
                                                                        NSString *displayName;
                                                                        
                                                                        if(jsonPayload[@"displayName"] && jsonPayload[@"displayName"] != [NSNull null])
                                                                        {
                                                                            displayName = jsonPayload[@"displayName"];
                                                                        }
                                                                        else
                                                                        {
                                                                            displayName = @"";
                                                                        }
                                                                        
                                                                        NSString *jobTitle;
                                                                        
                                                                        if(jsonPayload[@"jobTitle"] && jsonPayload[@"jobTitle"] != [NSNull null])
                                                                        {
                                                                            jobTitle = jsonPayload[@"jobTitle"];
                                                                        }
                                                                        else
                                                                        {
                                                                            jobTitle = @"";
                                                                        }
                                                                        
                                                                        
                                                                        ManagerInfo *managerInfo = [[ManagerInfo alloc] initWithId:objectId
                                                                                                                             displayName:displayName
                                                                                                                                jobTitle:jobTitle];
                                                                        
                                                                        completionHandler(managerInfo, error);
                                                                    }] resume];
                                            
                                        }];
}

//Fetches the user's direct reports from Active Directory
-(void)fetchDirectReportsForUserId:(NSString *)userObjectID completionHandler:(void (^)(NSArray *, NSError *))completionHandler {

    NSMutableArray *directReports = [[NSMutableArray alloc] init];
                              
    AuthenticationManager *authenticationManager = [AuthenticationManager sharedInstance];
    
    [authenticationManager acquireAuthTokenWithResourceId:_resourceID
                                        completionHandler:^(ADAuthenticationResult *result, NSError *error) {
                                            if (error) {
                                                completionHandler(nil,error);
                                                return;
                                            }
                                            
                                            
                                            NSString *accessToken = result.tokenCacheStoreItem.accessToken;
                                            
                                            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                                            NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration:
                                                                                 config delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
                                            
                                            NSString *requestURL = [NSString stringWithFormat:@"%@%@%@%@", _baseURL, @"users/", userObjectID, @"/directReports"];
                                            
                                            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestURL]];
                                            
                                            
                                            NSString *authorization = [NSString stringWithFormat:@"Bearer %@", accessToken];
                                            
                                            
                                            [theRequest setValue:authorization forHTTPHeaderField:@"Authorization"];
                                            
                                            [theRequest setValue:@"application/json;odata.metadata=minimal;odata.streaming=true" forHTTPHeaderField:@"accept"];
                                            
                                            
                                            [[delegateFreeSession dataTaskWithRequest:theRequest
                                                                    completionHandler:^(NSData *data, NSURLResponse *response,
                                                                                        NSError *error) {
                                                                        if (error) {
                                                                            completionHandler(nil,error);
                                                                            return;
                                                                        }
                                                                        
                                                                        
                                                                        NSDictionary *jsonPayload = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                    options:0
                                                                                                                                      error:NULL];
                                                                    
                                                                            
                                                                        for (NSDictionary *directReportData in jsonPayload[@"value"]) {
                                                                            
                                                                            NSString *objectId;
                                                                            
                                                                            if(directReportData[@"id"] && directReportData[@"id"] != [NSNull null])
                                                                            {
                                                                                objectId = directReportData[@"id"];
                                                                            }
                                                                            else
                                                                            {
                                                                                objectId = @"";
                                                                            }
                                                                            
                                                                            NSString *displayName;
                                                                            
                                                                            if(directReportData[@"displayName"] && directReportData[@"displayName"] != [NSNull null])
                                                                            {
                                                                                displayName = directReportData[@"displayName"];
                                                                            }
                                                                            else
                                                                            {
                                                                                displayName = @"";
                                                                            }
                                                                            
                                                                            NSString *jobTitle;
                                                                            
                                                                            if(directReportData[@"jobTitle"] && directReportData[@"jobTitle"] != [NSNull null])
                                                                            {
                                                                                jobTitle = directReportData[@"jobTitle"];
                                                                            }
                                                                            else
                                                                            {
                                                                                jobTitle = @"";
                                                                            }
                                                                            
                                                                            DirectReport *directReport = [[DirectReport alloc] initWithId:objectId
                                                                                                                      displayName:displayName
                                                                                                                         jobTitle:jobTitle];
                                                                            [directReports addObject:directReport];
                                                                                
                                                                            }
                                                                        
                                                                        
                                                                        completionHandler(directReports, error);
                                                                    }] resume];
                                            
                                        }];

    
}

//Fetches the user's membership info from Active Directory
-(void)fetchMembershipInfoForUserId:(NSString *)userObjectID completionHandler:(void (^)(NSArray *, NSError *))completionHandler {

    NSMutableArray *membershipGroups = [[NSMutableArray alloc] init];
    
    AuthenticationManager *authenticationManager = [AuthenticationManager sharedInstance];
    
    [authenticationManager acquireAuthTokenWithResourceId:_resourceID
                                        completionHandler:^(ADAuthenticationResult *result, NSError *error) {
                                            if (error) {
                                                completionHandler(nil,error);
                                                return;
                                            }
                                            
                                            
                                            NSString *accessToken = result.tokenCacheStoreItem.accessToken;
                                            
                                            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                                            NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration:
                                                                                 config delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
                                            
                                            NSString *requestURL = [NSString stringWithFormat:@"%@%@%@%@", _baseURL, @"users/", userObjectID, @"/memberOf"];
                                            
                                            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestURL]];
                                            
                                            
                                            NSString *authorization = [NSString stringWithFormat:@"Bearer %@", accessToken];
                                            
                                            
                                            [theRequest setValue:authorization forHTTPHeaderField:@"Authorization"];
                                            
                                            [theRequest setValue:@"application/json;odata.metadata=minimal;odata.streaming=true" forHTTPHeaderField:@"accept"];
                                            
                                            
                                            [[delegateFreeSession dataTaskWithRequest:theRequest
                                                                    completionHandler:^(NSData *data, NSURLResponse *response,
                                                                                        NSError *error) {
                                                                        if (error) {
                                                                            completionHandler(nil,error);
                                                                            return;
                                                                        }
                                                                        NSDictionary *jsonPayload = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                    options:0
                                                                                                                                      error:NULL];
                                                                        
                                                                        
                                                                        for (NSDictionary *membershipGroupData in jsonPayload[@"value"]) {
                                                                            
                                                                            NSString *objectId;
                                                                            
                                                                            if(membershipGroupData[@"id"] && membershipGroupData[@"id"] != [NSNull null])
                                                                            {
                                                                                objectId = membershipGroupData[@"id"];
                                                                            }
                                                                            else
                                                                            {
                                                                                objectId = @"";
                                                                            }
                                                                            
                                                                            NSString *groupName;
                                                                            
                                                                            if(membershipGroupData[@"displayName"] && membershipGroupData[@"displayName"] != [NSNull null])
                                                                            {
                                                                                groupName = membershipGroupData[@"displayName"];
                                                                            }
                                                                            else
                                                                            {
                                                                                groupName = @"";
                                                                            }
                                                                            MembershipGroup *membershipGroup = [[MembershipGroup alloc] initWithId:objectId
                                                                                                                              groupName:groupName];
                                                                            [membershipGroups addObject:membershipGroup];
                                                                            
                                                                        }
                                                                        
                                                                        
                                                                        completionHandler(membershipGroups, error);
                                                                    }] resume];
                                            
                                        }];
    

    
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