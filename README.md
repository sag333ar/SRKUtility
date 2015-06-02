# SRKUtility

###Installation
Use `pod 'SRKUtility'` under your `Podfile` and run `pod install` command to install library.

###Summary
A pod which helps you to easily save values to `NSUserDefaults`, display `MBProgressHUD` and check Network Reachability.

###Using library
Import the library in your class as indicated below.

    #import <SRKUtility/SRKUtility.h>

***

####Accessing `NSUserDefaults`

#####Storing values to `NSUserDefaults`

     // save value for key. Only supports Bool, Number, String, Dictionary, Array
     [SRKUtility saveValue:@"Cricket" forKey:@"UserFavGame"];
    
#####Accessing values stored to `NSUserDefaults`

     // get the value for key
     NSString *strValue = [SRKUtility getValueForKey:@"UserFavGame"];

#####Deleting value from `NSUserDefaults`

     [SRKUtility deleteValueForKey:@"UserFavGame"];

***

####Show and Hide `MBProgressHUD`

#####Displaying `MBProgressHUD`

     [SRKUtility showProgressHUD:self.window.rootViewController 
                       titleText:@"Loading data" 
                    detailedText:@"Please wait"];

#####Hiding `MBProgressHUD`

     [SRKUtility hideProgressHUD];

#####Changing font for `MBProgressHUD` title
This is one time settings only. Once it is set, It'll be applicable for all progresshud which are about to be shown.

     [SRKUtility setFontForProgressHUDTitleLabel:[UIFont systemFontOfSize:13]];

#####Changing font for `MBProgressHUD` subtitle

     [SRKUtility setFontForProgressHUDDetailedLabel:[UIFont systemFontOfSize:11]];

***

####Reachability Integration

#####Initiate Reachability

     - (BOOL)application:(UIApplication *)application 
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         [SRKUtility isReachableToLocalNetwork];
     }

#####Check Rechability

     if ([SRKUtility isReachableToLocalNetwork]) {
        NSLog(@"Wow! Internet is working :)");
     } else {
        NSLog(@"Oh No! Internet not working :(");
     }

***

#### Alerts in One line

#####Declaration of Alert method is as follows.

     void ALERT(NSString *title, 
                NSString *message,
                NSString *canceBtnTitle,
                id delegate,
                NSString *otherButtonTitles, ... );

#####Showing Alerts in one line.

    ALERT(@"Some alert title",
          @"Some alert message belongs here.", 
          @"Cancel button",
          self,
          @"Other buttons");

####Showing Error messages in One line with just title and message.

#####Declaration

     #define ALERT_ERROR(title,message)    dispatch_async(dispatch_get_main_queue(), ^{  \
                                                 ALERT(title, message, @"Okay", nil, nil); \
                                            });

#####Showing error message

     ALERT_ERROR(@"Oh Ah!", @"Some error occured.");

***
