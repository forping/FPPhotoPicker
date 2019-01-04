//
//  UIImage+AIRendleModel.m
//  微博项目
//
//  Created by Medalands on 16/6/26.
//  Copyright © 2016年 medalands. All rights reserved.
//

#import "UIImage+AIRendleModel.h"

@implementation UIImage (AIRendleModel)

+ (instancetype)imageWithOriginalName:(NSString *)imageName{
    
    return [[UIImage imageNamed:imageName]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
}

+ (instancetype)imageWithStretchableName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

+ (instancetype) roundImageViewColor:(UIColor *)color sideLength:(CGFloat)length{
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(length, length), NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, length, length));
    [color set];
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return image;
}

+ (instancetype)colorImage:(UIColor *)color{
    
    return [self colorImage:color size:CGSizeMake(1, 1)];
}

+ (instancetype)colorImage:(UIColor *)color size:(CGSize)size{
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;

    
}


@end
