//
//  NotificationsTVC.h
//
//  Created by Ghita Tazi on 31/05/2014.
//  Copyright (c) 2014 Ghita Tazi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NotificationsTVC : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, strong) QBUUser * user;
@property (nonatomic, strong) NSString * addressUserEvent;
@property (nonatomic, strong) NSString * descriptionUserEvent;
@property (nonatomic, strong) NSString * creatorUserEvent;
@property (nonatomic, strong) NSString * typeEvent;
@property (nonatomic, strong) NSString * linkWebsite;

@end
