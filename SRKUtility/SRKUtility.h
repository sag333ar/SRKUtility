//
//  Utility.h
//  Sagar R. Kothari
//
//  Created by http://sagarrkothari.com Pvt. Ltd. on 12/07/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

void ALERT(NSString *title, NSString *message,NSString *canceBtnTitle,id delegate,NSString *otherButtonTitles, ... );

#define ALERT_ERROR(title,message)    dispatch_async(dispatch_get_main_queue(), ^{  ALERT(title, message, @"Okay", nil, nil); }); 

#define APP_DEL         (AppDelegate *)[[UIApplication sharedApplication] delegate]

@interface SRKUtility : NSObject

+ (BOOL)isReachableToLocalNetwork;


+ (BOOL)saveValue:(id)value forKey:(NSString *)key;
+ (BOOL)deleteValueForKey:(NSString *)key;
+ (id)getValueForKey:(NSString *)key;

+ (void)showProgressHUD:(UIViewController *)vCtr titleText:(NSString *)titleText detailedText:(NSString *)detailedText;
+ (void)setFontForProgressHUDDetailedLabel:(UIFont *)font;
+ (void)setFontForProgressHUDTitleLabel:(UIFont *)font;
+ (void)hideProgressHUD;


@end
