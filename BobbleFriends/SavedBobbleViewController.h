//
//  SavedBobbleViewController.h
//  BobbleFriends
//
//  Created by Peter Kamm on 6/3/13.
//  Copyright (c) 2013 Peter Kamm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ShareViewController.h"



@interface SavedBobbleTableCell : UITableViewCell{
}
@property (weak, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UILabel *bobbleTitle;
@property (weak, nonatomic) IBOutlet UIImageView *bobbleImage;
@property (strong, nonatomic) NSString *filePath;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;


@end


@interface SavedBobbleViewController : ShareViewController<FBFriendPickerDelegate, UIAlertViewDelegate>{
    NSDateFormatter *_dateFormatter;
}
@property (weak, nonatomic) IBOutlet UITableView *savedBobbleTableView;
@property (strong, nonatomic) MPMoviePlayerViewController *player;

@end
