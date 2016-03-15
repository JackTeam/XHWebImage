//
//  XHWebImageManager.h
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHWebImage.h"
#import "XHWebImageCache.h"

#pragma mark - Manager Protocol

@protocol XHWebImageManagerInterface <NSObject>
@required
- (void)downloadImageAtURL:(NSURL *)url completeHandler:(XHWebImageCompleteHandler)completeBlock progressHandler:(XHWebImageProgressHandler)progressBlock;
@end


#pragma mark - Manager

@interface XHWebImageManager : NSObject <XHWebImageManagerInterface>

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (weak, nonatomic, readonly) XHWebImageCache *webImageCache;

+ (XHWebImageManager *)shareWebImageManager;

@end
