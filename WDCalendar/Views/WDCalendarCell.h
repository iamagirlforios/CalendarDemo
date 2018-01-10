//
//  WDCalendarCell.h
//  WDCalendar
//
//  Created by 吴丹 on 17/3/14.
//  Copyright © 2017年 吴丹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDCalendarDateModel.h"

@interface WDCalendarCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *subLabel;
@property (nonatomic, assign) BOOL isHoliday;
@property (nonatomic, assign) BOOL isWokeDay;
@property (nonatomic, assign) BOOL isToday;  //是否是今天
@property (nonatomic, assign) BOOL isInvalid;  //是否是无效的日期
@property (nonatomic, assign) CollectionViewCellDayType style;//显示的样式
@end
