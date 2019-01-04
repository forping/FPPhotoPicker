
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PHAsset, PHCachingImageManager;
/// 普通图片的cell
@interface FPPhotosBrowseImageCell : UICollectionViewCell

/// 显示图片的imageView
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

/// 底部负责滚动的滚动视图
@property (strong, nonatomic, readonly) IBOutlet UIScrollView *bottomScrollView;



@property (nonatomic, weak, nullable)PHAsset *currentAsset;
@property (nonatomic, copy) NSString *representedAssetIdentifier;

@end

NS_ASSUME_NONNULL_END
