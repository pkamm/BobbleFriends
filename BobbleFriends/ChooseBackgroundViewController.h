//
//  ChooseBackgroundViewController.h
//  BobbleFriends
//
//  Created by Peter Kamm on 12/18/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

@class Background;
#import <UIKit/UIKit.h>

@interface ChooseBackgroundViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

-(void)addBackgroundIndex:(int)bgIndex secondInCell:(BOOL)isSecond toCell:(UITableViewCell*)cell;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
