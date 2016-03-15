//
//  XHWebImage.h
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
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
