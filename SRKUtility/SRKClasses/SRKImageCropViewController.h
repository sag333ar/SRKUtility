//
//  SRKImageCropViewController.h
//  SRKImagePicker
//
//  Created by sagar kothari
//  Copyright © 2016 sagar kothari. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SRKImageCropControllerDelegate;

@interface SRKImageCropViewController : UIViewController{
    UIImage *_croppedImage;
}

@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, assign) CGSize cropSize; //size of the crop rect, default is 320x320
@property (nonatomic, assign) BOOL resizeableCropArea; 
@property (nonatomic, strong) id<SRKImageCropControllerDelegate> delegate;

@end


@protocol SRKImageCropControllerDelegate <NSObject>
@required
- (void)imageCropController:(SRKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage;
@end
