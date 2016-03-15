//
//  XHWebImageCache.m
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "XHWebImageCache.h"
#import "XHWebImage.h"
#import <CommonCrypto/CommonDigest.h>

static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7; // 1 week

@interface XHWebImageCache () {
    NSFileManager *_fileManager;
}

@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, strong) NSString *diskCachePath;

@property (nonatomic, strong) dispatch_queue_t ioQueue;

- (CGFloat)memoryCostForImage:(UIImage *)image;
@end

@implementation XHWebImageCache

#pragma mark - Life cycle

- (void)_setup {
    // Create IO serial queue
    _ioQueue = dispatch_queue_create("com.JackTeam.XHWebImageCache", DISPATCH_QUEUE_SERIAL);
    
    // Init default values
    _maxCacheAge = kDefaultCacheMaxCacheAge;
    
    _memoryCache = [[NSCache alloc] init];
    _memoryCache.name = @"com.JackTeam.XHWebImageCache";
    
    // Init the disk cache
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _diskCachePath = [paths[0] stringByAppendingPathComponent:@"com.JackTeam.XHWebImageCache"];
    
    dispatch_sync(_ioQueue, ^{
        _fileManager = [NSFileManager new];
    });
    
#if TARGET_OS_IPHONE
    // Subscribe to app events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearMemory)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanDisk)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundCleanDisk)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
#endif
}

- (id)init {
    if((self = [super init])) {
        [self _setup];
    }
    
    return self;
}

+ (instancetype)shareWebImageCache {
    static XHWebImageCache *webImageCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webImageCache = [[XHWebImageCache alloc] init];
    });
    return webImageCache;
}

#pragma mark SDImageCache (private)

- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path {
    NSString *filename = [self cachedFileNameForKey:key];
    return [path stringByAppendingPathComponent:filename];
}

- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [self cachePathForKey:key inPath:self.diskCachePath];
}

- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

#pragma mark - Cache operations

- (void)cacheImage:(UIImage *)image withKey:(NSString *)key andCacheType:(XHWebImageCacheType)cacheType {
    if(!key || !image)
        return;
    if(self.memoryCache)
        @synchronized(self) {
            [self.memoryCache setObject:image forKey:key cost:[self memoryCostForImage:image]];
        }
    else
        DLog(@"Impossible to add image to memory cache. NSCache is not initialized.");
    
    if (cacheType == XHWebImageCacheTypeDisk) {
        NSData *imageData = UIImagePNGRepresentation(image);
        if (imageData) {
            NSFileManager *fileManager = [NSFileManager new];
            
            if (![fileManager fileExistsAtPath:_diskCachePath]) {
                [fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
            }
            
            [fileManager createFileAtPath:[self defaultCachePathForKey:key] contents:imageData attributes:nil];
        }
    }
    else
        DLog(@"Unknow type of cache.");
}

// Get image from cache identified by key and type.
- (UIImage *)imageFromCacheWithKey:(NSString *)key andCacheType:(XHWebImageCacheType)cacheType {
    if(!key)
        return nil;
    
    if(self.memoryCache)
        @synchronized(self) {
            return [self.memoryCache objectForKey:key];
        }
    else
        DLog(@"Impossible to get image from memory cache. NSCache is not initialized.");
    
    if (cacheType == XHWebImageCacheTypeDisk) {
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:[self defaultCachePathForKey:key]];
        if (imageData) {
            return [UIImage imageWithData:imageData];
        }
    }
    else
        DLog(@"Unknow type of cache.");
    
    return nil;
}

// Remove image from cache identified by given key and type.
- (void)removeImageWithKey:(NSString *)key andCacheType:(XHWebImageCacheType)cacheType {
    if(!key)
        return;
    
    if(cacheType == XHWebImageCacheTypeMemory) {
        if(self.memoryCache)
            @synchronized(self) {
            [self.memoryCache removeObjectForKey:key];
        }
        else
            DLog(@"Impossible to remove image from memory cache. NSCache is not initialized.");
    } else if (cacheType == XHWebImageCacheTypeDisk) {
        dispatch_async(self.ioQueue, ^{
            [[NSFileManager defaultManager] removeItemAtPath:[self defaultCachePathForKey:key] error:nil];
        });
    }
    else
        DLog(@"Unknow type of cache.");
}

// Remove all content cached in given type.
- (void)clearCacheWithCacheType:(XHWebImageCacheType)cacheType {
    if(cacheType == XHWebImageCacheTypeMemory) {
        if(self.memoryCache)
            @synchronized(self) {
            [self clearMemory];
        }
        else
            DLog(@"Impossible to clear memory cache. NSCache is not initialized.");
    } else if (cacheType == XHWebImageCacheTypeDisk) {
        dispatch_async(self.ioQueue, ^{
            [[NSFileManager defaultManager] removeItemAtPath:self.diskCachePath error:nil];
            [[NSFileManager defaultManager] createDirectoryAtPath:self.diskCachePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        });
    }
    else
        DLog(@"Unknow type of cache.");
}

- (void)clearMemory {
    [self.memoryCache removeAllObjects];
}

- (void)cleanDisk {
    dispatch_async(self.ioQueue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
        
        // This enumerator prefetches useful properties for our cache files.
        NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:diskCacheURL
                                                  includingPropertiesForKeys:resourceKeys
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                errorHandler:NULL];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
        NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
        NSUInteger currentCacheSize = 0;
        
        // Enumerate all of the files in the cache directory.  This loop has two purposes:
        //
        //  1. Removing files that are older than the expiration date.
        //  2. Storing file attributes for the size-based cleanup pass.
        for (NSURL *fileURL in fileEnumerator) {
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
            
            // Skip directories.
            if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            
            // Remove files that are older than the expiration date;
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [fileManager removeItemAtURL:fileURL error:nil];
                continue;
            }
            
            // Store a reference to this file and account for its total size.
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
            [cacheFiles setObject:resourceValues forKey:fileURL];
        }
        
        // If our remaining disk cache exceeds a configured maximum size, perform a second
        // size-based cleanup pass.  We delete the oldest files first.
        if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize) {
            // Target half of our maximum cache size for this cleanup pass.
            const NSUInteger desiredCacheSize = self.maxCacheSize / 2;
            
            // Sort the remaining cache files by their last modification time (oldest first).
            NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                            usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                            }];
            
            // Delete files until we fall below our desired cache size.
            for (NSURL *fileURL in sortedFiles) {
                if ([fileManager removeItemAtURL:fileURL error:nil]) {
                    NSDictionary *resourceValues = cacheFiles[fileURL];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                    
                    if (currentCacheSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
    });
}

- (void)backgroundCleanDisk {
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Do the work associated with the task, preferably in chunks.
        [self cleanDisk];
        
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}

#pragma mark - Cache info

- (void)calculateSizeWithCompletionBlock:(void (^)(NSUInteger, NSUInteger))completionBlock {
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
    
    dispatch_async(self.ioQueue, ^{
        NSUInteger fileCount = 0;
        NSUInteger totalSize = 0;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:diskCacheURL
                                                  includingPropertiesForKeys:@[NSFileSize]
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                errorHandler:NULL];
        
        for (NSURL *fileURL in fileEnumerator) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            totalSize += [fileSize unsignedIntegerValue];
            fileCount += 1;
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(fileCount, totalSize);
            });
        }
    });
}

#pragma mark - Helpers

// Image size, cost for memory.
- (CGFloat)memoryCostForImage:(UIImage *)image {
    if(image)
        return (image.size.height * image.size.width * image.scale);
    return 0;
}

@end
