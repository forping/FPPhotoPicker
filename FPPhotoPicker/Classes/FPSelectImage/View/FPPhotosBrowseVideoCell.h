//
//  FPPhotosBrowseVideoCell.h

//
//  Created by forping on 2018/4/29.
//  Copyright © 2018年 forping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PHAsset, PHCachingImageManager;
/// 用于播放视频的cell
@interface FPPhotosBrowseVideoCell : UICollectionViewCell

/// 显示图片的imageView
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
/// 显示播放按钮的视图
@property (nonatomic, strong) UIImageView *playImageView;
/// 播放的layer
@property (nonatomic, strong, nullable) AVPlayerLayer *playerLayer;


@property (nonatomic, weak, nullable)PHAsset *currentAsset;
@property (nonatomic, copy) NSString *representedAssetIdentifier;



@end

NS_ASSUME_NONNULL_END
