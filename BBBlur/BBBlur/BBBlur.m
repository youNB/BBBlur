//
//  BBBlur.m
//  BBBlur
//
//  Created by 程肖斌 on 2019/1/24.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import "BBBlur.h"
#import <CoreImage/CoreImage.h>
#import <Accelerate/Accelerate.h>

@implementation BBBlur

+ (BBBlur *)sharedManager{
    static BBBlur *manager        = nil;
    static dispatch_once_t once_t = 0;
    dispatch_once(&once_t, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (UIImage *)gaussianBlur:(UIImage *)image
                     deep:(NSInteger)deep{
    //如果传入的image无效，直接返回，这个不能用断言
    if(!image){return image;}
    NSAssert(deep > 0, @"模糊的深度要大于0");
    
    //准备好需要的
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *input_image = [CIImage imageWithCGImage:image.CGImage];
    
    //设置filter
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:input_image forKey:kCIInputImageKey];
    [filter setValue:@(deep) forKey:@"inputRadius"];
    
    //开始模糊
    CIImage *output = [filter valueForKey:kCIOutputImageKey];
    CGImageRef output_image = [context createCGImage:output
                                            fromRect:input_image.extent];
    UIImage *result = [UIImage imageWithCGImage:output_image];
    
    CGImageRelease(output_image);
    
    return result;
}

- (UIImage *)vImageBlur:(UIImage *)image
                   deep:(NSInteger)deep{
    //如果传入的image无效，直接返回，这个不能用断言
    if(!image){return image;}
    NSAssert(deep > 0, @"模糊的深度要大于0");
    
    UIImage *result = image;
    
    //准备好资源
    uint32_t size = (uint32_t)(deep-(deep%2)+1);
    CGImageRef image_ref = image.CGImage;
    vImage_Buffer input_buffer, output_buffer;
    vImage_Error error;
    void *pixel_buffer;
    
    //从CGImage中获取数据
    CGDataProviderRef input_provider_ref = CGImageGetDataProvider(image_ref);
    CFDataRef input_bitmap_data_ref = CGDataProviderCopyData(input_provider_ref);
    
    //从CGImage中获取属性
    input_buffer.width  = CGImageGetWidth(image_ref);
    input_buffer.height = CGImageGetHeight(image_ref);
    input_buffer.rowBytes = CGImageGetBytesPerRow(image_ref);
    input_buffer.data = (void *)CFDataGetBytePtr(input_bitmap_data_ref);
    pixel_buffer = malloc(CGImageGetHeight(image_ref)*CGImageGetBytesPerRow(image_ref));
    if(!pixel_buffer){goto pixel_buffer_NULL;}
    
    output_buffer.data = pixel_buffer;
    output_buffer.width = CGImageGetWidth(image_ref);
    output_buffer.height = CGImageGetHeight(image_ref);
    output_buffer.rowBytes = CGImageGetBytesPerRow(image_ref);
    error = vImageBoxConvolve_ARGB8888(&input_buffer,
                                       &output_buffer,
                                       NULL,
                                       0,
                                       0,
                                       size,
                                       size,
                                       NULL,
                                       kvImageEdgeExtend);
    if(error){goto vImageBoxConvoleError;}
    
    CGColorSpaceRef color_ref = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(output_buffer.data,
                                             output_buffer.width,
                                             output_buffer.height,
                                             8,
                                             output_buffer.rowBytes,
                                             color_ref,
                                             CGImageGetBitmapInfo(image.CGImage));
    CGImageRef bitmap_image_ref = CGBitmapContextCreateImage(ctx);
    result = [UIImage imageWithCGImage:bitmap_image_ref];

    CGContextRelease(ctx);
    CGColorSpaceRelease(color_ref);
    CGImageRelease(bitmap_image_ref);
    
vImageBoxConvoleError:
    free(pixel_buffer);
    
pixel_buffer_NULL:
    CFRelease(input_bitmap_data_ref);
    
    return result;
}

@end
