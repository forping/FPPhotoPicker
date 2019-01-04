//
//  FPSelectImageConfig.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//

#import "FPPhotosConfig.h"

@implementation FPPhotosConfig

- (instancetype)init{
    
    if (self = [super init]) {
        
        self.maxPhotosCount = 9;
        self.containVideo = YES;
        self.hiddenGroupWhenNoPhotos = YES;
        self.thumbnailSize = CGSizeZero;
        
    }
    return self;
}


- (FPPhotosConfig * (^)(NSInteger maxPhotosCount)) setMaxPhotosCount{
    
    return ^(NSInteger maxPhotosCount){
     
        self.maxPhotosCount = maxPhotosCount;
        
        return self;
    };
    
}
- (FPPhotosConfig * (^)(BOOL containVideo)) setContainVideo{
    return ^(BOOL containVideo){
        self.containVideo = containVideo;
        return self;
        
    };
}
- (FPPhotosConfig * (^)(BOOL hiddenGroupWhenNoPhotos)) setHiddenGroupWhenNoPhotos{
 
    return ^(BOOL hiddenGroupWhenNoPhotos){
        
        self.hiddenGroupWhenNoPhotos = hiddenGroupWhenNoPhotos;
        return self;
    };
}


- (FPPhotosConfig * (^)(CGSize thumbnailSize)) setThumbnailSize{
    
    return ^(CGSize thumbnailSize){
        
        self.thumbnailSize = thumbnailSize;
        return self;
    };
}
















@end
