//
//  UIImageView+XHWebImage.m
//  XHWebImage
//
//  Created by 曾 宪华 on 14-2-8.
//  Copyright (c) 2014年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "UIImageView+XHWebImage.h"
#import "XHWebImageManager.h"
#import "UIImage+Rounded.h"

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
        }
        
        // Launching downloading
        [self downloadImageAtUrl:[NSURL URLWithString:url] placeholder:placeholder completeHandler:[self completeBlockWithImageRoundRadius:radius] progressHandler:nil];
    }
    
    return self;
}

- (void)setImageAtUrl:(NSString *)url placeholder:(UIImage *)placeholder {
    [self setImageAtUrl:url placeholder:placeholder imageRoundRadius:0];
}

- (void)setImageAtUrl:(NSString *)url placeholder:(UIImage *)placeholder imageRoundRadius:(CGFloat)radius {
    [self setImageAtUrl:url placeholder:placeholder completeHandler:[self completeBlockWithImageRoundRadius:radius] progressHandler:nil];
}

- (void)setImageAtUrl:(NSString *)url placeholder:(UIImage *)placeholder completeHandler:(XHWebImageCompleteHandler)completeBlock progressHandler:(XHWebImageProgressHandler)progressBlock {
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
    }
    
    // Launching downloading
    [[XHWebImageManager shareWebImageManager] downloadImageAtURL:url completeHandler:completeBlock progressHandler:progressBlock];
}

#pragma mark - Blocks
// Complete block
- (XHWebImageCompleteHandler)completeBlockWithImageRoundRadius:(CGFloat)radius
{
    // Keeping reference to self, without retaining it.
    __weak UIImageView *wself = self;
    return ^void(UIImage *image, NSError *error){
        if(error) {
            NSLog(@"Error : %@", error);
        }
        if(wself && image)
        {
//            UIImage *roundedImage = nil;
//            if (radius) {
//                roundedImage = [UIImage createRoundedRectImage:image size:image.size roundRadius:radius];
//            } else {
//                roundedImage = image;
//            }
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               if(wself && image)
                               {
                                   [wself setImage:image];
                               }
                           });
        }
    };
}

@end
