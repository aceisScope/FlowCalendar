//
//  CalendarCollectionViewController.m
//  MoveOnLayout
//
//  Created by bhliu on 14-2-18.
//  Copyright (c) 2014年 bhliu. All rights reserved.
//

#import "CalendarCollectionViewController.h"

#import "LineCalendarFlowLayout.h"
#import "LineCalendarCell.h"

const NSUInteger NumberOfDaysPerScreen = 5;
const CGFloat CalendaViewWidth = 270.0f;
const CGFloat CalendaViewHeight = 260.0f;

static NSString *CalendarViewCellIdentifier = @"collection.cell.identifier";

@interface CalendarCollectionViewController ()
{
    BOOL animateLock;
    
}

@property (nonatomic, strong) NSDateFormatter *monthDateFormatter;
@property (nonatomic, strong) UILabel *monthLabel;

@property (nonatomic, strong) NSDateComponents* currentMonth;
@property (nonatomic, strong) NSDateComponents* nextMonth;

@end

@implementation CalendarCollectionViewController

//Explicitely @synthesize the var (it will create the iVar for us automatically as we redefine both getter and setter)
@synthesize firstDate = _firstDate;
@synthesize lastDate = _lastDate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //Force the creation of the view with the pre-defined Flow Layout.
    //Still possible to define a custom Flow Layout, if needed by using initWithCollectionViewLayout:
    self = [super initWithCollectionViewLayout:[[LineCalendarFlowLayout alloc] init]];
    if (self) {
        // Custom initialization
        [self simpleCalendarCommonInit];
    }
    
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        [self simpleCalendarCommonInit];
    }
    
    return self;
}

- (void)simpleCalendarCommonInit
{
    self.monthLabel = [[UILabel alloc] init];
    NSDateComponents *components = [NSDateComponents new];
    components = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]];
    self.currentMonth = components;
    self.nextMonth = [NSDateComponents new];
}

#pragma mark - Accessors

- (NSDateFormatter *)headerDateFormatter;
{
    if (!_monthDateFormatter) {
        _monthDateFormatter = [[NSDateFormatter alloc] init];
        _monthDateFormatter.calendar = self.calendar;
        _monthDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyyLLLL" options:0 locale:[NSLocale currentLocale]];
    }
    return _monthDateFormatter;
}

- (NSCalendar *)calendar
{
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
    }
    return _calendar;
}

- (NSDate *)firstDate
{
    if (!_firstDate) {
        NSDateComponents *components = [NSDateComponents new];
        components.day = 28;
        components.month = 7;
        components.year = 2013;
        [self setFirstDate:[self.calendar dateFromComponents:components]];
    }
    return _firstDate;
}

- (void)setFirstDate:(NSDate *)firstDate
{
    NSDateComponents *components = [self.calendar components:NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit fromDate:firstDate];
    _firstDate = [self.calendar dateFromComponents:components];
}

- (NSDate *)lastDate
{
    if (!_lastDate) {
        [self setLastDate:[NSDate date]];
    }
    return _lastDate;
}

- (void)setLastDate:(NSDate *)lastDate
{    
    NSDateComponents *components = [self.calendar components:NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit fromDate:lastDate];
    _lastDate = [self.calendar dateFromComponents:components];
    
}

- (void)setSelectedDate:(NSDate *)newSelectedDate
{
    [self setSelectedDate:newSelectedDate animated:NO];
}

- (void)setSelectedDate:(NSDate *)newSelectedDate animated:(BOOL)animated
{
    //Test if selectedDate between first & last date
    NSDate *startOfDay = [self clampDate:newSelectedDate toComponents:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit];
    if (([startOfDay compare:self.firstDate] == NSOrderedAscending) || ([startOfDay compare:self.lastDate] == NSOrderedDescending)) {
        return;
    }
    
    [[self cellForItemAtDate:_selectedDate] setSelected:NO];
    [[self cellForItemAtDate:startOfDay] setSelected:YES];
    
    _selectedDate = startOfDay;
    
    NSIndexPath *indexPath = [self indexPathForCellAtDate:_selectedDate];
    [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
    
    [self scrollToDate:_selectedDate animated:animated];
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    @try {
        NSIndexPath *selectedDateIndexPath = [self indexPathForCellAtDate:date];

        if (![[self.collectionView indexPathsForVisibleItems] containsObject:selectedDateIndexPath]) {

            UICollectionViewLayoutAttributes *sectionLayoutAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:selectedDateIndexPath];
            CGPoint origin = CGPointZero;
            origin.x = sectionLayoutAttributes.frame.origin.x - (NumberOfDaysPerScreen - 1)*sectionLayoutAttributes.frame.size.width;
            origin.y = 0;
            [self.collectionView setContentOffset:origin animated:animated];
        }
    }
    @catch (NSException *exception) {
        //Exception occured (it should not according to the documentation, but in reality...) let's scroll to the IndexPath then
        NSInteger section = [self sectionForDate:date];
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        [self.collectionView scrollToItemAtIndexPath:sectionIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    }
}


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    //Configure the Collection View
    [self.collectionView registerClass:[LineCalendarCell class] forCellWithReuseIdentifier:CalendarViewCellIdentifier];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.frame = CGRectMake((self.view.frame.size.width - CalendaViewWidth)/2, 155,CalendaViewWidth , CalendaViewHeight);

    self.monthLabel.frame = (CGRect){0,93,self.view.frame.size.width,30};
    [self.view addSubview:self.monthLabel];
    [self.monthLabel setFont:[UIFont systemFontOfSize:25]];
    [self.monthLabel setTextAlignment:NSTextAlignmentCenter];
    [self.monthLabel setTextColor:[UIColor whiteColor]];
    [self.monthLabel setBackgroundColor:[UIColor clearColor]];
    self.monthLabel.text = [NSString stringWithFormat:@"%ld年%ld月",self.currentMonth.year,self.currentMonth.month];
    [self.monthLabel sizeToFit];
    self.monthLabel.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, 98);
    
    //iOS7 Only: We don't want the calendar to go below the status bar (&navbar if there is one).
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    animateLock = YES;
    [self performSelector:@selector(scrollToToday) withObject:nil afterDelay:1];
}

#pragma mark - private

- (void)scrollToToday
{
    [self scrollToDate:_lastDate animated:NO];
    animateLock = NO;
}


- (void)animateMonthLabel
{
    if (animateLock) {
        return;
    }
    
    [UIView animateWithDuration:1.5 animations:^{
        self.monthLabel.alpha = .5;
    } completion:^(BOOL finished) {
        self.monthLabel.text = [NSString stringWithFormat:@"%ld年%ld月",self.currentMonth.year,self.currentMonth.month];
        [self.monthLabel sizeToFit];
        self.monthLabel.alpha = 1;
    }];
}

#pragma mark - Rotation Handling

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait){
        self.monthLabel.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, 98);
        self.collectionView.frame = CGRectMake((self.view.frame.size.width - CalendaViewWidth)/2, 155,CalendaViewWidth , CalendaViewHeight);
    }
    else {
        self.monthLabel.center = CGPointMake(CGRectGetWidth(self.view.frame)*2.5/2, 98);
        self.collectionView.frame = CGRectMake((self.view.frame.size.width - CalendaViewWidth)/2, 30, CalendaViewWidth , CalendaViewHeight);
    }
    [self.collectionView.collectionViewLayout invalidateLayout];
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //Each Section is a Month
    // always count number of months from the 1st of the beginning month otherwise there may be one month less
    // e.g. 2013.7.28  -  2014.3.1
    NSDateComponents *components = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:self.firstDate];
    components.day = 1;
    return [self.calendar components:NSMonthCalendarUnit fromDate:[self.calendar dateFromComponents:components] toDate:self.lastDate options:0].month + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    
    // how many days in current month
    NSRange rangeOfDays = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstOfMonth];
    
    NSInteger numberOfDays = rangeOfDays.length;
    
    if (section == 0) //fristdate: trim dates before it
    {
        // how many days before first date
        NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:_firstDate];
        numberOfDays -= ordinalityOfFirstDay - 1;
    }
    else if (section == [self numberOfSectionsInCollectionView:self.collectionView] - 1) // lastdate: 去掉之后的日期
    {
        NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:_lastDate];
        numberOfDays = ordinalityOfFirstDay;
    }
    
    return numberOfDays;
}


- (LineCalendarCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LineCalendarCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:CalendarViewCellIdentifier
                                                                                forIndexPath:indexPath];
    
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];
    
    [cell setDatContent:cellDate calendar:self.calendar];
    [cell setMarks];
    
    if ([cellDate isEqualToDate:_lastDate])  // whether to add the last vertical line
    {
        [cell setLast:YES];
    }
    else {
        [cell setLast:NO];
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];
    
    NSDateComponents *cellDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:cellDate];
    NSDateComponents *firstOfMonthsComponents = [self.calendar components:NSMonthCalendarUnit fromDate:firstOfMonth];
    
    return (cellDateComponents.month == firstOfMonthsComponents.month);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedDate = [self dateForCellAtIndexPath:indexPath];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = floorf(CalendaViewWidth / NumberOfDaysPerScreen);
    return CGSizeMake(itemWidth, 210);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    
    if (sortedIndexPaths.count > 1) {
        NSIndexPath *firstIndexPath = [sortedIndexPaths firstObject];
        NSDateComponents *components = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[self firstOfMonthForSection:firstIndexPath.section]];
        if (components.month != self.currentMonth.month && !animateLock)  //月份改变
        {
            self.currentMonth = components;
            [self animateMonthLabel];
        }
    }
}

#pragma mark -
#pragma mark - Calendar calculations

- (NSDate *)clampDate:(NSDate *)date toComponents:(NSUInteger)unitFlags
{
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:date];
    return [self.calendar dateFromComponents:components];
}

- (BOOL)isTodayDate:(NSDate *)date
{
    return [self clampAndCompareDate:date withReferenceDate:[NSDate date]];
}

- (BOOL)isSelectedDate:(NSDate *)date
{
    if (!self.selectedDate) {
        return NO;
    }
    return [self clampAndCompareDate:date withReferenceDate:self.selectedDate];
}

- (BOOL)clampAndCompareDate:(NSDate *)date withReferenceDate:(NSDate *)referenceDate
{
    NSDate *refDate = [self clampDate:referenceDate toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];
    NSDate *clampedDate = [self clampDate:date toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];
    
    return [refDate isEqualToDate:clampedDate];
}

#pragma mark - Collection View / Calendar Methods

- (NSDate *)firstOfMonthForSection:(NSInteger)section
{
    if (section == 0) //first date may not be the 1st of a month
    {
        return _firstDate;
    }
    
    NSDateComponents *offset = [NSDateComponents new];
    offset.month = section;
    
    NSDateComponents *components = [self.calendar components:NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit fromDate:[self.calendar dateByAddingComponents:offset toDate:self.firstDate options:0]];
    components.day = 1;
    
    return [self.calendar dateFromComponents:components];
}

- (NSInteger)sectionForDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:self.firstDate];
    components.day = 1;
    return [self.calendar components:NSMonthCalendarUnit fromDate:[self.calendar dateFromComponents:components] toDate:date options:0].month;
}


- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = indexPath.item;
    
    return [self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0];
}


- (NSIndexPath *)indexPathForCellAtDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    NSInteger section = [self sectionForDate:date];
    
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    NSDateComponents *dateComponents = [self.calendar components:NSDayCalendarUnit fromDate:date];
    NSDateComponents *firstOfMonthComponents = [self.calendar components:NSDayCalendarUnit fromDate:firstOfMonth];
    
    NSInteger item;
    item = (dateComponents.day - firstOfMonthComponents.day);
    
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (LineCalendarCell *)cellForItemAtDate:(NSDate *)date
{
    return (LineCalendarCell *)[self.collectionView cellForItemAtIndexPath:[self indexPathForCellAtDate:date]];
}


@end
