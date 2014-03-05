//
//  ChooseBodyViewController.h
//  BobbleFriends
//
//  Created by Peter Kamm on 1/6/13.
//  Copyright (c) 2013 Peter Kamm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseBodyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
