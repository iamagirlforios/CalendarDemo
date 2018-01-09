//
//  WDCalendarDateModel.h
//  WDCalendar
//
//  Created by 吴丹 on 17/3/14.
//  Copyright © 2017年 吴丹. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CollectionViewCellDayType) {
    CellDayTypeNormal = 0,
//    CellDayTypeToday,    //今天
    CellDayTypeEmpty,   //不显示
//    CellDayTypePast,    //过去的日期
//    CellDayTypeFutur,   //将来的日期
    CellDayTypeWeek,    //周末
    CellDayTypeClick,    //被点击的日期
    CellDayTypeMutableClick,    //被多选点击的日期
    CellDayTypeHasOtherSechdule,    //某个日期有他们的日程
    CellDayTypeHasMySechdule,     //某个日期有我的日程
    CellDayTypeHasBothSechdule,     //某个我和他人的日程
};

@interface WDCalendarDateModel : NSObject

@property (assign, nonatomic) CollectionViewCellDayType style;//显示的样式

@property (nonatomic, assign) NSInteger day;//天
@property (nonatomic, assign) NSInteger month;//月
@property (nonatomic, assign) NSInteger year;//年
@property (nonatomic, assign) NSInteger week;//周

@property (nonatomic, strong) NSString *Chinese_calendar;//农历
@property (nonatomic, strong) NSString *holiday;//节日
@property (nonatomic, assign) BOOL isInvalid;  //无效

- (instancetype)initWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
//separtartStr年月日的分隔符
- (instancetype)initWithDateString:(NSString *)dateString separtartStr:(NSString *)separtartStr;
- (instancetype)initWithDate:(NSDate *)date;

//separtartStr：年月日中间的分隔符 如：@"-" 则返回格式为 2017-3-2。不传的话，默认返回格式为2017年3月2日
- (NSString *)toStringWithSeparatStr:(NSString *)separtartStr;
- (NSDate *)date;
- (NSString *)getWeekString;
- (NSString *)getWeekString1;
- (NSComparisonResult)compare:(WDCalendarDateModel *)cdate;

- (NSInteger)getForwardMonthDays;//得到上个月的天数

- (BOOL)isEqualToDateModel:(WDCalendarDateModel *)object;

- (WDCalendarDateModel *)getPastCalendarDateModel;  //得到上个月的日期
- (WDCalendarDateModel *)getNextCalendarDateModel;  //得到下个月的日期

@end
