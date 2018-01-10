//
//  WDCalendarView.m
//  WDCalendar
//
//  Created by 吴丹 on 17/3/14.
//  Copyright © 2017年 吴丹. All rights reserved.
//

#import "WDCalendarView.h"
#import "config.h"
#import "WDCalendarUtils.h"
#import "WDCalendarDateModel.h"

@interface WDCalendarView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) WDCalendarDateModel *clickDateModel;
@property (nonatomic, assign) CollectionViewCellDayType beforClickDateStyle;

@end

@implementation WDCalendarView

- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createHeaderWeekView];
        _showToday = YES;
    }
    return self;
}

- (void)setCalendarDayModelArray:(NSArray *)calendarDayModelArray
{
    _calendarDayModelArray = calendarDayModelArray;
    [self.collectionView reloadData];
    self.height = [self getCalendarViewHeightByItemCount:calendarDayModelArray.count];
    self.collectionView.height = self.height;
}

- (NSInteger)getAllRowsCount
{
    return self.calendarDayModelArray.count / 7;
}

- (UICollectionView *)collectionView
{
    if(!_collectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionLayout = layout;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[WDCalendarCell class] forCellWithReuseIdentifier:@"WDCalendarCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = YES;
        [self addSubview:_collectionView];
        [self sendSubviewToBack:_collectionView];
    }
    return _collectionView;
}

- (void)createHeaderWeekView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 30)];
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view];
    self.collectionView.top = view.bottom;
    
    NSArray *labelArray = @[@"一", @"二", @"三", @"四", @"五", @"六", @"日"];
    float width = [WDCalendarView getRowWidth];
    for (NSInteger i = 0; i < labelArray.count; i ++) {
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(i*width, 0, width, view.height)];
        lable.font = [UIFont systemFontOfSize:16];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.text = labelArray[i];
        [view addSubview:lable];
    }
}

- (NSArray *)visibleCells
{
    return [self.collectionView.visibleCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isKindOfClass:[WDCalendarCell class]];
    }]];
}

#pragma mark -- collection delegate and datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.calendarDayModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"WDCalendarCell";
    WDCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellid
                                                                     forIndexPath:indexPath];
    
    WDCalendarDateModel *model = self.calendarDayModelArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", model.day];
    
    if (self.itemBorderColor) {
        cell.layer.borderColor = self.itemBorderColor.CGColor;
    }
    cell.layer.borderWidth = self.itemBorderWidth;
    
    if (self.disVisibleChinese_calendar) cell.subLabel.text = @"";
    else cell.subLabel.text = model.Chinese_calendar;
    
    cell.isToday = self.showToday?[WDCalendarUtils isToday:model]:false;
    cell.isInvalid = model.isInvalid;
    cell.style = model.style;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([WDCalendarView getRowWidth], [WDCalendarView getRowHeight]);
}

//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);//分别为上、左、下、右
}

//两个cell之间的间距（同一行的cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0;
}

//这个是两行cell之间的间距（上下行cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WDCalendarDateModel *model = self.calendarDayModelArray[indexPath.row];
    if (self.canMutableChoice) {
        model.style = model.style!=CellDayTypeMutableClick?CellDayTypeMutableClick:CellDayTypeNormal;
    }else{
        //改变被点击的date的style和上次被点击的date的style
        if (self.clickDateModel)
            self.clickDateModel.style = self.beforClickDateStyle;
        self.beforClickDateStyle = model.style;
        model.style = CellDayTypeClick;
        self.clickDateModel = model;
    }
    if (self.didSelectDate) {
        self.didSelectDate (self, model);
    }
    [collectionView reloadData];
}

- (float)getCalendarViewHeightByItemCount:(NSInteger)count
{
    NSInteger row = ceil(count / Colume);
    return 30 + row * [WDCalendarView getRowHeight];
}

- (WDCalendarCoordinate)coordinateForIndexPath:(NSIndexPath *)indexPath
{
    WDCalendarCoordinate coordinate;
    coordinate.row = indexPath.item / 7;
    coordinate.column = indexPath.item % 7;
    return coordinate;
}

+ (float)getRowHeight{
    return [self getRowWidth] - 4;
}

+ (float)getRowWidth{
    return UI_SCREEN_WIDTH/7.05;
}

@end
