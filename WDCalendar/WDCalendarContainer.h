//
//  YXTCalendarContainer.h
//  QiHua
//
//  Created by 吴丹 on 17/3/22.
//  Copyright © 2017年 pzdf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDCalendarDateModel.h"
#import "WDCalendarView.h"

//显示日历的容器

typedef NS_ENUM(NSInteger, ContainerType) {
    ContainerTypeMonth = 0,  //按月显示
    ContainerWeek    //按周显示
};

typedef NS_ENUM(NSUInteger, WDCalendarScope) {
    WDCalendarScopeMonth,
    WDCalendarScopeWeek
};

@class WDCalendarContainer;

@protocol WDCalendarContainerDelegate <NSObject>
@optional
//点击选择的日期
- (void)calendar:(WDCalendarView *)calendar didSelectedDate:(WDCalendarDateModel *)dateModel;
//日历高度改变回调
- (void)calendar:(WDCalendarView *)calendar showWithHeight:(float)height;
//月视图和周视图转变完成
- (void)calendarDidChangeToScope:(WDCalendarScope)scope;
@end

@interface WDCalendarContainer : UIView
@property (nonatomic, strong) WDCalendarDateModel *currentShowDateCalendar;
@property (nonatomic, weak) id<WDCalendarContainerDelegate> delegate;
- (void)convertToCalendarScope:(WDCalendarScope)scope;
- (void)reloadData;
@end

@interface FSCalendarTransitionAttributes : NSObject
@property (assign, nonatomic) float sourceY;
@property (assign, nonatomic) float targetY;
@property (assign, nonatomic) float sourceHeight;
@property (assign, nonatomic) float targetHeight;
@property (strong, nonatomic) NSDate *sourcePage;
@property (strong, nonatomic) NSDate *targetPage;
@property (assign, nonatomic) NSInteger focusedRowNumber;
@property (assign, nonatomic) NSDate *focusedDate;
@property (strong, nonatomic) NSDate *firstDayOfMonth;
@end
