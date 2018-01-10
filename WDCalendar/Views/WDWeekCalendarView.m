//
//  WDWeekCalendarView.m
//  QiHua
//
//  Created by 吴丹 on 17/3/23.
//  Copyright © 2017年 pzdf. All rights reserved.
//

#import "WDWeekCalendarView.h"
#import "WDCalendarCell.h"
#import "WDCalendarView.h"
#import "WDCalendarUtils.h"
#import "config.h"

@interface WDWeekCalendarView() <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *weekCollectionView;
@property (nonatomic, strong) WDCalendarDateModel *clickDateModel;
@property (nonatomic, assign) CollectionViewCellDayType beforClickDateStyle;
@property (nonatomic, copy) void (^didSelectDate)(WDWeekCalendarView *calendar, WDCalendarDateModel *dateModel);
@end

@implementation WDWeekCalendarView
- (UICollectionView *)weekCollectionView
{
    if(!_weekCollectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _weekCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) collectionViewLayout:layout];
        _weekCollectionView.backgroundColor = [UIColor clearColor];
        [_weekCollectionView registerClass:[WDCalendarCell class] forCellWithReuseIdentifier:@"WDCalendarCell"];
        _weekCollectionView.delegate = self;
        _weekCollectionView.dataSource = self;
        _weekCollectionView.scrollEnabled = YES;
        [self addSubview:_weekCollectionView];
    }
    return _weekCollectionView;
}

- (void)setCalendarDayModelArray:(NSArray *)calendarDayModelArray
{
    _calendarDayModelArray = calendarDayModelArray;
    [self.weekCollectionView reloadData];
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
    cell.subLabel.text = model.Chinese_calendar;
    cell.isToday = [WDCalendarUtils isToday:model];
    cell.isInvalid = false;
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
    //点击了同一个日期，不做操作
    if (self.clickDateModel && [self.clickDateModel isEqualToDateModel:model]) {
        return;
    }
//    改变被点击的date的style和上次被点击的date的style
    if (self.clickDateModel) {
        self.clickDateModel.style = self.beforClickDateStyle;
    }

    self.beforClickDateStyle = model.style;
    model.style = CellDayTypeClick;
    [collectionView reloadData];
    self.clickDateModel = model;
    
    if (self.didSelectDate) {
        self.didSelectDate (self, model);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self weekCollectionView];
}

@end

@interface WDWeekCalendarContainer() <UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray<WDWeekCalendarView *> *subCalendarViews;
@property (nonatomic, assign) NSInteger currentPage;
@end

@implementation WDWeekCalendarContainer

- (NSMutableArray<WDWeekCalendarView *> *)subCalendarViews
{
    if (!_subCalendarViews) {
        _subCalendarViews = [NSMutableArray array];
        for (int i = 0; i < 3; i ++) {
            WDWeekCalendarView *calendarView = [[WDWeekCalendarView alloc] initWithFrame:CGRectMake(i*self.scrollerView.width,
                                                                                            0,
                                                                                            self.scrollerView.width,
                                                                                            self.scrollerView.height)];
            __weak typeof(self) weakSelf = self;
            [calendarView setDidSelectDate:^(WDWeekCalendarView *calendar, WDCalendarDateModel *dateModel) {
                __strong typeof(self) strongSelf = weakSelf;
                if([strongSelf.delegate respondsToSelector:@selector(weekCalendar:didSelectDate:)]){
                    [strongSelf.delegate weekCalendar:calendar didSelectDate:dateModel];
                }
            }];
            [self.scrollerView addSubview:calendarView];
            [_subCalendarViews addObject:calendarView];
        }
    }
    return _subCalendarViews;
}

- (UIScrollView *)scrollerView
{
    if (!_scrollerView) {
        _scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _scrollerView.contentSize = CGSizeMake(_scrollerView.width * 3, self.height);
        _scrollerView.scrollEnabled = YES;
        _scrollerView.pagingEnabled = YES;
        _scrollerView.showsHorizontalScrollIndicator = false;
        _scrollerView.showsVerticalScrollIndicator = false;
        _scrollerView.delegate = self;
        _scrollerView.directionalLockEnabled = YES;
        _scrollerView.alwaysBounceHorizontal = YES;
        _scrollerView.alwaysBounceVertical = NO;
        [self addSubview:_scrollerView];
    }
    return _scrollerView;
}

- (WDWeekCalendarView *)currentWeekCalendarView{
    return self.subCalendarViews[1];
}

- (void)setSubViewDateArray:(NSArray<NSArray<WDCalendarDateModel *> *> *)subViewDateArray
{
    _subViewDateArray = subViewDateArray;
    [self updateUI];
}

- (void)updateUI{
    if (_subViewDateArray.count != self.subCalendarViews.count) {
        return;
    }
    for (int i = 0; i < _subViewDateArray.count; i ++) {
        WDWeekCalendarView *weekCalendar = self.subCalendarViews[i];
        weekCalendar.calendarDayModelArray = _subViewDateArray[i];
    }
    self.scrollerView.contentOffset = CGPointMake(self.scrollerView.width, 0);
    self.currentPage = 1;
}

#pragma mark scrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat fractionalPage = scrollView.contentOffset.x / scrollView.width;
    int currentPage = roundf(fractionalPage); //返回x的四舍五入整数值。
    if(self.currentPage == currentPage){
        return;
    }
    WDWeekCaleaderScrollDirector director = WDWeekCaleaderScrollDirectorNone;
    if (currentPage == 0) {  //向左滑了
        director = WDWeekCaleaderScrollDirectorLeft;
    }else if(currentPage == 2){  //向右滑了
        director = WDWeekCaleaderScrollDirectorRight;
    }
    if ([self.delegate respondsToSelector:@selector(weekCalendar:scrollDirect:)]) {
        [self.delegate weekCalendar:self.currentWeekCalendarView scrollDirect:director];
    }
}

@end
