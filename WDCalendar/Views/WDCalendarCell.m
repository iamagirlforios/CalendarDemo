//
//  WDCalendarCell.m
//  WDCalendar
//
//  Created by 吴丹 on 17/3/14.
//  Copyright © 2017年 吴丹. All rights reserved.
//

#import "WDCalendarCell.h"
#import "config.h"
#import "WDCalendarView.h"

@interface WDCalendarCell()
@property (nonatomic, strong) UIView *bgColorView;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UILabel *specialTagLabel;
@end

@implementation WDCalendarCell
- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:16];
        CGSize size = [self getLabelFrame2:CGSizeMake(100, 100) font:_textLabel.font text:@"25"];
        _textLabel.frame = CGRectMake(0, 0, size.width+5, size.height);
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_textLabel];
    }
    return _textLabel;
}

- (UILabel *)subLabel
{
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.font = [UIFont systemFontOfSize:9];
        CGSize size = [self getLabelFrame2:CGSizeMake(100, 100) font:_subLabel.font text:@"春分"];
        _subLabel.frame = CGRectMake(0, 0, size.width + 10, size.height);
        _subLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_subLabel];
    }
    return _subLabel;
}

- (UILabel *)specialTagLabel
{
    if (!_specialTagLabel) {
        _specialTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 16)];
        _specialTagLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:_specialTagLabel];
    }
    return _specialTagLabel;
}
- (UIView *)bgColorView
{
    if (!_bgColorView) {
        float height = [WDCalendarView getRowHeight]-2;
        _bgColorView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgColorView.frame = CGRectMake([WDCalendarView getRowWidth]/2-height/2, 1, height, height);
        _bgColorView.layer.cornerRadius = height/2;
        _bgColorView.layer.borderWidth = 1.5;
        _bgColorView.backgroundColor = [UIColor clearColor];
    }
    return _bgColorView;
}

- (CGSize)getLabelFrame2:(CGSize)baseSie font:(UIFont *)font  text:(NSString *)text
{
    
    CGSize  actualsize =[text boundingRectWithSize:baseSie options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName: font, NSBaselineOffsetAttributeName:[NSNumber numberWithInt:NSLineBreakByWordWrapping]} context:nil].size;
    return actualsize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float padding = 0;
    self.textLabel.font = [UIFont systemFontOfSize:16];
    if(self.subLabel.text.length == 0){
        self.subLabel.height = 0;
        self.textLabel.font = [UIFont systemFontOfSize:17];
    }
    float totalHeight = self.textLabel.height + self.subLabel.height + padding;
    self.textLabel.top = self.height / 2 - totalHeight / 2;
    self.textLabel.left = self.width/2-self.textLabel.width/2;
    self.specialTagLabel.left = self.textLabel.right-2;
    self.specialTagLabel.top = self.textLabel.top;
    self.subLabel.top = self.textLabel.bottom + padding;
    self.subLabel.left = self.width/2-self.subLabel.width/2;
}

- (void)setIsInvalid:(BOOL)isInvalid
{
    _isInvalid = isInvalid;
    if (isInvalid) {
        self.textLabel.textColor = kInvaildColor;
        self.subLabel.textColor = kInvaildColor;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [_bgColorView removeFromSuperview];
        _bgColorView = nil;
    }
}

- (void)setStyle:(CollectionViewCellDayType)style
{
    if (self.isInvalid) {
        return;
    }
    self.textLabel.textColor = [UIColor blackColor];
    self.subLabel.textColor = [UIColor blackColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    if (self.isToday) {
        [self setStyleViewBackgroundcolor:RGBA(217, 217, 217, 1)
                               boardColor:RGBA(217, 217, 217, 1)];
    }
    switch (style) {
        case CellDayTypeClick:
            [self setStyleViewBackgroundcolor:kAppBaseColor
                                   boardColor:kAppBaseColor];
            self.textLabel.textColor = [UIColor whiteColor];
            self.subLabel.textColor = [UIColor whiteColor];
            break;
        case CellDayTypeMutableClick:
            self.contentView.backgroundColor = kAppBaseColor;
            [_bgColorView removeFromSuperview];
            _bgColorView = nil;
            break;
        case CellDayTypeHasBothSechdule: //某个日期即有我的日程也是别人的日程
        case CellDayTypeHasOtherSechdule:  //某个日期有他们的日程
        {
            if (self.isToday) {
                [self setStyleViewBackgroundcolor:RGBA(217, 217, 217, 1)
                                       boardColor:RGBA(243, 156, 42, 1)];

            }else{
                [self setStyleViewBackgroundcolor:[UIColor whiteColor]
                                       boardColor:RGBA(243, 156, 42, 1)];
            }
        }
            break;
        case CellDayTypeHasMySechdule:  //某个日期有我的日程
        {
            if (self.isToday) {
                [self setStyleViewBackgroundcolor:RGBA(217, 217, 217, 1)
                                       boardColor:kAppBaseColor];
            }else{
                [self setStyleViewBackgroundcolor:[UIColor whiteColor]
                                       boardColor:kAppBaseColor];
            }
        }
            break;
        default:
            if(!self.isToday)
            {
                [_bgColorView removeFromSuperview];
                _bgColorView = nil;
            }
            break;
    }
}

- (void)setStyleViewBackgroundcolor:(UIColor *)gColor boardColor:(UIColor *)bColor{
    if (!self.bgColorView.superview) {
        [self.contentView addSubview:self.bgColorView];
        [self.contentView sendSubviewToBack:self.bgColorView];
    }
    self.bgColorView.backgroundColor = gColor;
    self.bgColorView.layer.borderColor = bColor.CGColor;
}

- (void)setIsHoliday:(BOOL)isHoliday
{
    _isHoliday = isHoliday;
    self.specialTagLabel.text = isHoliday?@"休":@"";
    self.specialTagLabel.textColor = RGBA(243, 167, 57, 1);
}

- (void)setIsWokeDay:(BOOL)isWokeDay
{
    _isWokeDay = isWokeDay;
    self.specialTagLabel.text = isWokeDay?@"班":@"";
    self.specialTagLabel.textColor = kAppBaseColor;
}

@end
