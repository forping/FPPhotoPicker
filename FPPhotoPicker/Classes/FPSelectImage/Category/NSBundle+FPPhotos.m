//
//  NSBundle+FPPhotos.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//

#import "NSBundle+FPPhotos.h"


@interface NSString (FPPhotosBundle)

@property (nonatomic, strong, readonly, nullable) UIImage * fp_bundleImage;

@end

@implementation NSString (FPPhotosBundle)

- (UIImage *)fp_bundleImage
{
    return [UIImage imageWithContentsOfFile:[[NSBundle.fp_bundle resourcePath] stringByAppendingPathComponent:self]];
}

@end


@implementation NSBundle (FPPhotos)
+ (NSBundle *)fp_bundle
{
    static NSBundle *_fp_bundle = nil;
    
    if (_fp_bundle == nil) {
        
        _fp_bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:NSClassFromString(@"FPPhotosViewController")]pathForResource:@"FPPhotos" ofType:@"bundle"]];
    }
    
    return _fp_bundle;
}


+ (UIImage *)fp_arrow_right
{
    return @"fp_arrow_right".fp_bundleImage;
}

+ (UIImage *)fp_placeholder
{
    return @"fp_placeholder".fp_bundleImage;
}

+ (UIImage *)fp_browse_back
{
    return @"fp_browse_back".fp_bundleImage;
}


+ (UIImage *)fp_deselect
{
    return @"fp_deselect".fp_bundleImage;
}

+ (UIImage *)fp_brower_selected
{
    return @"fp_brower_selected".fp_bundleImage;
}

+ (UIImage *)fp_bottomSelected
{
    return @"fp_bottomSelected".fp_bundleImage;
}

+ (UIImage *)fp_bottomUnselected
{
    return @"fp_bottomUnselected".fp_bundleImage;
}

+ (UIImage *)fp_video_play
{
    return @"fp_video_play".fp_bundleImage;
}



@end
