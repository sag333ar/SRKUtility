//
//  SRKImageCropView.h
//  SRKImagePicker
//
//  Created by sagar kothari
//  Copyright © 2016 sagar kothari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRKImageCropView : UIView

@property (nonatomic, strong) UIImage *imageToCrop;
@property (nonatomic, assign) CGSize cropSize;
@property (nonatomic, assign) BOOL resizableCropArea;

- (UIImage *)croppedImage;

@end
