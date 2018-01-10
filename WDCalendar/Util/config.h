//
//  config.h
//  FrameworkTest
//
//  Created by 吴丹 on 2017/8/24.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#ifndef config_h
#define config_h

#import "UIViewExt.h"

#define UI_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define UI_SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height

#define RGBA(r,g,b,a)       [UIColor colorWithRed:((r)/255.0) green:((g)/255.0) blue:((b)/255.0) alpha:(a)]

//rgb颜色
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kInvaildColor        UIColorFromRGB(0x969696)
#define kAppBaseColor              UIColorFromRGB(0x37c2f5)

#endif /* config_h */
