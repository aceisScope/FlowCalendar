//
//  LineCalendarCell.h
//  MoveOnLayout
//
//  Created by bhliu on 14-2-20.
//  Copyright (c) 2014年 bhliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineCalendarCell : UICollectionViewCell

- (void)setDatContent:(NSDate*)date calendar:(NSCalendar*)calendar;
- (void)setLast:(BOOL)isLast;
- (void)setMarks;

@end
