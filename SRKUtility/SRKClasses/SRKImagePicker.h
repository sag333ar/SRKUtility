//
//  SRKImagePicker.h
//  SRKImagePicker
//
//  Created by sagar kothari
//  Copyright © 2016 sagar kothari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SRKImagePickerDelegate;

@interface SRKImagePicker : NSObject
- (id)initWithSourceType:(UIImagePickerControllerSourceType)type;
@property (nonatomic, weak) id<SRKImagePickerDelegate> delegate;
@property (nonatomic, assign) CGSize cropSize; //default value is 320x320 (which is exactly the same as the normal imagepicker uses)
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, assign) BOOL resizeableCropArea;

@end


@protocol SRKImagePickerDelegate <NSObject>

@optional

/**
 * @method imagePicker:pickedImage: gets called when a user has chosen an image
 * @param imagePicker the image picker instance
 * @param image the picked and cropped image
 */
- (void)imagePicker:(SRKImagePicker *)imagePicker pickedImage:(UIImage *)image;


/**
 * @method imagePickerDidCancel: gets called when the user taps the cancel button
 * @param imagePicker the image picker instance
 */
- (void)imagePickerDidCancel:(SRKImagePicker *)imagePicker;

@end
