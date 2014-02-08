//
//  UIImage+Rounded.h
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Rounded)
+ (UIImage *)createRoundedRectImage:(UIImage *)image size:(CGSize)size roundRadius:(CGFloat)radius; // radius default is 8
@end
