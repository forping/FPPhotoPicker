//
//  UIImage+AIRendleModel.h
//  微博项目
//
//  Created by Medalands on 16/6/26.
//  Copyright © 2016年 medalands. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AIRendleModel)

// id:能调用任何对象的get 和 set 方法，不能帮我们检测错误

// 默认会识别当前是哪个类或者对象调用，就会转换成相应类的对象
//

// 加载最原始的图片 没有渲染的
+ (instancetype) imageWithOriginalName:(NSString *)imageName;

+ (instancetype)imageWithStretchableName:(NSString *)imageName;


/**
 给定颜色和体积,画出一个纯色的圆的图片

 @param color  颜色
 @param length 边长

 @return <#return value description#>
 */
+ (instancetype) roundImageViewColor:(UIColor *)color sideLength:(CGFloat)length;


/**
 给定颜色，制造imahe

 @param color <#color description#>
 @return <#return value description#>
 */
+ (instancetype) colorImage:(UIColor *)color;

+ (instancetype)colorImage:(UIColor *)color size:(CGSize)size;

@end
