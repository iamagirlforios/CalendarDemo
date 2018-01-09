//
//  ViewController.m
//  CalendarDemo
//
//  Created by 吴丹 on 2017/8/24.
//  Copyright © 2017年 吴丹. All rights reserved.
//

#import "ViewController.h"

#import "WDCalendarContainer.h"
#import "UIViewExt.h"

@interface ViewController () <WDCalendarContainerDelegate>
@property (nonatomic, strong) WDCalendarContainer *calendarContainer;
@end

@implementation ViewController

- (WDCalendarContainer *)calendarContainer
{
    if (!_calendarContainer) {
        _calendarContainer = [[WDCalendarContainer alloc] initWithFrame:CGRectMake(0, 64 + 30, self.view.width, 0)];
        _calendarContainer.delegate = self;
        _calendarContainer.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_calendarContainer];
    }
    return _calendarContainer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSDateComponents *componnents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    self.calendarContainer.currentShowDateCalendar = [[WDCalendarDateModel alloc] initWithYear:componnents.year
                                                                                         month:componnents.month
                                                                                           day:componnents.day];;
}

- (void)updateSubViewFrames{
    self.calendarContainer.top = 44 + 64;
}

#pragma YXTCalendarContainer delegate
- (void)calendar:(WDCalendarView *)calendar showWithHeight:(float)height{
    //日历高度改变时
}

- (void)calendar:(WDCalendarView *)calendar didSelectedDate:(WDCalendarDateModel *)dateModel
{
    self.title = [NSString stringWithFormat:@"%@  %@", [dateModel toStringWithSeparatStr:@"-"], [dateModel getWeekString]];
}

- (void)calendarDidChangeToScope:(WDCalendarScope)scope{
    //周视图和月视图改变之后
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
