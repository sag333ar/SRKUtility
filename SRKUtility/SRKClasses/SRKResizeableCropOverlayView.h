//
//  SRKResizeableCropOverlayView.h
//  SRKImagePicker
//
//  Created by sagar kothari
//  Copyright © 2016 sagar kothari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRKCropBorderView.h"
#import "SRKImageCropOverlayView.h"

typedef struct {
    int widhtMultiplyer;
    int heightMultiplyer;
    int xMultiplyer;
    int yMultiplyer;
}SRKResizeableViewBorderMultiplyer;

@interface SRKResizeableCropOverlayView : SRKImageCropOverlayView

@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong, readonly) SRKCropBorderView *cropBorderView;

/**
 call this method to create a resizable crop view
 @param frame frame for image
 @param contentSize crop size
 @return crop view instance
 */
-(id)initWithFrame:(CGRect)frame andInitialContentSize:(CGSize)contentSize;

@end
