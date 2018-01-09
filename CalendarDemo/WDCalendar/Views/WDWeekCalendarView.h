//
//  WDWeekCalendarView.h
//  QiHua
//
//  Created by 吴丹 on 17/3/23.
//  Copyright © 2017年 pzdf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDCalendarDateModel.h"

@interface WDWeekCalendarView : UIView
@property (nonatomic, strong) NSArray *calendarDayModelArray;
@end

typedef NS_ENUM(NSInteger, WDWeekCaleaderScrollDirector) {
    WDWeekCaleaderScrollDirectorNone = 0,
    WDWeekCaleaderScrollDirectorLeft,    //向左滑动
    WDWeekCaleaderScrollDirectorRight  //向右滑动
};

@protocol WDWeekCalendarDelegate <NSObject>
- (void)weekCalendar:(WDWeekCalendarView *)weekCalendar scrollDirect:(WDWeekCaleaderScrollDirector)scrollDirect;
- (void)weekCalendar:(WDWeekCalendarView *)weekCalendar didSelectDate:(WDCalendarDateModel *)dateModel;
@end

@interface WDWeekCalendarContainer : UIView
@property (nonatomic, strong) UIScrollView *scrollerView;
@property (nonatomic, strong) NSArray <NSArray <WDCalendarDateModel *>*> *subViewDateArray;
@property (nonatomic, weak) id <WDWeekCalendarDelegate>delegate;
@end
