//
//  WDCalendarDateModel.m
//  WDCalendar
//
//  Created by 吴丹 on 17/3/14.
//  Copyright © 2017年 吴丹. All rights reserved.
//

#import "WDCalendarDateModel.h"
#import "WDCalendarUtils.h"

@implementation WDCalendarDateModel

- (instancetype)initWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    self = [super init];
    if (self) {
        _year = year;
        _month = month;
        day = day<=0?1:day;
        NSInteger allDays = [WDCalendarUtils getDaysByMonth:month year:year];  //一个月最多有多少天
        _day = allDays<day?allDays:day;
    }
    return self;
}

- (instancetype)initWithDateString:(NSString *)dateString separtartStr:(NSString *)separtartStr
{
    self = [super init];
    if (self) {
        NSArray *array = [dateString componentsSeparatedByString:separtartStr];
        _year = array.count==0?:[array[0] integerValue];
        _month = array.count==1?:[array[1] integerValue];
        _day = array.count==2?:[array[2] integerValue];
    }
    return self;
}

- (instancetype)initWithDate:(NSDate *)date
{
    self = [super init];
    if (self) {
        NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:unit fromDate:date];
        _year = components.year;
        _month = components.month;
        _day = components.day;
    }
    return self;
}

- (NSDate *)date
{
    return [WDCalendarUtils dateByYear:self.year month:self.month day:self.day];
}

- (NSString *)toStringWithSeparatStr:(NSString *)separtartStr
{
    if (separtartStr.length==0) {
        return [NSString stringWithFormat:@"%ld年%@%ld月%@%ld日",self.year, self.month>9?@"":@"0" ,self.month, self.day>9?@"":@"0",self.day];
    }
    return [NSString stringWithFormat:@"%ld%@%@%ld%@%@%ld",self.year, separtartStr, self.month>9?@"":@"0",self.month, separtartStr, self.day>9?@"":@"0",self.day];
}

- (NSInteger)getForwardMonthDays
{
    NSInteger month = self.month - 1;
    NSInteger year = self.year;
    if (month == 0) {
        month = 12;
        year = self.year - 1;
    }
    return [WDCalendarUtils getDaysByMonth:month year:year];
}

- (NSInteger)week
{
    NSUInteger firstDayOfMonthInt= [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:[self date]];
    //firstDayOfMonthInt得到的值为1：周日  2：周一  3：周二
    //0：周日  1：周一  2：周二 .......
    return firstDayOfMonthInt-1;
}

- (NSString *)getWeekString{
    switch (self.week) {
        case 0: return @"星期天";
        case 1: return @"星期一";
        case 2: return @"星期二";
        case 3: return @"星期三";
        case 4: return @"星期四";
        case 5: return @"星期五";
        case 6: return @"星期六";
        default: return @"";
    }
}

- (NSString *)getWeekString1
{
    switch (self.week) {
        case 0: return @"周日";
        case 1: return @"周一";
        case 2: return @"周二";
        case 3: return @"周三";
        case 4: return @"周四";
        case 5: return @"周五";
        case 6: return @"周六";
        default: return @"";
    }
}

- (NSComparisonResult)compare:(WDCalendarDateModel *)cdate
{
    if (cdate == nil) {
        return NSOrderedDescending;
    }
    return [self.date compare:cdate.date];
}



- (NSString *)Chinese_calendar
{
    if (!_Chinese_calendar) {
        _Chinese_calendar = [WDCalendarUtils chineseCalendarOfDate:[self date]];
    }
    return _Chinese_calendar;
}

- (BOOL)isEqualToDateModel:(WDCalendarDateModel *)object
{
    return (self.year==object.year  && self.month==object.month && self.day == object.day);
}

//得到上个月对应的日期
- (WDCalendarDateModel *)getPastCalendarDateModel{
    NSInteger month = self.month - 1;
    NSInteger year = self.year;
    if (month == 0) {
        month = 12;
        year --;
    }
    return [[WDCalendarDateModel alloc] initWithYear:year month:month day:self.day];
}

//得到下一个对应的日期
- (WDCalendarDateModel *)getNextCalendarDateModel{
    NSInteger month = self.month + 1;
    NSInteger year = self.year;
    if (month > 12) {
        month = 1;
        year ++;
    }
    return [[WDCalendarDateModel alloc] initWithYear:year month:month day:self.day];
}
@end
