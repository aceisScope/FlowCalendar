//
//  LineCalendarCell.m
//  MoveOnLayout
//
//  Created by bhliu on 14-2-20.
//  Copyright (c) 2014年 bhliu. All rights reserved.
//

#import "LineCalendarCell.h"

#define DAY_HEIGHT 19
#define WEEK_HEIGHT 12
#define DOT_RADIUS 5

static NSArray *weekdays = nil;

@interface LineCalendarCell()

@property (nonatomic,strong) UILabel *dayLabel;
@property (nonatomic,strong) UILabel *weekdayLabel;
@property (nonatomic,readwrite,setter = setLast:) BOOL isLast;

@end

@implementation LineCalendarCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        weekdays =  @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
        
        self.isLast = NO;
        self.opaque = NO;
        
        self.weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), WEEK_HEIGHT)];
        [self.contentView addSubview:self.weekdayLabel];
        self.weekdayLabel.textAlignment = NSTextAlignmentCenter;
        self.weekdayLabel.textColor = [UIColor whiteColor];
        self.weekdayLabel.font = [UIFont systemFontOfSize:10];
        self.weekdayLabel.backgroundColor = [UIColor clearColor];
        
        self.dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, WEEK_HEIGHT, CGRectGetWidth(frame), DAY_HEIGHT)];
        [self.contentView addSubview:self.dayLabel];
        self.dayLabel.textAlignment = NSTextAlignmentCenter;
        self.dayLabel.textColor = [UIColor whiteColor];
        self.dayLabel.font = [UIFont systemFontOfSize:18];
        self.dayLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);

    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 0. ,DAY_HEIGHT + WEEK_HEIGHT);
    CGContextAddLineToPoint(context, 0, rect.size.height);
    CGContextStrokePath(context);
    
    if (self.isLast) {
        CGContextMoveToPoint(context, rect.size.width - 1.,DAY_HEIGHT + WEEK_HEIGHT);
        CGContextAddLineToPoint(context, rect.size.width - 1., rect.size.height);
        CGContextStrokePath(context);
    }
    
    [self drawCircleInRect:CGRectMake(rect.size.width/2-DOT_RADIUS, 40, DOT_RADIUS*2, DOT_RADIUS*2) withFilledColor:[UIColor colorWithRed:217./255 green:81./255 blue:77./255 alpha:1]];
    [self drawCircleInRect:CGRectMake(rect.size.width/2-DOT_RADIUS, 80, DOT_RADIUS*2, DOT_RADIUS*2) withFilledColor:[UIColor colorWithRed:252./255 green:141./255 blue:39./255 alpha:1]];
    [self drawCheckedInRect:CGRectMake(rect.size.width/2-4*DOT_RADIUS, 40, DOT_RADIUS*8, DOT_RADIUS*8)];
    
}

- (void) drawRingInRect: (CGRect) rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextStrokeEllipseInRect(context, rect);
}

- (void) drawCircleInRect: (CGRect) rect withFilledColor:(UIColor*)filledColor
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [filledColor setFill];
    CGContextFillEllipseInRect(context, rect);
}

- (void) drawCheckedInRect: (CGRect) rect
{
    //// Frames
    CGRect frame = rect;
    
    //// Subframes
    CGRect group = CGRectMake(CGRectGetMinX(frame) + 3, CGRectGetMinY(frame) + 3, CGRectGetWidth(frame) - 6, CGRectGetHeight(frame) - 6);
    

    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.27083 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.54167 * CGRectGetHeight(group))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.41667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.68750 * CGRectGetHeight(group))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.75000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.35417 * CGRectGetHeight(group))];
    bezierPath.lineCapStyle = kCGLineCapSquare;
    
    [[UIColor colorWithRed:58./255 green:141./255 blue:210./255 alpha:1.] setStroke];
    bezierPath.lineWidth = 1.3;
    [bezierPath stroke];
}


- (void)setLast:(BOOL)isLast
{
    _isLast = isLast;
    [self setNeedsDisplay];
}

- (void)setDatContent:(NSDate*)date calendar:(NSCalendar*)calendar
{
    NSString* day = @"";
    NSString* week = @"";
    if (date && calendar) {
        NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
        week = [NSString stringWithFormat:@"%@", weekdays[dateComponents.weekday-1]];
        day = [NSString stringWithFormat:@"%@",@(dateComponents.day)];
    }
    self.dayLabel.text = day;
    self.weekdayLabel.text = week;
}

- (void)setMarks
{
    // test only
    [self setNeedsDisplay];
}

@end
