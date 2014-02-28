//
//  CalendarCollectionViewController.h
//  MoveOnLayout
//
//  Created by bhliu on 14-2-18.
//  Copyright (c) 2014年 bhliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDate *firstDate;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) NSDate *selectedDate;

@end
