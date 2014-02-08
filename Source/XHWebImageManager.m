//
//  XHWebImageManager.m
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHWebImageManager.h"

@interface XHWebImageManager ()

@end

@implementation XHWebImageManager

#pragma mark - Life cycle

- (void)_setup {
    _operationQueue = [[NSOperationQueue alloc] init];
    [_operationQueue setName:@"XHWebImageOperationQueue"];
    [_operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    _webImageCache = [XHWebImageCache shareWebImageCache];
}

- (id)init
{
    @synchronized(self)
    {
        self = [super init];
        [self _setup];
        return self;
    }
}

+ (instancetype)shareWebImageManager {
    static dispatch_once_t onceToken;
    static XHWebImageManager *webImageManager;
    dispatch_once(&onceToken, ^{
        webImageManager = [[XHWebImageManager alloc] init];
    });
    return webImageManager;
}

#pragma mark - Operations

- (void)downloadImageAtURL:(NSURL *)url completeHandler:(XHWebImageCompleteHandler)completeBlock progressHandler:(XHWebImageProgressHandler)progressBlock
{
    // Need URL
    if(!url)
    {
        DLog(@"Please make sure that your URL object is not nil to download an image.");
        return;
    }
    
    // Checking for cache
    UIImage *cachedImage = [self.webImageCache imageFromCacheWithKey:url.relativeString andCacheType:XHWebImageCacheTypeMemory];
    
    // Image cached, do not need to go further
    if(cachedImage)
    {
        DLog(@"Cached Image available");
        if(completeBlock)
            completeBlock(cachedImage, nil);
        return;
    }
    
    // Creating Request without interval
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // Creating Custom Operation
    XHWebImageOperation *operation = [[XHWebImageOperation alloc] initWithRequest:request completeHandler:completeBlock progressHandler:progressBlock];
    if(!operation)
    {
        DLog(@"Impossible to download Image at URL : %@", url.relativeString);
        return;
    }
    // Adding operation to queue
    [self.operationQueue addOperation:operation];
}

@end
