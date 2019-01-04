//
//  FPPhotosTool.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/6.
//  Copyright © 2018 forping. All rights reserved.
//

#import "FPPhotosTool.h"
#import <Photos/Photos.h>

@interface FPPhotosTool ()

@property (nonatomic , strong) PHPhotoLibrary *photoLibrary;

@end

@implementation FPPhotosTool

fp_singleM(FPPhotosTool)

+ (void) hasPhotosAuthorization:(void(^)(BOOL has))block{
    PHAuthorizationStatus photoAuthStatus = [PHPhotoLibrary authorizationStatus];
    
    if (photoAuthStatus == PHAuthorizationStatusNotDetermined) { // 没有选择
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) { // 请求权限
            if(status == PHAuthorizationStatusAuthorized){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (block) {
                        block(YES);
                    }
                });
                
            }
            else{
                if (block) {
                    block(NO);
                }
            }
            
        }];
    }
    else  if ((photoAuthStatus == PHAuthorizationStatusRestricted) || (photoAuthStatus ==  PHAuthorizationStatusDenied)) { // 没有权限
        if (block) {
            block(NO);
        }
    }
    else{ // 有权限
        if (block) {
            block(YES);
        }
    }
}

- (PHPhotoLibrary *)photoLibrary{
    if (_photoLibrary == nil) {
        _photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    }
    return _photoLibrary;
}


+ (void) systemAlbumHasPtotoWithAssetIdentifier:(NSString *)Identifier has:(void(^)(BOOL has))block{
    
    [self hasPhotosAuthorization:^(BOOL has) {
        if (has) {
            PHFetchResult<PHAsset *> *array = [PHAsset fetchAssetsWithLocalIdentifiers:@[Identifier] options:nil];
            if (block) {
                block(array.count>0?YES:NO);
            }
        }
        else{
            if (block) {
                block(NO);
            }
        }
    }];
}

@end
