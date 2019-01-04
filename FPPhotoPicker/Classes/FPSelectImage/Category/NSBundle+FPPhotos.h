//
//  NSBundle+FPPhotos.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//
// 得到bundle里的图片

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
/*** 避免直接使用路径获取image导致的nil ***/
@interface NSBundle (FPPhotos)
/// 确保使用自己的bundle
@property (nonatomic, strong, readonly, class)NSBundle *fp_bundle;

/*Group*/
@property (nonatomic, strong, readonly, class)UIImage *fp_placeholder;
@property (nonatomic, strong, readonly, class)UIImage *fp_arrow_right;

/*Collection*/
@property (nonatomic, strong, readonly, class)UIImage *fp_deselect;

/*Horiscroll --  Browse*/
@property (nonatomic, strong, readonly, class)UIImage *fp_brower_selected;
@property (nonatomic, strong, readonly, class)UIImage *fp_browse_back;
@property (nonatomic, strong, readonly, class)UIImage *fp_bottomSelected;
@property (nonatomic, strong, readonly, class)UIImage *fp_bottomUnselected;
@property (nonatomic, strong, readonly, class)UIImage *fp_video_play;


@end

NS_ASSUME_NONNULL_END
