//
//  SRKImagePicker.m
//  SRKImagePicker
//
//  Created by sagar kothari
//  Copyright © 2016 sagar kothari. All rights reserved.
//

#import "SRKImagePicker.h"
#import "SRKImageCropViewController.h"

@interface SRKImagePicker ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, SRKImageCropControllerDelegate>
- (void)_hideController;
@end

@implementation SRKImagePicker

#pragma mark -
#pragma mark Getter/Setter

@synthesize cropSize, delegate, resizeableCropArea;
@synthesize imagePickerController = _imagePickerController;


#pragma mark -
#pragma mark Init Methods

- (id)init{
    if (self = [super init]) {
		CGSize size = CGSizeMake(320, 320);
		self.cropSize = size;
        self.resizeableCropArea = NO;
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return self;
}

- (id)initWithSourceType:(UIImagePickerControllerSourceType)type {
	if (self = [super init]) {
		CGSize size = CGSizeMake(320, 320);
		self.cropSize = size;
		self.resizeableCropArea = NO;
		_imagePickerController = [[UIImagePickerController alloc] init];
		_imagePickerController.delegate = self;
		_imagePickerController.sourceType = type;
	}
	return self;
}

# pragma mark -
# pragma mark Private Methods

- (void)_hideController{
	[self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UIImagePickerDelegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    if ([self.delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
      
        [self.delegate imagePickerDidCancel:self];
        
    } else {
        
        [self _hideController];
    
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    SRKImageCropViewController *cropController = [[SRKImageCropViewController alloc] init];
    cropController.preferredContentSize = picker.preferredContentSize;
    cropController.sourceImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    cropController.resizeableCropArea = self.resizeableCropArea;
    cropController.cropSize = self.cropSize;
    cropController.delegate = self;
    [picker pushViewController:cropController animated:YES];
    
}

#pragma mark -
#pragma SRKImagePickerDelegate

- (void)imageCropController:(SRKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage{
    
    if ([self.delegate respondsToSelector:@selector(imagePicker:pickedImage:)]) {
        [self.delegate imagePicker:self pickedImage:croppedImage];   
    }
}

@end
