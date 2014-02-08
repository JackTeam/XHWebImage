//
//  XHWebImageCache.h
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
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

+ (instancetype)shareWebImageManager;

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
