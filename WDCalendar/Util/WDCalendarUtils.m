//
//  WDCalendarutils.m
//  WDCalendar
//
//  Created by 吴丹 on 17/3/14.
//  Copyright © 2017年 吴丹. All rights reserved.
//

#import "WDCalendarUtils.h"

#define ChineseMonths @[@"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",@"九月", @"十月", @"冬月", @"腊月"]
#define ChineseFestival @[@"正月",@"春节",@"中秋",@"劳动节",@"国庆",@"儿童",@"圣诞",@"七夕",@"端午",@"元宵",@"重阳",@"腊八", @"中元", @"元旦", @"妇女节", @"植树节", @"消费者权益日", @"愚人节", @"地球日", @"青年节", @"儿童节", @"环境日", @"建党节", @"建军节", @"教师节", @"国庆"]
#define ChineseDays @[@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",@"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十", @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十"]
#define ChineseWeatherFestival @[@"立春",@"雨水",@"惊蛰",@"春分",@"清明",@"谷雨",@"立夏",@"小满",@"忙种",@"夏至",@"小暑",@"大暑",@"立秋",@"处暑",@"寒露",@"霜降",@"白露",@"秋分",@"立冬",@"小雪",@"大雪",@"冬至",@"小寒",@"大寒"]

@implementation WDCalendarUtils
+ (NSInteger)getDaysByMonth:(NSInteger)month year:(NSInteger)year
{
    switch (month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:   return 31;
        case 4:
        case 6:
        case 9:
        case 11:   return 30;
        case 2:    return [WDCalendarUtils isLeapYear:year]?29:28;
        default: return 0;
    }
}

+ (NSInteger)getForwardMonthDaysByMonth:(NSInteger)curMonth curYear:(NSInteger)curYear{
    NSInteger month = curMonth - 1;
    NSInteger year = curYear;
    if (month == 0) {
        month = 12;
        year = curYear - 1;
    }
    return [WDCalendarUtils getDaysByMonth:month year:year];
}

//是否是闰年 是闰年 2月有29天 否则为28天
//1、普通年能被4整除且不能被100整除的为闰年
//2、世纪年能被400整除的是闰年
+ (BOOL)isLeapYear:(NSInteger)year{
    if (year % 400 == 0) {
        return true;
    }
    if (year % 100 != 0 && year % 4 == 0) {
        return true;
    }
    return false;
}

//得到某日期的第一天是周几
+ (NSInteger)getFirstDayByMonth:(NSInteger)month year:(NSInteger)year{
    NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-1", year, month];
    NSDateFormatter *formmate = [[NSDateFormatter alloc] init];
    [formmate setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formmate dateFromString:dateStr];
    NSUInteger firstDayOfMonthInt= [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:date];
    //firstDayOfMonthInt得到的值为1：周日  2：周一  3：周二
    return firstDayOfMonthInt-1;
}

// 自动获取date当前月的第一天是星期几
+ (NSInteger)weekdayOfFirstDayInDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear |NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    [components setDay:1];
    NSDate *firstDate = [calendar dateFromComponents:components];
    NSDateComponents *firstComponents = [calendar components:NSCalendarUnitWeekday fromDate:firstDate];
    return firstComponents.weekday - 1;
}

+ (NSDate *)dateByYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = year;
    components.month = month;
    components.day = day;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

+ (BOOL)isToday:(WDCalendarDateModel *)dateModel{
    NSDateComponents *componts = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    return componts.year==dateModel.year&&componts.month==dateModel.month&&componts.day==dateModel.day;
}

#pragma mark - 显示节日节气信息
// 获取date当天的农历
+ (NSString *)chineseCalendarOfDate:(NSDate *)date {
    
    NSCalendar *chineseCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
    NSDateComponents *components = [chineseCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    //NSString *dayDate;
    NSCalendar *normalDate = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *Datecomponents = [normalDate components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    NSString *_day = @"";
    
    if (components.day ==1 ) {
        _day = ChineseMonths[components.month - 1];
        
    } else {
        
        _day = ChineseDays[components.day - 1];
    }
    //农历节日
    
    if (components.day == 1 && components.month ==1) {
        _day = @"春节";
    } if(components.month ==8 && components.day == 15){
        _day = @"中秋";
    }else if(components.month == 7 && components.day == 7){
        _day = @"七夕";
    }else if(components.month == 5 && components.day == 5){
        _day = @"端午";
    }else if (components.month == 1 && components.day == 15){
        _day = @"元宵";
    }else if (components.month == 7 && components.day == 15){
        _day = @"中元";
    }else if (components.month == 9 && components.day == 9){
        _day = @"重阳";
    }else if (components.month == 12 && components.day == 8){
        _day = @"腊八";
    }

    if (Datecomponents.month == 1 && Datecomponents.day ==1) {  //元旦
        _day = @"元旦";
    }else if(Datecomponents.month == 3 && Datecomponents.day == 8){ //妇女节
        _day = @"妇女节";
    }else if(Datecomponents.month == 3 && Datecomponents.day == 12){ //植树节
        _day = @"植树节";
    }else if(Datecomponents.month == 3 && Datecomponents.day == 15){ //消费者权益日
        _day = @"消费者权益日";
    }else if(Datecomponents.month == 4 && Datecomponents.day == 1){ //愚人节
        _day = @"愚人节";
    }else if(Datecomponents.month == 4 && Datecomponents.day == 22){ //地球日
        _day = @"地球日";
    }else if(Datecomponents.month == 5 && Datecomponents.day == 1){ //劳动节
        _day = @"劳动节";
    }else if(Datecomponents.month == 5 && Datecomponents.day == 4){ //青年节
        _day = @"青年节";
    }else if(Datecomponents.month == 6 && Datecomponents.day == 1){ //儿童节
        _day = @"儿童节";
    }else if(Datecomponents.month == 6 && Datecomponents.day == 5){ //环境日
        _day = @"环境日";
    }else if(Datecomponents.month == 7 && Datecomponents.day == 1){ //建党节
        _day = @"建党节";
    }else if(Datecomponents.month == 8 && Datecomponents.day == 1){ //建军节
        _day = @"建军节";
    }else if(Datecomponents.month == 9 && Datecomponents.day == 10){ //教师节
        _day = @"教师节";
    }else if(Datecomponents.month == 10 && Datecomponents.day == 1){ //国庆
        _day = @"国庆";
    }else if(Datecomponents.month == 12 && Datecomponents.day == 25){ //圣诞节
        _day = @"圣诞";
    }
    
    NSString *day = [WDCalendarUtils getLunarSpecialDate:Datecomponents.year Month:Datecomponents.month Day:Datecomponents.day];
    if (day.length > 0) {
        _day = day;
    }
    //除夕另外提出放在所有节日的末尾执行，除夕是在春节前一天，即把components当天时间前移一天，放在所有节日末尾，避免其他节日全部前移一天
    NSTimeInterval timeInterval_day = 60 *60 * 24;
    NSDate *nextDay_date = [NSDate dateWithTimeInterval:timeInterval_day sinceDate:date];
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay;
    components = [localeCalendar components:unitFlags fromDate:nextDay_date];
    if ( 1 == components.month && 1 == components.day ) {
        return @"除夕";
    }
    return _day;
}

//24节气只有(1901 - 2050)之间为准确的节气
const  int START_YEAR =1901;
const  int END_YEAR   =2050;

static int32_t gLunarHolDay[]=
{
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1901
    0X96,0XA4, 0X96,0X96, 0X97,0X87, 0X79,0X79, 0X79,0X69, 0X78,0X78,   //1902
    0X96,0XA5, 0X87,0X96, 0X87,0X87, 0X79,0X69, 0X69,0X69, 0X78,0X78,   //1903
    0X86,0XA5, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X78,0X87,   //1904
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1905
    0X96,0XA4, 0X96,0X96, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,   //1906
    0X96,0XA5, 0X87,0X96, 0X87,0X87, 0X79,0X69, 0X69,0X69, 0X78,0X78,   //1907
    0X86,0XA5, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //1908
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1909
    0X96,0XA4, 0X96,0X96, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,   //1910
    0X96,0XA5, 0X87,0X96, 0X87,0X87, 0X79,0X69, 0X69,0X69, 0X78,0X78,   //1911
    0X86,0XA5, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //1912
    0X95,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1913
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,   //1914
    0X96,0XA5, 0X97,0X96, 0X97,0X87, 0X79,0X79, 0X69,0X69, 0X78,0X78,   //1915
    0X96,0XA5, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,   //1916
    0X95,0XB4, 0X96,0XA6, 0X96,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X87,   //1917
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X77,   //1918
    0X96,0XA5, 0X97,0X96, 0X97,0X87, 0X79,0X79, 0X69,0X69, 0X78,0X78,   //1919
    0X96,0XA5, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,   //1920
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X87,   //1921
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X77,   //1922
    0X96,0XA4, 0X96,0X96, 0X97,0X87, 0X79,0X79, 0X69,0X69, 0X78,0X78,   //1923
    0X96,0XA5, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,   //1924
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X87,   //1925
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1926
    0X96,0XA4, 0X96,0X96, 0X97,0X87, 0X79,0X79, 0X79,0X69, 0X78,0X78,   //1927
    0X96,0XA5, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //1928
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,   //1929
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1930
    0X96,0XA4, 0X96,0X96, 0X97,0X87, 0X79,0X79, 0X79,0X69, 0X78,0X78,   //1931
    0X96,0XA5, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //1932
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //1933
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1934
    0X96,0XA4, 0X96,0X96, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,   //1935
    0X96,0XA5, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //1936
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //1937
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1938
    0X96,0XA4, 0X96,0X96, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,   //1939
    0X96,0XA5, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //1940
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //1941
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1942
    0X96,0XA4, 0X96,0X96, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,   //1943
    0X96,0XA5, 0X96,0XA5, 0XA6,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //1944
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,   //1945
    0X95,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X77,   //1946
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,   //1947
    0X96,0XA5, 0XA6,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,   //1948
    0XA5,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X79, 0X78,0X79, 0X77,0X87,   //1949
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X77,   //1950
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,   //1951
    0X96,0XA5, 0XA6,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,   //1952
    0XA5,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,   //1953
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X78,0X79, 0X78,0X68, 0X78,0X87,   //1954
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1955
    0X96,0XA5, 0XA5,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,   //1956
    0XA5,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,   //1957
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //1958
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1959
    0X96,0XA4, 0XA5,0XA5, 0XA6,0X96, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //1960
    0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //1961
    0X96,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //1962
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1963
    0X96,0XA4, 0XA5,0XA5, 0XA6,0X96, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //1964
    0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //1965
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //1966
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1967
    0X96,0XA4, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //1968
    0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //1969
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //1970
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,   //1971
    0X96,0XA4, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //1972
    0XA5,0XB5, 0X96,0XA5, 0XA6,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //1973
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //1974
    0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X77,   //1975
    0X96,0XA4, 0XA5,0XB5, 0XA6,0XA6, 0X88,0X89, 0X88,0X78, 0X87,0X87,   //1976
    0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,   //1977
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X78,0X87,   //1978
    0X96,0XB4, 0X96,0XA6, 0X96,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X77,   //1979
    0X96,0XA4, 0XA5,0XB5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //1980
    0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X77,0X87,   //1981
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,   //1982
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X77,   //1983
    0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X87,   //1984
    0XA5,0XB4, 0XA6,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,   //1985
    0XA5,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,   //1986
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X79, 0X78,0X69, 0X78,0X87,   //1987
    0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,   //1988
    0XA5,0XB4, 0XA5,0XA5, 0XA6,0X96, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //1989
    0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X79, 0X77,0X87,   //1990
    0X95,0XB4, 0X96,0XA5, 0X86,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //1991
    0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,   //1992
    0XA5,0XB3, 0XA5,0XA5, 0XA6,0X96, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //1993
    0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //1994
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X76, 0X78,0X69, 0X78,0X87,   //1995
    0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,   //1996
    0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //1997
    0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //1998
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //1999
    0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,   //2000
    0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //2001
    0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //2002
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //2003
    0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,   //2004
    0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //2005
    0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,   //2006
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,   //2007
    0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X87,0X78, 0X87,0X86,   //2008
    0XA5,0XB3, 0XA5,0XB5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //2009
    0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,   //2010
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X78,0X87,   //2011
    0X96,0XB4, 0XA5,0XB5, 0XA5,0XA6, 0X87,0X88, 0X87,0X78, 0X87,0X86,   //2012
    0XA5,0XB3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X87,   //2013
    0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,   //2014
    0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,   //2015
    0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X87,0X88, 0X87,0X78, 0X87,0X86,   //2016
    0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X87,   //2017
    0XA5,0XB4, 0XA6,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,   //2018
    0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X79, 0X77,0X87,   //2019
    0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X86,   //2020
    0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,   //2021
    0XA5,0XB4, 0XA5,0XA5, 0XA6,0X96, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //2022
    0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X79, 0X77,0X87,   //2023
    0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X96,   //2024
    0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,   //2025
    0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //2026
    0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //2027
    0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X96,   //2028
    0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,   //2029
    0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //2030
    0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,   //2031
    0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X96,   //2032
    0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X86,   //2033
    0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X78, 0X88,0X78, 0X87,0X87,   //2034
    0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,   //2035
    0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X96,   //2036
    0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,   //2037
    0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //2038
    0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,   //2039
    0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X96,   //2040
    0XA5,0XC3, 0XA5,0XB5, 0XA5,0XA6, 0X87,0X88, 0X87,0X78, 0X87,0X86,   //2041
    0XA5,0XB3, 0XA5,0XB5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,   //2042
    0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,   //2043
    0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X88, 0X87,0X96,   //2044
    0XA5,0XC3, 0XA5,0XB4, 0XA5,0XA6, 0X87,0X88, 0X87,0X78, 0X87,0X86,   //2045
    0XA5,0XB3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X87,   //2046
    0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,   //2047
    0X95,0XB4, 0XA5,0XB4, 0XA5,0XA5, 0X97,0X87, 0X87,0X88, 0X86,0X96,   //2048
    0XA4,0XC3, 0XA5,0XA5, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X86,   //2049
    0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X78,0X78, 0X87,0X87    //2050
    
};

+(NSString *)getLunarSpecialDate:(NSInteger)iYear Month:(NSInteger)iMonth Day:(NSInteger)iDay  {
    
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"小寒",@"大寒",@"立春",@"雨水",@"惊蛰",@"春分",
                          @"清明",@"谷雨",@"立夏",@"小满",@"芒种",@"夏至",
                          @"小暑",@"大暑",@"立秋",@"处暑",@"白露",@"秋分",
                          @"寒露",@"霜降",@"立冬",@"小雪",@"大雪",@"冬至",nil];
    
    NSString *_day = @"";
    long array_index = (iYear -START_YEAR)*12+iMonth -1 ;
    
    
    int64_t flag =gLunarHolDay[array_index];
    int64_t day;
    
    if(iDay <15)
        day= 15 - ((flag>>4)&0x0f);
    else
        day = ((flag)&0x0f)+15;
    
    long index = -1;
    
    if(iDay == day){
        index = (iMonth-1) *2 + (iDay>15?1: 0);
    }
    
    if ( index >=0  && index < [chineseDays count] ) {
        [chineseDays objectAtIndex:index];
        _day = chineseDays[index];
    }
    return _day;
}

@end
