//
//  XHWebImageOperation.m
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "XHWebImageOperation.h"
#import "XHWebImageCache.h"

@interface XHWebImageOperation ()

// Blocks
@property (copy, nonatomic) XHWebImageCompleteHandler completeBlock;
@property (copy, nonatomic) XHWebImageProgressHandler progressBlock;
// Connection
@property (strong, nonatomic) NSURLConnection *connection;
// Datas related attr.
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) UIImage *imageDownloaded;
@property (assign, nonatomic) long long expectedContentLength;
// NSOperation redefinition
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

// Helpers functions
- (NSDictionary *)createErrorUserInfoDictionnary;

@end

@implementation XHWebImageOperation
#pragma mark - Lifecycle

- (id)initWithRequest:(NSURLRequest *)request completeHandler:(XHWebImageCompleteHandler)completeBlock progressHandler:(XHWebImageProgressHandler)progressBlock {
    if(!(self = [super init]))
        return self;
    
    // Checking for required parameter
    if(!request)
    {
        DLog(@"%@", @"You must pass a NSURLRequest to create the operation object.");
        return self;
    }
    
    // Attributes init.
    _completeBlock = (completeBlock) ? [completeBlock copy] : nil;
    _progressBlock = (progressBlock) ? [progressBlock copy] : nil;
    _request = request;
    _receivedData = nil;
    _imageDownloaded = nil;
    _connection = nil;
    _expectedContentLength = 0;
    _executing = false;
    _finished = false;
    
    return self;
}

- (void)reset
{
    _expectedContentLength = 0;
    _receivedData = nil;
    _imageDownloaded = nil;
    _request = nil;
    _connection = nil;
    _completeBlock = nil;
    _progressBlock = nil;
}

#pragma mark - NSOperation behaviors

- (void)main {
    if(self.executing)
        return;
    self.executing = true;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                                  delegate:self
                                                          startImmediately:NO];
    [self setConnection:connection];
    [self.connection start];
    
    if(self.connection)
    {
        CFRunLoopRun();
        if(![self isFinished])
        {
            [self.connection cancel];
            [self connection:self.connection
            didFailWithError:[NSError errorWithDomain:XHWebImageErrorDomain
                                                 code:0
                                             userInfo:[self createErrorUserInfoDictionnary]]];
        }
    }
    else
    {
        if(self.completeBlock)
            self.completeBlock(nil, [NSError errorWithDomain:XHWebImageErrorDomain
                                                        code:XHWebImageErrorConnectionCode
                                                    userInfo:[self createErrorUserInfoDictionnary]]);
        [self cancel];
    }
}

- (void)cancel
{
    if(self.connection)
    {
        [self.connection cancel];
        self.executing = false;
        self.finished = true;
    }
    [self reset];
}

- (BOOL)isConcurrent
{
    return true;
}

#pragma mark - NSURLConnection Delegate Methods

// Download started.
// - Will call back the Complete Block if Error detected and Block setted at instanciation.
// - Operation will be cancelled.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(![response respondsToSelector:@selector(statusCode)] || ((NSHTTPURLResponse *)response).statusCode < 400)
    {
        self.expectedContentLength = response.expectedContentLength;
        NSMutableData *datas_container = [[NSMutableData alloc] initWithCapacity:(NSUInteger)self.expectedContentLength];
        [self setReceivedData:datas_container];
    }
    else
    {
        if(self.completeBlock)
            self.completeBlock(nil, [NSError errorWithDomain:XHWebImageErrorDomain
                                                        code:XHWebImageErrorHeaderStatusCode
                                                    userInfo:[self createErrorUserInfoDictionnary]]);
        [self cancel];
    }
}

// Downloading.
// Retrieved streaming and appended to instance variable.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(self.receivedData)
        [self.receivedData appendData:data];
    
    if(self.progressBlock)
        self.progressBlock(self.receivedData.length, (NSUInteger)self.expectedContentLength);
}

// Download failed.
// - Will call back the complete Block with NSError object, if setted at instanciation.
// - Operation will be reseted and released by parent Operation Queue.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Stopping loop
    CFRunLoopStop(CFRunLoopGetCurrent());
    
    // Executing complete block with error
    if(self.completeBlock)
        self.completeBlock(nil, error);
    
    // Reseting
    self.finished = true;
    self.executing = false;
    [self reset];
}

// Download finished.
// - Will call back the Complete Block with UIImage object if setted at instanciation.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Stopping loop
    CFRunLoopStop(CFRunLoopGetCurrent());
    
    // Creating image
    UIImage *image = [UIImage imageWithData:self.receivedData];
    
    // Executing complete block with image
    if(self.completeBlock)
        self.completeBlock(image, nil);
    
    // Adding image to cache
    [[XHWebImageCache shareWebImageCache] cacheImage:image                                        withKey:self.request.URL.relativeString andCacheType:XHWebImageCacheTypeDisk];
    
    // Reseting
    self.finished = true;
    self.executing = false;
    [self reset];
}

#pragma mark - Helpers

// Get NSDictionnary with Url info.
- (NSDictionary *)createErrorUserInfoDictionnary {
    if(!self.request)
        return nil;
    return [NSDictionary dictionaryWithObject:self.request.URL.relativeString forKey:XHWebImageErrorUrlKey];
}

@end
