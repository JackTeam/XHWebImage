//
//  XHWebImageCache.h
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Cache type

typedef enum {
    XHWebImageCacheTypeMemory,
    XHWebImageCacheTypeDisk
} XHWebImageCacheType;

@interface XHWebImageCache : NSObject

/**
 * The maximum length of time to keep an image in the cache, in seconds
 */
@property (assign, nonatomic) NSInteger maxCacheAge;

/**
 * The maximum size of the cache, in bytes.
 */
@property (assign, nonatomic) NSUInteger maxCacheSize;

+ (instancetype)shareWebImageCache;

// cache
/**
 * synchronously cache image in Memory or Disk
 */
- (void)cacheImage:(UIImage *)image withKey:(NSString *)key andCacheType:(XHWebImageCacheType)cacheType;
- (UIImage *)imageFromCacheWithKey:(NSString *)key andCacheType:(XHWebImageCacheType)cacheType;
- (void)removeImageWithKey:(NSString *)key andCacheType:(XHWebImageCacheType)cacheType;
- (void)clearCacheWithCacheType:(XHWebImageCacheType)cacheType;

// cache info
/**
 * Asynchronously calculate the disk cache's size.
 */
- (void)calculateSizeWithCompletionBlock:(void (^)(NSUInteger fileCount, NSUInteger totalSize))completionBlock;

@end
