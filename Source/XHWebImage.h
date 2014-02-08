//
//  XHWebImage.h
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#ifndef XHWebImage_XHWebImage_h
#define XHWebImage_XHWebImage_h

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

// NSError related
#define XHWebImageErrorDomain               @"XHWebImageErrorDomain"
#define XHWebImageErrorUrlKey               @"XHWebURL"
#define XHWebImageErrorHeaderStatusCode     666
#define XHWebImageErrorConnectionCode       667

// Completion Block
typedef void (^XHWebImageCompleteHandler)(UIImage *image, NSError *error);
// Progress Block
typedef void (^XHWebImageProgressHandler)(NSUInteger currentSize, NSUInteger totalSize);

#endif
