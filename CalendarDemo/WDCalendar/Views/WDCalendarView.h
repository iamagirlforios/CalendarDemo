//
//  WDCalendarView.h
//  WDCalendar
//
//  Created by 吴丹 on 17/3/14.
//  Copyright © 2017年 吴丹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDCalendarDateModel.h"
#import "WDCalendarCell.h"

#define     Colume   7.0

struct WDCalendarCoordinate {
    NSInteger row;
    NSInteger column;
};

typedef struct WDCalendarCoordinate WDCalendarCoordinate;

@interface WDCalendarView : UIView
@property (nonatomic, assign) BOOL canMutableChoice;  //是否可多选
@property (nonatomic, assign) BOOL disVisibleChinese_calendar;  //不显示阴历
@property (nonatomic, assign) BOOL showToday;  //是否显示今天
@property (nonatomic, strong) UIColor *itemBorderColor;
@property (nonatomic, assign) float itemBorderWidth;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *visibleCells;
@property (nonatomic, strong) NSArray *calendarDayModelArray;
@property (nonatomic, copy) void (^didSelectDate)(WDCalendarView *calendar, WDCalendarDateModel *dateModel);
- (float)getCalendarViewHeightByItemCount:(NSInteger)count;
//通过indexPath得到是第几行第几列
- (WDCalendarCoordinate)coordinateForIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)getAllRowsCount;

+ (float)getRowHeight;
+ (float)getRowWidth;
@end
