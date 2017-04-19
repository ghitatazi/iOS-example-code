//
//  NotificationsTVC.m
//
//  Created by Ghita Tazi on 31/05/2014.
//  Copyright (c) 2014 Ghita Tazi. All rights reserved.
//

#import "NotificationsTVC.h"
#import <Parse/Parse.h>
#import "messageNotifTVCell.h"
#import "profileSelectedTableViewController.h"
#import "messageViewController.h"
#import "EventsViewController.h"

@interface NotificationsTVC () <QBActionStatusDelegate>

@property (nonatomic, strong) NSMutableArray * friendRequests;
@property (nonatomic, strong) NSMutableArray * messages;
@property (nonatomic, strong) NSMutableArray * erasmEvents;
@property (nonatomic, strong) NSMutableArray * userEvents;
@property (nonatomic, strong) PFObject * senderRequestSelected;

@end

@implementation NotificationsTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    NSLog(@"view vill appear called");
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friendRequests = [[NSMutableArray alloc] init];
    self.messages = [[NSMutableArray alloc] init];
    self.erasmEvents = [[NSMutableArray alloc] init];
    self.userEvents = [[NSMutableArray alloc] init];
    self.senderRequestSelected = NULL;
    self.user = NULL;
    
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlValueChanged)
                  forControlEvents:UIControlEventValueChanged];

    self.tableView.delegate = self;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
    PFUser * currentUser = [PFUser currentUser];
    [query whereKey:@"SentTo" equalTo:currentUser.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d notifications.", objects.count);
            
            if (objects.count > 0) {
                for (PFObject *object in objects) {
                    NSLog(@"Type of notifications: %@, sent from: %@ at: %@", object[@"TypeOfNotif"], object[@"SentFrom"], object[@"Hour"]);
                    
                    NSString * typeNotif = [NSString stringWithFormat:@"%@", object[@"TypeOfNotif"]];
                    
                    if ([typeNotif isEqualToString:@"friendShipRequest"]) {
                        [self.friendRequests addObject:object];
                        
                    } else if ([typeNotif isEqualToString:@"erasmusEvent"]) {
                        [self.erasmEvents addObject:object];
                        
                    } else if ([typeNotif isEqualToString:@"userEvent"]) {
                        [self.userEvents addObject:object];
                        
                    } else if ([typeNotif isEqualToString:@"newMessage"]) {
                        [self.messages addObject:object];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    /*
                    //display messages in self.messages:
                    //le self.messages se complète bien:
                    if ([self.messages count] > 0) {
                        for (PFObject * messageNotif in self.messages) {
                        NSLog(@"messageNotif in self.messages from: %@", messageNotif[@"SentFrom"]);
                        }
                    }
                    */
                    [self.tableView reloadData];
                });
                
            } else {
                //No notifications:
                
                NSString *title = NSLocalizedString(@"Notifications", nil);
                NSString *message = NSLocalizedString(@"You have no notifications for the moment.", nil);
                NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
                
                [alert show];
                
                // hide alert after delay
                double delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [alert dismissWithClickedButtonIndex:0 animated:YES];
                });

            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error");
        }
    }];
}


- (void)refreshControlValueChanged
{
    [self viewDidLoad];
    // Terminar el control de refresco!
    [self.refreshControl endRefreshing];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * header;
    switch (section) {
        case 0:
            header = @"Friendship Requests";
            break;
        case 1:
            header = @"New messages";
            break;
        case 2:
            header = @"New Friends Events";
            break;
        case 3:
            header = @"New Erasmus Events";
            break;
        default:
            break;
    }
    return header;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numberRows;
    switch (section) {
        case 0:
            if ([self.friendRequests count] > 0) {
                numberRows = [self.friendRequests count];
            } else {
                numberRows = 1;
            }
            break;
        case 1:
            if ([self.messages count] > 0) {
                numberRows = [self.messages count];
            } else {
                numberRows = 1;
            }
            break;
        case 2:
            if ([self.userEvents count] > 0) {
                numberRows = [self.userEvents count];
            } else {
                numberRows = 1;
            }
            break;
        case 3:
            if ([self.erasmEvents count] > 0) {
                numberRows = [self.erasmEvents count];
            } else {
                numberRows = 1;
            }
            break;
        default:
            break;
    }
    return numberRows;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height;
    if (indexPath.section == 0) {
        height = 55;
    } else if (indexPath.section == 1) {
        height = 55;
    } else if (indexPath.section == 2) {
        height = 55;
    } else if (indexPath.section == 3) {
        height = 55;
    }
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    
    if (indexPath.section == 0) {
        if ([self.friendRequests count] > 0) {
            messageNotifTVCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"FriendRequest Cell" forIndexPath:indexPath];

            NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"SentFrom" ascending:YES];
            [self.friendRequests sortUsingDescriptors:[NSMutableArray arrayWithObject:sortByDate]];
            for (PFObject * friend in self.friendRequests) {
                NSLog(@"Sender of request: %@", friend[@"SentFrom"]);
            }
                    
            PFObject * friendRequest = self.friendRequests[indexPath.row];
            cell1.messageLabel.text = friendRequest[@"MessageDisplayed"];
            cell1.hourNotifLabel.text = friendRequest[@"Hour"];
            cell = cell1;
        }
    } else if (indexPath.section == 1) {
        if ([self.messages count] > 0) {
            messageNotifTVCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Message Cell" forIndexPath:indexPath];
            PFObject * message = self.messages[indexPath.row];
            cell2.messageLabel.text = message[@"MessageDisplayed"];
            cell2.hourNotifLabel.text = message[@"Hour"];
            cell = cell2;
        }
    } else if (indexPath.section == 2) {
        if ([self.userEvents count] > 0) {
            messageNotifTVCell *cell3 = [tableView dequeueReusableCellWithIdentifier:@"Event Cell" forIndexPath:indexPath];
            PFObject * userEvent = self.userEvents[indexPath.row];
            cell3.messageLabel.text = userEvent[@"MessageDisplayed"];
            cell3.hourNotifLabel.text = userEvent[@"Hour"];
            cell = cell3;
        }
        
    } else if (indexPath.section == 3) {
        if ([self.erasmEvents count] > 0) {
            messageNotifTVCell *cell4 = [tableView dequeueReusableCellWithIdentifier:@"Event Cell" forIndexPath:indexPath];
            PFObject * erasmEvent = self.erasmEvents[indexPath.row];
            cell4.messageLabel.text = erasmEvent[@"MessageDisplayed"];
            cell4.hourNotifLabel.text = erasmEvent[@"Hour"];
            cell = cell4;
        }
    }
    return cell;
}


//informs the delegate that the specified row is now selected
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",
          [NSString stringWithFormat:@"Cell %ld in Section %ld is selected",
           (long)indexPath.row, (long)indexPath.section]);
    
    if (([self.friendRequests count] > 0) && (indexPath.section == 0)) {
        PFObject * userSelected = self.friendRequests[indexPath.row];
        NSLog(@"Request sent from: %@", userSelected[@"SentFrom"]);
        NSString * email = userSelected[@"SentFrom"];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Users"];
        [query whereKey:@"Email" equalTo:email];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                NSLog(@"The friend request is sent from: %@ %@", object[@"FirstName"], object[@"FamilyName"]);
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    self.senderRequestSelected = object;
                    NSLog(@"self.senderRequestSelected: %@ %@", self.senderRequestSelected[@"FirstName"], self.senderRequestSelected[@"FamilyName"]);
                });
                
            } else {
                NSLog(@"error");
            }
        }];
    }

    if (([self.messages count] > 0) && (indexPath.section == 1)) {
        PFObject * userSenderMessage = self.messages[indexPath.row];
        NSLog(@"Message sent from: %@", userSenderMessage[@"SentFrom"]);
        NSString * email = userSenderMessage[@"SentFrom"];
        dispatch_async(dispatch_get_main_queue(), ^ {
            //retrieve the user from QuickBlox:
            [QBUsers userWithEmail:email delegate:self];
        });
    }
    
    if (([self.userEvents count] > 0) && (indexPath.section == 2)) {
        PFObject * userEventSelected = self.userEvents[indexPath.row];
        NSLog(@"Event Selected description: %@", userEventSelected[@"descriptionEvent"]);
        PFQuery *query = [PFQuery queryWithClassName:@"Events"];
        NSString * descriptionEvent = userEventSelected[@"descriptionEvent"];
        [query whereKey:@"Description" equalTo:descriptionEvent];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                NSLog(@"The event request is sent from: %@", object[@"Creator"]);
                NSLog(@"address event: %@", object[@"Adress"]);
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    self.addressUserEvent = object[@"Adress"];
                    self.descriptionUserEvent = object[@"Description"];
                    self.creatorUserEvent = object[@"Creator"];
                    self.typeEvent = object[@"TypeOfEvent"];
                });
            } else {
                NSLog(@"error");
            }
        }];
    }
    
    if (([self.erasmEvents count] > 0) && (indexPath.section == 3)) {
        PFObject * erasmEventSelected = self.erasmEvents[indexPath.row];
        NSLog(@"Event Selected description: %@", erasmEventSelected[@"descriptionEvent"]);
        PFQuery *query = [PFQuery queryWithClassName:@"Events"];
        NSString * descriptionEvent = erasmEventSelected[@"descriptionEvent"];
        [query whereKey:@"Description" equalTo:descriptionEvent];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                NSLog(@"The event request is sent from: %@", object[@"Creator"]);
                NSLog(@"address event: %@", object[@"Adress"]);
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    self.addressUserEvent = object[@"Adress"];
                    self.descriptionUserEvent = object[@"Description"];
                    self.creatorUserEvent = object[@"Creator"];
                    self.typeEvent = object[@"TypeOfEvent"];
                    self.linkWebsite = object[@"LinkToWebsite"];
                });
            } else {
                NSLog(@"error");
            }
        }];
    }
    
    if (indexPath.section == 0) {
        NSString *title = NSLocalizedString(@"Friendship request", nil);
        NSString *message = NSLocalizedString(@"Choose an option", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"Later", nil);
        NSString *otherButtonTitleOne = NSLocalizedString(@"Accept", nil);
        NSString *otherButtonTitleTwo = NSLocalizedString(@"Refuse", nil);
        NSString *otherButtonTitleThree = NSLocalizedString(@"See profil", nil);
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, otherButtonTitleTwo, otherButtonTitleThree, nil];
        alert.tag = 101;
        [alert show];

    } else if (indexPath.section == 2) {
        NSString *title = NSLocalizedString(@"New Friend Event", nil);
        NSString *message = NSLocalizedString(@"Choose an option", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"Later", nil);
        NSString *otherButtonTitleOne = NSLocalizedString(@"Take part of it", nil);
        NSString *otherButtonTitleTwo = NSLocalizedString(@"Refuse", nil);
        NSString *otherButtonTitleThree = NSLocalizedString(@"See on the map", nil);
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, otherButtonTitleTwo, otherButtonTitleThree, nil];
        alert.tag = 102;
        [alert show];
        
    } else if (indexPath.section == 3) {
        NSString *title = NSLocalizedString(@"New Erasmus Event", nil);
        NSString *message = NSLocalizedString(@"Choose an option", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"Later", nil);
        NSString *otherButtonTitleOne = NSLocalizedString(@"Take part of it", nil);
        NSString *otherButtonTitleTwo = NSLocalizedString(@"Refuse", nil);
        NSString *otherButtonTitleThree = NSLocalizedString(@"See on the map", nil);
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, otherButtonTitleTwo, otherButtonTitleThree, nil];
        alert.tag = 103;
        [alert show];
        
    } else if (indexPath.section == 1) {
        NSLog(@"See the message sent by one of the Erasmus");
        /*
        //the user is retrieved from QuickBlox at the begin of this method, now we perform the segue:
        NSString *title = NSLocalizedString(@"New Message", nil);
        NSString *message = NSLocalizedString(@"Choose an option", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"Later", nil);
        NSString *otherButtonTitleOne = NSLocalizedString(@"Take a look at it", nil);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, nil];
        alert.tag = 104;
        //self.alert = alert;
        [alert show];
        */
    }
}


#pragma mark -
#pragma mark QBActionStatusDelegate

- (void)completedWithResult:(Result *)result{
    // Get User result
    NSLog(@"entering retrieving user from QuickBlox");
    if(result.success && [result isKindOfClass:[QBUUserResult class]]){
        //NSLog(@"entering retrieving user from QuickBlox");
        QBUUserResult *userResult = (QBUUserResult *)result;
        NSLog(@"User retrieved from QuickBlox=%@", userResult.user);        
        //cest la que le self.opponent est récup pour voir le message:
        self.user = userResult.user;
        NSString *title = NSLocalizedString(@"New Message", nil);
        NSString *message = NSLocalizedString(@"Choose an option", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"Later", nil);
        NSString *otherButtonTitleOne = NSLocalizedString(@"Take a look at it", nil);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, nil];
        alert.tag = 104;
        [alert show];
    } else {
        NSLog(@"errors=%@", result.errors);
    }
}

#pragma mark - UIAlertViewDelegate
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if ((alertView.tag == 104) && (self.user == nil)) {
        return NO;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 101) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            NSLog(@"Alert view clicked with the cancel button index.");
        } else {
            NSLog(@"Alert view clicked with button at index %ld.", (long)buttonIndex);
            if (buttonIndex == 3) {
                
             [self performSegueWithIdentifier:@"Show Profile" sender:self];
                
            } else if (buttonIndex == 1) {
                
                
                NSLog(@"button Accept selected");
                NSLog(@"rajout du lien d'amitié dans classe Frienships");

                PFObject * friendship = [PFObject objectWithClassName:@"Friendships"];
                PFUser * currentUser = [PFUser currentUser];

                NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
                PFObject * userSelected = self.friendRequests[selectedIndexPath.row];
                NSLog(@"Request sent from: %@", userSelected[@"SentFrom"]);
                
                
                [friendship setObject:userSelected[@"SentFrom"] forKey:@"FriendOf"];
                [friendship setObject:currentUser.username forKey:@"NameOfTheFriend"];
                [friendship saveInBackgroundWithBlock:^(BOOL succeded, NSError *error)
                 {
                     if (!error) {
                         NSLog(@"No error saving friendship");
                     } else {
                         NSLog(@"error saving friendship");
                     }
                 }];

                NSLog(@"rajout du deuxième lien damitié");
                PFObject * friendship2 = [PFObject objectWithClassName:@"Friendships"];
                [friendship2 setObject:currentUser.username forKey:@"FriendOf"];
                [friendship2 setObject:userSelected[@"SentFrom"] forKey:@"NameOfTheFriend"];
                [friendship2 saveInBackgroundWithBlock:^(BOOL succeded, NSError *error)
                 {
                     if (!error) {
                         NSLog(@"No error saving friendship");
                     } else {
                         NSLog(@"error saving friendship");
                     }
                 }];

                NSString * email = userSelected[@"SentFrom"];
                NSLog(@"increment NbFriends of %@", email);
                PFQuery *query = [PFQuery queryWithClassName:@"Users"];
                [query whereKey:@"Email" equalTo:email];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error) {
                        NSLog(@"The friend request is sent from: %@ %@", object[@"FirstName"], object[@"FamilyName"]);
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                        [object incrementKey:@"NbFriends"];
                        [object saveInBackground];
                        });
                        
                    } else {
                        NSLog(@"error");
                    }
                }];

                NSString * emailReceived = userSelected[@"SentTo"];
                NSLog(@"increment NbFriends of %@", emailReceived);
                PFQuery *query2 = [PFQuery queryWithClassName:@"Users"];
                [query2 whereKey:@"Email" equalTo:emailReceived];
                [query2 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error) {
                        NSLog(@"The friend request is received by: %@ %@", object[@"FirstName"], object[@"FamilyName"]);
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            [object incrementKey:@"NbFriends"];
                            [object saveInBackground];
                        });
                        
                    } else {
                        NSLog(@"error");
                    }
                }];

                [self.friendRequests removeObject:userSelected];

                NSLog(@"suppression de la notification");
                [userSelected deleteInBackground];
                [self.tableView reloadData];
                
            } else if (buttonIndex == 2) {
                
                NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
                PFObject * userSelected = self.friendRequests[selectedIndexPath.row];

                [self.friendRequests removeObject:userSelected];

                NSLog(@"suppression de la notification");
                [userSelected deleteInBackground];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
                });
            }
        }
    } else if (alertView.tag == 102) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            NSLog(@"Alert view clicked with the cancel button index.");
        }
        
        else {
           NSLog(@"Alert view clicked with button at index %ld.", (long)buttonIndex);
            
            if (buttonIndex == 1) {
                NSLog(@"Button take part of it selected");
                NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
                PFObject * userEventSelected = self.userEvents[selectedIndexPath.row];
                NSLog(@"Event Selected description: %@", userEventSelected[@"descriptionEvent"]);
                
                PFQuery *query = [PFQuery queryWithClassName:@"Events"];

                NSString * descriptionEvent = userEventSelected[@"descriptionEvent"];
                [query whereKey:@"Description" equalTo:descriptionEvent];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error) {
                        NSLog(@"The event request is sent from: %@", object[@"Creator"]);
                        [object incrementKey:@"NbParticipants"];
                        [object saveInBackground];
                        
                    } else {
                        NSLog(@"error");
                    }
                }];
                
                [self.userEvents removeObject:userEventSelected];

                NSLog(@"suppression de la notification");
                [userEventSelected deleteInBackground];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self.tableView reloadData];
                });
                
            } else if (buttonIndex == 2) {
                
                NSLog(@"button Refuse selected");
                NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
                PFObject * eventSelected = self.userEvents[selectedIndexPath.row];

                [self.userEvents removeObject:eventSelected];
                
                NSLog(@"suppression de la notification");
                [eventSelected deleteInBackground];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self.tableView reloadData];
                });

                
            } else if (buttonIndex == 3) {
                NSLog(@"button See on the map selected");
                
                [self performSegueWithIdentifier:@"See on the map" sender:self];
            }
        }
    } else if (alertView.tag == 103) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            NSLog(@"Alert view clicked with the cancel button index.");
        }
        
        else {
            NSLog(@"Alert view clicked with button at index %ld.", (long)buttonIndex);
            
            if (buttonIndex == 1) {
                NSLog(@"Button take part of it selected");
                NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
                PFObject * erasmEventSelected = self.erasmEvents[selectedIndexPath.row];
                NSLog(@"Event Selected description: %@", erasmEventSelected[@"descriptionEvent"]);
                
                PFQuery *query = [PFQuery queryWithClassName:@"Events"];

                NSString * descriptionEvent = erasmEventSelected[@"descriptionEvent"];
                [query whereKey:@"Description" equalTo:descriptionEvent];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error) {
                        NSLog(@"The event request is sent from: %@", object[@"Creator"]);
                        [object incrementKey:@"NbParticipants"];
                        [object saveInBackground];
                        
                    } else {
                        NSLog(@"error");
                    }
                }];
                
                [self.erasmEvents removeObject:erasmEventSelected];

                NSLog(@"suppression de la notification");
                [erasmEventSelected deleteInBackground];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self.tableView reloadData];
                });
                
            } else if (buttonIndex == 2) {
                
                NSLog(@"button Refuse selected");
                NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
                PFObject * eventSelected = self.erasmEvents[selectedIndexPath.row];
                
                [self.erasmEvents removeObject:eventSelected];
                
                NSLog(@"suppression de la notification");
                [eventSelected deleteInBackground];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self.tableView reloadData];
                });
                
                
            } else if (buttonIndex == 3) {
                NSLog(@"button See on the map selected");
                [self performSegueWithIdentifier:@"See on the map" sender:self];
            }

        }
        
    } else if (alertView.tag == 104) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            NSLog(@"Alert view clicked with the cancel button index.");
        }
        
        else {
            NSLog(@"button take a look at the message clicked");
            NSLog(@"Alert view clicked with button at index %ld.", (long)buttonIndex);
            
            [self performSegueWithIdentifier:@"Show Message" sender:self];
            
            NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
            PFObject * messageSelected = self.messages[selectedIndexPath.row];
            [self.messages removeObject:messageSelected];
            
            NSLog(@"suppression de la notification");
            [messageSelected deleteInBackground];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
            });
    
        }
    }

}


 #pragma mark - Navigation
 

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"Show Profile"]) {
         profileSelectedTableViewController * pvc = segue.destinationViewController;
         
                 
        NSString * nameComplete = [NSString stringWithFormat:@"%@ %@", self.senderRequestSelected[@"FirstName"], self.senderRequestSelected[@"FamilyName"]];
        pvc.name = nameComplete;
        pvc.imageURL = self.senderRequestSelected[@"UrlProfilPicture"];
        pvc.gender = self.senderRequestSelected[@"Gender"];
        pvc.email = self.senderRequestSelected[@"Email"];
        pvc.erasmCity = self.senderRequestSelected[@"ErasmusCity"];
        pvc.erasmUni = self.senderRequestSelected[@"ErasmusUni"];
        pvc.homeCountry = self.senderRequestSelected[@"HomeCountry"];
        pvc.homeUni = self.senderRequestSelected[@"HomeUni"];
        pvc.nbFriends = self.senderRequestSelected[@"NbFriends"];
         
        //get the current year:
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy"];
        NSString *dateToday = [dateFormat stringFromDate:today];
        //get the year of birth of the person:
        NSString * yearOfBirth = self.senderRequestSelected[@"YearBirth"];
        NSLog(@"date of birth of %@: %@", nameComplete, yearOfBirth);
        //get the age:
        int todayYear = [dateToday intValue];
        int birthYear = [yearOfBirth intValue];
        int age = todayYear - birthYear;
        NSString * strAge = [NSString stringWithFormat:@"%d",age];
        //set the age parameter:
        pvc.age = strAge;
        NSLog(@"Age: %@", pvc.age);
     }
     else if ([segue.identifier isEqualToString:@"Show Message"]) {
         NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
         PFObject * userSelected = self.messages[selectedIndexPath.row];
         
         messageViewController * mvc = segue.destinationViewController;

         NSLog(@"perform segue in NotificationsTVC in Show Message");
         mvc.opponent = self.user;
         NSLog(@"self.user = %@", self.user);
         mvc.friends = userSelected[@"Friends"];

     }
     else if ([segue.identifier isEqualToString:@"See on the map"]) {
         EventsViewController * evc = segue.destinationViewController;
         evc.addressUserEvent = self.addressUserEvent;
         evc.descriptionEvent = self.descriptionUserEvent;
         evc.creatorEvent = self.creatorUserEvent;
         evc.typeEvent = self.typeEvent;
         if (self.linkWebsite != NULL) {
         evc.linkEvent = self.linkWebsite;
         }
     }
 }

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



@end
