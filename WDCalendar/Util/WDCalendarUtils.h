//
//  WDCalendarutils.h
//  WDCalendar
//
//  Created by 吴丹 on 17/3/14.
//  Copyright © 2017年 吴丹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDCalendarDateModel.h"

@interface WDCalendarUtils : NSObject
//通过月份得到这个月有几天
+ (NSInteger)getDaysByMonth:(NSInteger)month year:(NSInteger)year;
//得到该月的上一个月的天数
+ (NSInteger)getForwardMonthDaysByMonth:(NSInteger)curMonth curYear:(NSInteger)curYear;

//得到某日期的第一天是周几
+ (NSInteger)getFirstDayByMonth:(NSInteger)month year:(NSInteger)year;
+ (NSInteger)weekdayOfFirstDayInDate:(NSDate *)date;

+ (BOOL)isToday:(WDCalendarDateModel *)dateModel;

/*
 * @DO 获取指定日期的农历日期
 * @param date [指定日期]
 * @return (NSString)[指定日期的农历字符串]
 */
//+(NSString*)getChineseCalendarWithDate:(NSDate *)date;
+ (NSString *)chineseCalendarOfDate:(NSDate *)date;

//通过年月日得到date
+ (NSDate *)dateByYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

//得到一个月的所有需要显示的日期
//+ (NSArray *)getCalendarOnMonthDatesByDateModel:(WDCalendarDateModel *)dateModel;

@end
