//
//  YXTCalendarContainer.m
//  QiHua
//
//  Created by 吴丹 on 17/3/22.
//  Copyright © 2017年 pzdf. All rights reserved.
//

#import "WDCalendarContainer.h"
#import "WDCalendarUtils.h"
#import "WDWeekCalendarView.h"
#import "config.h"


typedef NS_ENUM(NSUInteger, WDCalendarTransitionState) {
    WDCalendarTransitionStateIdle,
    WDCalendarTransitionStateChanging,
    WDCalendarTransitionStateFinishing,
};

typedef NS_ENUM(NSUInteger, WDCalendarTransition) {
    WDCalendarTransitionNone,
    WDCalendarTransitionMonthToWeek,
    WDCalendarTransitionWeekToMonth
};

@interface WDCalendarContainer() <UIScrollViewDelegate, WDWeekCalendarDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<WDCalendarView *> *subCalendarViews;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) WDCalendarTransitionState transitionState;  //动画的状态
@property (nonatomic, assign) WDCalendarTransition transition;   //动画的方式，月到周  周到月
@property (nonatomic, strong) WDWeekCalendarContainer *weekCalendar;
@property (nonatomic, strong) FSCalendarTransitionAttributes *attributes;
@property (nonatomic, assign) NSInteger focusedRowNumber;  //被点中锁定的行
@property (nonatomic, assign) WDCalendarScope scope;

@end

@implementation WDCalendarContainer

- (void)reloadData{
    if (_currentShowDateCalendar == nil) {
        return;
    }
    self.focusedRowNumber = [self getRowByDateModel:_currentShowDateCalendar];  //得到当前选中时间在月日历中的第几行
    [self updateUI];   //更新界面
    if (self.scope == WDCalendarScopeWeek) {  //如果当前显示的是周视图，给周视图设置数据
        [self setWeekCalendarData];
    }
    [self.delegate calendar:self.subCalendarViews[1]
            didSelectedDate:_currentShowDateCalendar];
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0)];
        _scrollView.scrollEnabled = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.delegate = self;
        _scrollView.directionalLockEnabled = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.alwaysBounceVertical = NO;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (NSMutableArray<WDCalendarView *> *)subCalendarViews
{
    if (!_subCalendarViews) {
        _subCalendarViews = [NSMutableArray array];
        for (int i = 0; i < 3; i ++) {
            //装配需要显示的日历，左中右各一个
            WDCalendarView *calendarView = [[WDCalendarView alloc] initWithFrame:CGRectMake(i*self.scrollView.width,
                                                                                            0,
                                                                                            self.scrollView.width,
                                                                                            self.scrollView.height)];
            __weak typeof(self) weakSelf = self;
            //日历中的日期点击回调
            [calendarView setDidSelectDate:^(WDCalendarView *calendar, WDCalendarDateModel *dateModel) {
                if([weakSelf.delegate respondsToSelector:@selector(calendar:didSelectedDate:)]){
                    weakSelf.currentShowDateCalendar = dateModel;
                }
            }];
            [self.scrollView addSubview:calendarView];
            [_subCalendarViews addObject:calendarView];
        }
    }
    return _subCalendarViews;
}
//周日历视图
- (WDWeekCalendarContainer *)weekCalendar
{
    if (!_weekCalendar) {
        _weekCalendar = [[WDWeekCalendarContainer alloc] initWithFrame:CGRectMake(0, 30, self.width, [WDCalendarView getRowHeight])];
        _weekCalendar.backgroundColor = [UIColor whiteColor];
        _weekCalendar.delegate = self;
        [self addSubview:_weekCalendar];
    }
    return _weekCalendar;
}
//拖拽手势（通过拖拽将月视图和周视图互换）
- (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [self addGestureRecognizer:_panGestureRecognizer];
    }
    return _panGestureRecognizer;
}

#pragma mark -- WDWeekCalendarContainer delegate
//周视图滑动后回调
- (void)weekCalendar:(WDWeekCalendarView *)weekCalendar scrollDirect:(WDWeekCaleaderScrollDirector)scrollDirect
{
    NSArray *array;
    switch (scrollDirect) {
        case WDWeekCaleaderScrollDirectorLeft:{  //向左滑动
            array = [self getLeftWeekArray];
        }
            break;
        case WDWeekCaleaderScrollDirectorRight:{   //向右滑动
            array = [self getRightWeekArray];
        }
            break;
        default:
            return;
    }
    WDCalendarDateModel *selectedModel = array[self.currentShowDateCalendar.week];
    WDCalendarDateModel *newModel = [[WDCalendarDateModel alloc] initWithYear:selectedModel.year month:selectedModel.month day:selectedModel.day];
    self.currentShowDateCalendar = newModel;
    self.focusedRowNumber = [self getRowByDateModel:newModel];
    [self setWeekCalendarData];
}
//周视图选择日期周回调
- (void)weekCalendar:(WDWeekCalendarView *)weekCalendar didSelectDate:(WDCalendarDateModel *)dateModel
{
    self.currentShowDateCalendar = dateModel;
    [self convertToCalendarScope:WDCalendarScopeWeek];
}
//通过月视图得到左边周数据所需数组
- (NSArray *)getLeftWeekArray{
    WDCalendarView *calendar = self.subCalendarViews[1];
    NSInteger row = self.focusedRowNumber - 1;  //向左滑就相当于在当前月视图下，当前选中的row减一
    if (self.focusedRowNumber == 0) { //若当前选中的行刚好是第0行，row就是前一个月视图的最后一行
        WDCalendarDateModel *model = calendar.calendarDayModelArray[0]; //当前视图下的第一天日期
        NSInteger firstWeek = model.week;  //若这个月的第一天刚好是周日(顶格，上个月的日历中没有出现这个月的无效日期)，row就是上一个月的月视图的行数-1，否则-2()
        calendar = self.subCalendarViews[0];
        row = [calendar getAllRowsCount] - ((firstWeek==0&&model.day==1)?1:2);
    }
    NSArray *array = [calendar.calendarDayModelArray subarrayWithRange:NSMakeRange(Colume*row, Colume)];
    return array;
}

//通过月视图得到右边周数据所需数组
- (NSArray *)getRightWeekArray{
    WDCalendarView *calendar = self.subCalendarViews[1];
    NSInteger row = self.focusedRowNumber + 1;
    if (self.focusedRowNumber == [calendar getAllRowsCount] - 1) {
        calendar = self.subCalendarViews[2];
        WDCalendarDateModel *model = calendar.calendarDayModelArray[0]; //下个月的第一天日期
        NSInteger firstWeek = model.week; //下个月第一天刚好是日历的左边第一个日期
        row = (firstWeek==0&&model.day==1)?0:1;
    }
    NSArray *array = [calendar.calendarDayModelArray subarrayWithRange:NSMakeRange(Colume*row, Colume)];
    return array;
}

//设置周视图数据
- (void)setWeekCalendarData{
    WDCalendarView *calendar = self.subCalendarViews[1];
    NSArray *centerArray = [calendar.calendarDayModelArray subarrayWithRange:NSMakeRange(Colume*self.focusedRowNumber, Colume)];
    NSArray *leftArray = [self getLeftWeekArray];
    NSArray *rightArray = [self getRightWeekArray];
    self.weekCalendar.subViewDateArray = @[leftArray, centerArray, rightArray];
}

//通过月和年得到这个月的显示的数组
- (NSArray *)getModelArrayByDateModel:(WDCalendarDateModel *)dateModel{
    NSInteger monthAllDays = [WDCalendarUtils getDaysByMonth:dateModel.month year:dateModel.year]; //这个月的天数
    NSInteger forwardMonthAllDays = [dateModel getForwardMonthDays]; //上个月的天数
    NSInteger firstDay = [WDCalendarUtils weekdayOfFirstDayInDate:dateModel.date]; //这个月的第一天
    NSInteger row = ceil((monthAllDays + firstDay) / Colume);
    NSMutableArray *modelArray = [NSMutableArray array];
    for (int i = 0; i < row * 7; i ++) {
        WDCalendarDateModel *model1;
        if (i < firstDay) {   //显示上个月的日期
            NSInteger forwardmonth = dateModel.month - 1;
            NSInteger forwardyear = dateModel.year;
            if (forwardmonth == 0) {
                forwardmonth = 12;
                forwardyear = forwardyear - 1;
            }
            model1 = [[WDCalendarDateModel alloc] initWithYear:forwardyear
                                                         month:forwardmonth
                                                           day:forwardMonthAllDays - (firstDay - i - 1)];
            model1.isInvalid = YES;
        }else if (i >= monthAllDays + firstDay){  //显示下个月的日期
            NSInteger nextmonth = dateModel.month + 1;
            NSInteger nextyear = dateModel.year;
            if (nextmonth > 12) {
                nextmonth = 1;
                nextyear ++;
            }
            model1 = [[WDCalendarDateModel alloc] initWithYear:nextyear
                                                         month:nextmonth
                                                           day:i - (monthAllDays + firstDay) + 1];
            model1.isInvalid = YES;
        }else{  //当前月的日期
            model1 = [[WDCalendarDateModel alloc] initWithYear:dateModel.year
                                                         month:dateModel.month
                                                           day:i - firstDay + 1];
            model1.style = CellDayTypeNormal;
            model1.isInvalid = false;
        }
        if ([model1 isEqualToDateModel:self.currentShowDateCalendar]) model1.style = CellDayTypeClick;
        [modelArray addObject:model1];
    }
    return modelArray;
}

#pragma mark scrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat fractionalPage = scrollView.contentOffset.x / scrollView.width;
    int currentPage = roundf(fractionalPage); //返回x的四舍五入整数值。
    if(self.currentIndex == currentPage){
        return;
    }
    if (currentPage == 0) {  //向左滑了
        self.currentShowDateCalendar = [_currentShowDateCalendar getPastCalendarDateModel];
    }else if(currentPage == 2){  //向右滑了
        self.currentShowDateCalendar = [_currentShowDateCalendar getNextCalendarDateModel];
    }
}

//左右滑动之后 ，更新界面
- (void)updateUI{
    WDCalendarDateModel *pastDate = [_currentShowDateCalendar getPastCalendarDateModel];
    WDCalendarDateModel *nextDate = [_currentShowDateCalendar getNextCalendarDateModel];
    NSArray *modeArray = @[pastDate, _currentShowDateCalendar, nextDate];
    for (int i = 0; i < self.subCalendarViews.count; i ++) {
        WDCalendarView *calendar = self.subCalendarViews[i];
        WDCalendarDateModel *model = modeArray[i];
        calendar.calendarDayModelArray = [self getModelArrayByDateModel:model];
    }
    
    WDCalendarView *calendar = self.subCalendarViews[1];
    
    //设置大小
    self.scrollView.contentOffset = CGPointMake(self.scrollView.width, 0);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width*3, calendar.height);
    if (self.scope == WDCalendarScopeMonth) {
        [self _updateSelfToHeight:calendar.height];
    }
    
    CGFloat fractionalPage = self.scrollView.contentOffset.x / self.scrollView.width;
    int currentPage = roundf(fractionalPage); //返回x的四舍五入整数值。
    self.currentIndex = currentPage;
}

- (void)setCurrentShowDateCalendar:(WDCalendarDateModel *)currentShowDateCalendar
{
    if ([_currentShowDateCalendar isEqualToDateModel:currentShowDateCalendar]) {
        return;
    }
    _currentShowDateCalendar = currentShowDateCalendar;
    [self reloadData];
}

//通过某一个日期，得到这个日期在日历中的第几行
- (NSInteger)getRowByDateModel:(WDCalendarDateModel *)model{
    NSInteger firstDay = [WDCalendarUtils weekdayOfFirstDayInDate:model.date];
    NSInteger row = ceil((firstDay + model.day - 1) / 7);
    return row;
}

#pragma mark -- gestureRecognizer action
- (void)panGestureAction:(UIPanGestureRecognizer *)recognizer{
    //获取手指拖拽的时候,平移的值
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self scopeTransitionDidBegin:recognizer];
            break;
        case UIGestureRecognizerStateChanged:
            [self scopeTransitionDidUpdate:recognizer];
            break;
        case UIGestureRecognizerStateEnded:
            [self scopeTransitionDidEnd:recognizer];
            break;
        case UIGestureRecognizerStateCancelled:
            [self scopeTransitionDidEnd:recognizer];
            break;
        case UIGestureRecognizerStateFailed:
            [self scopeTransitionDidEnd:recognizer];
            break;
        default:
            break;
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view];
        BOOL shouldStart = self.scope == WDCalendarScopeWeek ? velocity.y >= 0 : velocity.y <= 0;
        if (!shouldStart) return NO;
        shouldStart = (ABS(velocity.x)<=ABS(velocity.y));
        return shouldStart;
    }
    return YES;
}

- (void)scopeTransitionDidBegin:(UIPanGestureRecognizer *)panGesture
{
    //velocity向下滑动 大于0   向上滑动 小于0
    CGPoint velocity = [panGesture velocityInView:panGesture.view];
    switch (self.scope) {
        case WDCalendarScopeMonth:  //日历当前是月视图，若下滑不起作用，上滑转为周视图
            if (velocity.y < 0) {
                self.transitionState = WDCalendarTransitionStateChanging;
                self.transition = WDCalendarTransitionMonthToWeek;
            }
            break;
        case WDCalendarScopeWeek:   //日历当前是周视图，若上滑滑不起作用，上滑转为月视图
            if (velocity.y > 0) {
                self.transitionState = WDCalendarTransitionStateChanging;
                self.transition = WDCalendarTransitionWeekToMonth;
            }
        default:
            break;
    }
    [self setTransitionBeginValue];
}

- (void)setTransitionBeginValue{
    if (self.transitionState != WDCalendarTransitionStateChanging) return;
    //从月视图转周视图，赋初值
    if (self.transition == WDCalendarTransitionMonthToWeek) {
        [self setWeekCalendarData];
        self.attributes.sourceY = [self getModelMonthY:self.currentShowDateCalendar];
        self.attributes.targetY = [self getModelWeekY];
        self.attributes.targetHeight = [self minHeight];
        self.attributes.sourceHeight = [self maxHeight];
    }
    //从周视图转月视图，赋初值
    else if (self.transition == WDCalendarTransitionWeekToMonth)
    {
        self.attributes.sourceY = [self getModelWeekY];
        //当前点中的时间换到月日历应该是第几行
        self.attributes.targetY = [self getModelMonthY:self.currentShowDateCalendar];;
        self.attributes.sourceHeight = [self minHeight];
        self.attributes.targetHeight = [self maxHeight];
    }
    self.weekCalendar.top = self.attributes.sourceY;
}

//月视图下，该日期应该在的位置
- (float)getModelMonthY:(WDCalendarDateModel *)dateModel{
    NSInteger targetRow = [self getRowByDateModel:self.currentShowDateCalendar];
    return 30 + targetRow * [WDCalendarView getRowHeight];
}

//周视图下，该日期应该在的位置
- (float)getModelWeekY{
    return 30;
}

//正在拖动的时候，计算视图的高度变化
- (void)scopeTransitionDidUpdate:(UIPanGestureRecognizer *)panGesture{
    CGPoint translation = [panGesture translationInView:panGesture.view];
    float finalHeight = self.attributes.sourceHeight + translation.y;
    
    if (self.transition == WDCalendarTransitionMonthToWeek) {
        if (finalHeight > [self minHeight] || finalHeight < [self maxHeight]) {
            [self changeSubFrames:translation.y];
            if (self.height <= self.attributes.sourceY + [WDCalendarView getRowHeight]) {
                self.weekCalendar.top = self.height - ([WDCalendarView getRowHeight]);
            }else{
                self.weekCalendar.top = self.attributes.sourceY;
            }
        }
    }else if (self.transition == WDCalendarTransitionWeekToMonth){
        if (finalHeight > [self minHeight] || finalHeight < [self maxHeight]) {
            [self changeSubFrames:translation.y];
            if (self.height <= self.attributes.targetY + [WDCalendarView getRowHeight]) {
                self.weekCalendar.top = self.height - ([WDCalendarView getRowHeight]);
            }else{
                self.weekCalendar.top = self.attributes.targetY;
            }
        }
    }
}

//拖动完成之后判断是到周视图还是月视图
- (void)scopeTransitionDidEnd:(UIPanGestureRecognizer *)panGesture{
    self.transitionState = WDCalendarTransitionStateIdle;
    CGFloat velocity = [panGesture velocityInView:panGesture.view].y;

    switch (self.transition) {
        case WDCalendarTransitionMonthToWeek:
        {
            if (velocity >= 0) {
                self.attributes.sourceY = [self getModelWeekY];
                self.attributes.targetY = [self getModelMonthY:self.currentShowDateCalendar];
                [self performMonthTransition:self.transition];
            } else {
                [self performToWeekTransition:self.transition];
            }
        }
            break;
        case WDCalendarTransitionWeekToMonth:
        {
            if (velocity >= 0) {
                [self performMonthTransition:self.transition];
            } else {
                self.attributes.targetY = [self getModelWeekY];
                float sourceY = [self getModelMonthY:self.currentShowDateCalendar];
                self.attributes.sourceY = sourceY>self.weekCalendar.top?self.weekCalendar.top:sourceY;
                [self performToWeekTransition:self.transition];
            }
        }
            break;
        default:
            break;
    }
}

//从月视图到周视图
- (void)performToWeekTransition:(WDCalendarTransition)transition{
    __weak typeof(self) weakSelf = self;
    [self _selfHightToWeekCalendarPositionAnimation1:^(BOOL finished) {
        float progress = ((weakSelf.attributes.sourceY-weakSelf.attributes.targetY)/[WDCalendarView getRowHeight])*0.08;
        [UIView animateWithDuration:progress animations:^{
            [weakSelf _updateSelfToHeight:[weakSelf minHeight]];
            weakSelf.weekCalendar.top = weakSelf.attributes.targetY;
        } completion:^(BOOL finished) {
            weakSelf.scope = WDCalendarScopeWeek;
            weakSelf.transition = WDCalendarTransitionNone;
            weakSelf.transitionState = WDCalendarTransitionStateFinishing;
            weakSelf.scrollView.scrollEnabled = false;
            if ([weakSelf.delegate respondsToSelector:@selector(calendarDidChangeToScope:)]) {
                [weakSelf.delegate calendarDidChangeToScope:WDCalendarScopeWeek];
            }
        }];
        
    }];
}

//从月视图到周视图的话，先把自己的高度移动sourceY的位置,在用self的高度和weekCalendar的top一起做动画
- (void)_selfHightToWeekCalendarPositionAnimation1:(void (^ __nullable)(BOOL finished))completion{
    float targetHeight = self.attributes.sourceY + [WDCalendarView getRowHeight];
    if (self.height > targetHeight) {
        float progress = ((self.height - targetHeight)/[WDCalendarView getRowHeight])*0.08;
        [UIView animateWithDuration:progress animations:^{
            [self _updateSelfToHeight:targetHeight];
        } completion:completion];
    }else{
        if(completion) completion(YES);
    }
}

//从周视图到月视图的话，先将自己的位置和weekCalendar的top移到targetY的位置，再将自己的高度放到最大
- (void)_selfHightToWeekCalendarPositionAnimation2:(void (^ __nullable)(BOOL finished))completion{
    float targetHeight = self.attributes.targetY + [WDCalendarView getRowHeight];
    if (self.height < targetHeight) {
        float progress = ((targetHeight - self.height)/[WDCalendarView getRowHeight])*0.08;
        [UIView animateWithDuration:progress animations:^{
            [self _updateSelfToHeight:targetHeight];
            self.weekCalendar.top = self.attributes.targetY;
        } completion:completion];
    }else{
        if(completion) completion(YES);
    }
}

- (void)_updateSelfToHeight:(float)height{
    self.height = height;
    self.scrollView.height = self.height;
    if ([self.delegate respondsToSelector:@selector(calendar:showWithHeight:)]) {
        [self.delegate calendar:self.subCalendarViews[1]
                 showWithHeight:self.height];
    }
}

//从周视图到月视图
- (void)performMonthTransition:(WDCalendarTransition)transition{
    __weak typeof(self) weakSelf = self;
    [self _selfHightToWeekCalendarPositionAnimation2:^(BOOL finished) {
        float progress = (([weakSelf maxHeight] - weakSelf.height)/[WDCalendarView getRowHeight]) * 0.08;//一行移动的时间是0.08
        [UIView animateWithDuration:progress animations:^{
            [weakSelf _updateSelfToHeight:[weakSelf maxHeight]];
        } completion:^(BOOL finished) {
            weakSelf.scope = WDCalendarScopeMonth;
            weakSelf.transition = WDCalendarTransitionNone;
            weakSelf.transitionState = WDCalendarTransitionStateFinishing;
            weakSelf.scrollView.scrollEnabled = true;
            [_weekCalendar removeFromSuperview];
            _weekCalendar = nil;
            if ([weakSelf.delegate respondsToSelector:@selector(calendarDidChangeToScope:)]) {
                [weakSelf.delegate calendarDidChangeToScope:WDCalendarScopeMonth];
            }
        }];
    }];
}

//根据拖动的距离，更新界面
- (void)changeSubFrames:(float)subHeight{
    self.height = self.attributes.sourceHeight + subHeight;
    if (self.height > [self maxHeight]) {
        self.height = [self maxHeight];
    }
    if (self.height < [self minHeight]) {
        self.height = [self minHeight];
    }
    self.scrollView.height = self.height;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width*3, self.scrollView.height);
    
    if ([self.delegate respondsToSelector:@selector(calendar:showWithHeight:)]) {
        [self.delegate calendar:self.subCalendarViews[1]
                 showWithHeight:self.height];
    }
}

- (float)minHeight{
    return 30 + [WDCalendarView getRowHeight];
}

- (float)maxHeight{
    WDCalendarView *calendar = self.subCalendarViews[1];
    return calendar.height;
}

- (FSCalendarTransitionAttributes *)attributes
{
    if(!_attributes){
        _attributes = [[FSCalendarTransitionAttributes alloc] init];
    }
    return _attributes;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.userInteractionEnabled = YES;
    [self panGestureRecognizer];
}

- (void)convertToCalendarScope:(WDCalendarScope)scope
{
    if (self.scope == scope) {
        return;
    }
    switch (scope) {
        case WDCalendarScopeWeek:
            self.transitionState = WDCalendarTransitionStateChanging;
            self.transition = WDCalendarTransitionMonthToWeek;
            [self setTransitionBeginValue];
            [self performToWeekTransition:self.transition];
            break;
        case WDCalendarScopeMonth:
            self.transitionState = WDCalendarTransitionStateChanging;
            self.transition = WDCalendarTransitionWeekToMonth;
            [self setTransitionBeginValue];
            [self performMonthTransition:self.transition];
        default:
            break;
    }
}

- (void)backToMonthViewBtnAction{
    [self convertToCalendarScope:WDCalendarScopeMonth];
}

@end

@implementation FSCalendarTransitionAttributes
@end
