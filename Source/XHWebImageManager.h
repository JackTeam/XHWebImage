//
//  XHWebImageManager.h
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHWebImage.h"
#import "XHWebImageCache.h"
#import "XHWebImageOperation.h"

#pragma mark - Manager Protocol

@protocol XHWebImageManagerDelegate <NSObject>
@required
- (void)downloadImageAtURL:(NSURL *)url completeHandler:(XHWebImageCompleteHandler)completeBlock progressHandler:(XHWebImageProgressHandler)progressBlock;
@end

@interface XHWebImageManager : NSObject <XHWebImageManagerDelegate>

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (weak, nonatomic, readonly) XHWebImageCache *webImageCache;

+ (instancetype)shareWebImageManager;

@end
