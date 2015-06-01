//
//  Utility.m
//  Sagar R. Kothari
//
//  Created by http://sagarrkothari.com Pvt. Ltd. on 12/07/14.
//
//

#import "SRKUtility.h"
#import <KSReachability/KSReachability.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface SRKUtility ()
@property (nonatomic, strong) KSReachability *obj_KSReachability;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) UIFont *fontForTitleLabel;
@property (nonatomic, strong) UIFont *fontForDetailedLabel;
@end

@implementation SRKUtility

void ALERT(NSString *title, NSString *message,NSString *canceBtnTitle,id delegate,NSString *otherButtonTitles, ... )
{
    
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:title
                                                          message:message
                                                         delegate:delegate
                                                cancelButtonTitle:canceBtnTitle
                                                otherButtonTitles:nil
                                ];
        
        va_list args;
        va_start(args, otherButtonTitles);
        NSString *obj;
        for (obj = otherButtonTitles; obj != nil; obj = va_arg(args, NSString*))
            [alertView addButtonWithTitle:obj];
        va_end(args);
    [alertView show];
}

+ (SRKUtility *)sharedInstance {
    static dispatch_once_t once;
    static SRKUtility *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[SRKUtility alloc] init];
    });
    return sharedInstance;
}

+ (BOOL)isReachableToLocalNetwork {
	return [[SRKUtility sharedInstance].obj_KSReachability reachable];
}

+ (BOOL)saveValue:(id)value forKey:(NSString *)key {
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
	return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)deleteValueForKey:(NSString *)key {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getValueForKey:(NSString *)key {
	return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

+ (void)showProgressHUD:(UIViewController *)vCtr titleText:(NSString *)titleText detailedText:(NSString *)detailedText {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SRKUtility sharedInstance] showProgressHUD:vCtr titleText:titleText detailedText:detailedText];
    });
}

+ (void)hideProgressHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SRKUtility sharedInstance] hideProgressHUD];
    });
}

+ (void)setFontForProgressHUDTitleLabel:(UIFont *)font {
    [[SRKUtility sharedInstance] setFontForTitleLabel:font];
}

+ (void)setFontForProgressHUDDetailedLabel:(UIFont *)font {
    [[SRKUtility sharedInstance] setFontForDetailedLabel:font];
}

- (id)init {
	if(self=[super init]) {
		self.obj_KSReachability = [KSReachability reachabilityToLocalNetwork];
	}
	return self;
}

- (void)showProgressHUD:(UIViewController *)vCtr titleText:(NSString *)titleText detailedText:(NSString *)detailedText {
    if(self.HUD) {
        [self hideProgressHUD];
    }
    self.HUD = [[MBProgressHUD alloc] initWithView:vCtr.view];
    [vCtr.view addSubview:self.HUD];
    self.HUD.labelText = titleText;
    self.HUD.detailsLabelText = detailedText;
    if (self.fontForDetailedLabel) self.HUD.detailsLabelFont = self.fontForDetailedLabel;
    if (self.fontForTitleLabel) self.HUD.labelFont = self.fontForTitleLabel;
    self.HUD.removeFromSuperViewOnHide = YES;
    [self.HUD show:NO];
}

- (void)hideProgressHUD {
    if(self.HUD) {
        if(self.HUD.superview) [self.HUD hide:NO];
        self.HUD = nil;
    }
}


@end

