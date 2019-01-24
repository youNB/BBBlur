//
//  BBBlur.h
//  BBBlur
//
//  Created by 程肖斌 on 2019/1/24.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>

@interface BBBlur : UIView

/*
    单例，建议模糊的图片不要有alpha通道，不然容易变成黑色
*/
+ (BBBlur *)sharedManager;

/*
    高斯模糊效果
    image：传入的需要模糊的图片
    deep：模糊的深度，值越大，越模糊，建议取值范围8～12
 */
- (UIImage *)gaussianBlur:(UIImage *)image
                     deep:(NSInteger)deep;

/*
    vImage模糊效果，模糊效率很高，可以做动态模糊效果
    image：传入的需要模糊的图片
    deep：模糊的深度，值越大，越模糊，建议取值30~40
 */
- (UIImage *)vImageBlur:(UIImage *)image
                   deep:(NSInteger)deep;

@end

