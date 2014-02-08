//
//  UIImageView+XHWebImage.h
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHWebImage.h"

@interface UIImageView (XHWebImage)

- (id)initWithImageAtUrl:(NSString *)url placeholder:(UIImage *)placeholder;

- (id)initWithImageAtUrl:(NSString *)url placeholder:(UIImage *)placeholder imageRoundRadius:(CGFloat)radius;

- (void)setImageAtUrl:(NSString *)url placeholder:(UIImage *)placeholder;

- (void)setImageAtUrl:(NSString *)url placeholder:(UIImage *)placeholder imageRoundRadius:(CGFloat)radius;

- (void)setImageAtUrl:(NSString *)url placeholder:(UIImage *)placeholder imageRoundRadius:(CGFloat)radius completeHandler:(XHWebImageCompleteHandler)completeBlock progressHandler:(XHWebImageProgressHandler)progressBlock;

@end
