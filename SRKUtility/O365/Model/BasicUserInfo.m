/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license. See full license at the bottom of this file.
 */

#import "BasicUserInfo.h"

@implementation BasicUserInfo

- (instancetype)init
{
    return [self initWithId:nil displayName:nil state:nil country:nil department:nil jobTitle:nil phone:nil email:nil];
    
    
}

- (instancetype)initWithId:(NSString *)objectId displayName:(NSString *)displayName state:(NSString *)state country:(NSString *)country department:(NSString *)department jobTitle:(NSString *)jobTitle phone:(NSString *)phone email:(NSString *)email
{
    self = [super init];
    
    if (self) {
        _objectId = [objectId copy];
        _displayName = [displayName copy];
        _state = [state copy];
        _country = [country copy];
        _department = [department copy];
        _jobTitle = [jobTitle copy];
        _phone = [phone copy];
        _email = [email copy];
    }
    
    return self;
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