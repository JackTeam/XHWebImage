//
//  XHWebImageOperation.h
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHWebImage.h"

@interface XHWebImageOperation : NSOperation <NSURLConnectionDelegate>

@property (strong, nonatomic, readonly) NSURLRequest *request;

- (id)initWithRequest:(NSURLRequest *)request completeHandler:(XHWebImageCompleteHandler)completeBlock progressHandler:(XHWebImageProgressHandler)progressBlock;
@end
