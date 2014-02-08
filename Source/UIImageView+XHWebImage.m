//
//  UIImageView+XHWebImage.m
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "UIImageView+XHWebImage.h"
#import "XHWebImageManager.h"

@implementation UIImageView (XHWebImage)

- (id)initWithImageAtUrl:(NSString *)url placeholder:(UIImage *)placeholder {
    return [self initWithImageAtUrl:url placeholder:placeholder imageRoundRadius:0];
}

- (id)initWithImageAtUrl:(NSString *)url placeholder:(UIImage *)placeholder imageRoundRadius:(CGFloat)radius {
    // Need URL
    if(!url)
        return self;
    
    if((self = [super init]))
    {
        // Setting Placeholder
        if(placeholder)
        {
            [self setImage:placeholder];
            [self setNeedsLayout];
        }
        
        // Launching downloading
        [self downloadImageAtUrl:[NSURL URLWithString:url] placeholder:placeholder completeHandler:[self completeBlock] progressHandler:nil];
    }
    
    return self;
}

- (void)setImageAtUrl:(NSString *)url placeholder:(UIImage *)placeholder {
    [self setImageAtUrl:url placeholder:placeholder imageRoundRadius:0];
}

- (void)setImageAtUrl:(NSString *)url placeholder:(UIImage *)placeholder imageRoundRadius:(CGFloat)radius {
    [self setImageAtUrl:url placeholder:placeholder imageRoundRadius:radius completeHandler:[self completeBlock] progressHandler:nil];
}

- (void)setImageAtUrl:(NSString *)url placeholder:(UIImage *)placeholder imageRoundRadius:(CGFloat)radius completeHandler:(XHWebImageCompleteHandler)completeBlock progressHandler:(XHWebImageProgressHandler)progressBlock {
    [self downloadImageAtUrl:[NSURL URLWithString:url] placeholder:placeholder completeHandler:completeBlock progressHandler:progressBlock];
}

#pragma mark - Internal download function

- (void)downloadImageAtUrl:(NSURL *)url placeholder:(UIImage *)placeholder completeHandler:(XHWebImageCompleteHandler)completeBlock progressHandler:(XHWebImageProgressHandler)progressBlock
{
    if(!url)
        return;
    
    // Setting Placeholder
    if(placeholder)
    {
        [self setImage:placeholder];
        [self setNeedsLayout];
    }
    
    // Launching downloading
    [[XHWebImageManager shareWebImageManager] downloadImageAtURL:url completeHandler:completeBlock progressHandler:progressBlock];
}

#pragma mark - Blocks
// Complete block
- (XHWebImageCompleteHandler)completeBlock
{
    // Keeping reference to self, without retaining it.
    __weak UIImageView *wself = self;
    return ^void(UIImage *image, NSError *error){
        if(error) {
            NSLog(@"Error : %@", error);
        }
        if(wself && image)
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               if(wself && image)
                               {
                                   [wself setImage:image];
                                   [wself setNeedsLayout];
                                   [wself setNeedsUpdateConstraints];
                               }
                           });
        }
    };
}

@end
