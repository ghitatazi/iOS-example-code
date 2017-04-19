//
//  EventsViewController.m
//
//  Created by Ghita Tazi on 09/05/2014.
//  Copyright (c) 2014 Ghita Tazi. All rights reserved.
//

#import "EventsViewController.h"
#import "Annotations.h"
#import "EditUserEvents.h"
#import <Parse/Parse.h>
#import "WebViewController.h"
#import "ShowUserEventSheetTableViewController.h"
#import "ChatService.h"

@interface EventsViewController () <QBChatDelegate>
@property (nonatomic, strong) PFObject * currentUserConnected;
@property (copy) QBChatRoom * joinRoomCompletionBlock;
@end

@implementation EventsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _mapView.delegate = self;
    
    NSLog(@"self.addressUserEvent: %@", self.addressUserEvent);
    
    if (self.addressUserEvent == NULL) {

    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(NextEvent:)];
    [self.mapView addGestureRecognizer:press];

    self.title = @"Events of today";
        
    PFUser * currentUser = [PFUser currentUser];
    PFQuery *query1 = [PFQuery queryWithClassName:@"Users"];
    [query1 whereKey:@"Email" equalTo:currentUser.username];
    [query1 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved the user: %@", object[@"Email"]);
            self.currentUserConnected = object;
            NSString * cityName = object[@"ErasmusCity"];
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:cityName completionHandler:^(NSArray *placemarks, NSError *error)
             {
                 if (error)
                 {
                     NSLog(@"Geocode failed with error: %@", error);
                     return;
                 }
                 CLPlacemark *placemark = [placemarks firstObject];
                 CLLocationCoordinate2D coordinate = placemark.location.coordinate;
                 [self.mapView setCenterCoordinate:coordinate animated:NO];
                 MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (coordinate, 20000, 20000);
                 [self.mapView setRegion:region animated:NO];
             }];
            
                } else {
                    // Log details of the failure
                    NSLog(@"Error");
                }
            }];
    
    
    //montrer la zone ou se trouve l'utilisateur, ne marche que quand iphone branché:
    //self.mapView.showsUserLocation = YES;
    
    self.annotationsArray = [[NSMutableArray alloc]init];
    
    NSDate * dateofToday = [[NSDate alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString* fechaDeHoy = [dateFormat stringFromDate:dateofToday];
    NSLog(@"%@", fechaDeHoy);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"Day" equalTo:fechaDeHoy];
    [query whereKey:@"Guests" containsAllObjectsInArray:@[currentUser.username]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d events.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                [geocoder geocodeAddressString:object[@"Adress"] completionHandler:^(NSArray *placemarks, NSError *error)
                 {
                     if (error)
                     {
                         NSLog(@"Geocode failed with error: %@", error);
                         return;
                     }
                     CLPlacemark *placemark = [placemarks firstObject];
                     CLLocationCoordinate2D coordinate = placemark.location.coordinate;
                     
                     Annotations *temp = [[Annotations alloc]init];
                     
                     if ([object[@"TypeOfEvent"] isEqualToString:@"userEvent"]) {
                     [temp setTitle:object[@"Description"]];
                     [temp setSubtitle:object[@"Creator"]];
                     [temp setCoordinate:coordinate];
                     [self.annotationsArray addObject:temp];
                     NSArray * annotations = self.annotationsArray;
                     [self.mapView addAnnotations:annotations];
                     NSLog(@"type de l'objet '%@': %@",object[@"Description"], object[@"TypeOfEvent"]);
                     
                     } else if ([object[@"TypeOfEvent"] isEqualToString:@"erasmusEvent"]) {
                         [temp setTitle:object[@"Description"]];
                         [temp setSubtitle:object[@"LinkToWebsite"]]; //le lien une fois cliqué doit pouvoir renvoyer directement a la page!!!
                         [temp setCoordinate:coordinate];
                         [self.annotationsArray addObject:temp];
                         NSArray * annotations = self.annotationsArray;
                         [self.mapView addAnnotations:annotations];
                         NSLog(@"type de l'objet '%@': %@",object[@"Description"], object[@"TypeOfEvent"]);
                     }
                 }];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error");
        }
    }];
    }
    
    else {

        self.navigationItem.leftBarButtonItem = nil;
        self.refreshBarButton.enabled = NO;
        
        NSLog(@"self.addressUserEvent: %@", self.addressUserEvent);
        NSLog(@"self.descriptionEvent: %@", self.descriptionEvent);
        NSLog(@"self.creatorEvent: %@", self.creatorEvent);
        NSLog(@"self.typeEvent: %@", self.typeEvent);
        NSLog(@"link website: %@", self.linkEvent);
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:self.addressUserEvent completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (error)
             {
                 NSLog(@"Geocode failed with error: %@", error);
                 return;
             }
             
             CLPlacemark *placemark = [placemarks firstObject];
             CLLocationCoordinate2D coordinate = placemark.location.coordinate;
             [self.mapView setCenterCoordinate:coordinate animated:NO];
             MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (coordinate, 2000, 2000);
             [self.mapView setRegion:region animated:NO];
             
             //création de l'annotation:
             if ([self.typeEvent isEqualToString:@"userEvent"]) {
                 Annotations *temp = [[Annotations alloc]init];
                 [temp setTitle:self.descriptionEvent];
                 [temp setSubtitle:self.creatorEvent];
                 [temp setCoordinate:coordinate];
                 NSArray * annotations = [[NSArray alloc] init];
                 annotations = @[temp];
                 [self.mapView addAnnotations:annotations];
                 
             } else if ([self.typeEvent isEqualToString:@"erasmusEvent"]) {
                 Annotations *temp = [[Annotations alloc]init];
                 [temp setTitle:self.descriptionEvent];
                 [temp setSubtitle:self.linkEvent];
                 [temp setCoordinate:coordinate];
                 NSArray * annotations = [[NSArray alloc] init];
                 annotations = @[temp];
                 [self.mapView addAnnotations:annotations];

             }
         }];
        }
}

- (void) NextEvent:(UILongPressGestureRecognizer *)sender {
    
    CGPoint pos = [sender locationInView:sender.view];
    NSLog(@" pos.x= %f, pos.y= %f", pos.x, pos.y);
    [self.mapView removeAnnotations:self.annotationsArray];
    
    self.title = @"Events of Tomorrow";
    PFUser * currentUser = [PFUser currentUser];
    PFQuery *query1 = [PFQuery queryWithClassName:@"Users"];
    [query1 whereKey:@"Email" equalTo:currentUser.username];
    [query1 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved the user: %@", object[@"Email"]);
            self.currentUserConnected = object;
            NSString * cityName = object[@"ErasmusCity"];
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:cityName completionHandler:^(NSArray *placemarks, NSError *error)
             {
                 if (error)
                 {
                     NSLog(@"Geocode failed with error: %@", error);
                     return;
                 }
                 CLPlacemark *placemark = [placemarks firstObject];
                 CLLocationCoordinate2D coordinate = placemark.location.coordinate;
                 [self.mapView setCenterCoordinate:coordinate animated:NO];
                 MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (coordinate, 20000, 20000);
                 [self.mapView setRegion:region animated:NO];
             }];
            
        } else {
            // Log details of the failure
            NSLog(@"Error");
        }
    }];
    
    NSDate * dateofToday = [[NSDate alloc] init];
    NSDate *tomorrow = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:dateofToday];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString* fechaDeManana = [dateFormat stringFromDate:tomorrow];
    
    NSLog(@"%@", fechaDeManana);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"Day" equalTo:fechaDeManana];
    [query whereKey:@"Guests" containsAllObjectsInArray:@[currentUser.username]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d events.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                [geocoder geocodeAddressString:object[@"Adress"] completionHandler:^(NSArray *placemarks, NSError *error)
                 {
                     if (error)
                     {
                         NSLog(@"Geocode failed with error: %@", error);
                         return;
                     }
                     CLPlacemark *placemark = [placemarks firstObject];
                     CLLocationCoordinate2D coordinate = placemark.location.coordinate;
                     
                     
                     Annotations *temp = [[Annotations alloc]init];
                     
                     if ([object[@"TypeOfEvent"] isEqualToString:@"userEvent"]) {
                         [temp setTitle:object[@"Description"]];
                         [temp setSubtitle:object[@"Creator"]];
                         [temp setCoordinate:coordinate];
                         [self.mapView addAnnotation:temp];
                         NSLog(@"type de l'objet '%@': %@",object[@"Description"], object[@"TypeOfEvent"]);
                         
                     } else if ([object[@"TypeOfEvent"] isEqualToString:@"erasmusEvent"]) {
                         [temp setTitle:object[@"Description"]];
                         [temp setSubtitle:object[@"LinkToWebsite"]]; //le lien une fois cliqué doit pouvoir renvoyer directement a la page!!!
                         [temp setCoordinate:coordinate];
                         [self.mapView addAnnotation:temp];
                         NSLog(@"type de l'objet '%@': %@",object[@"Description"], object[@"TypeOfEvent"]);
                     }
                     
                 }];
            }
        }
     }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//fonction suivante sert à actualiser la position de l'utilisateur quand il se déplace:
- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:
(MKUserLocation *)userLocation
{
    _mapView.centerCoordinate =
    userLocation.location.coordinate;
}

//change the pin colors+créer les boutons infos sur events:
- (MKAnnotationView *) mapView:(MKMapView *)mapView
             viewForAnnotation:(id <MKAnnotation>) annotation {
    
    static NSString* MyAnnotationIdentifier = @"MyAnnotationIdentifier";
    MKPinAnnotationView* customPinView = [[MKPinAnnotationView alloc]
                                          initWithAnnotation:annotation reuseIdentifier:MyAnnotationIdentifier];
    
    if([[annotation subtitle] hasPrefix:@"http"]) {
        customPinView.pinColor = MKPinAnnotationColorGreen;
        
        UIButton *advertButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        advertButton.frame = CGRectMake(0, 0, 23, 23);
        advertButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        advertButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

        [advertButton addTarget:self action:@selector(showLinks:) forControlEvents:UIControlEventTouchUpInside];
        
        customPinView.rightCalloutAccessoryView = advertButton;
        customPinView.animatesDrop=TRUE;
        customPinView.canShowCallout = YES;
        customPinView.calloutOffset = CGPointMake(-5, 5);
       
    } else {
        customPinView.pinColor = MKPinAnnotationColorRed;
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        customPinView.rightCalloutAccessoryView = rightButton;
        
        rightButton.frame = CGRectMake(0, 0, 23, 23);
        rightButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

        [rightButton addTarget:self action:@selector(showEventDetails:) forControlEvents:UIControlEventTouchUpInside];
    }
    return customPinView;
}

-(void)showLinks:(UIButton*)sender  {
    NSLog(@"bouton info erasmusEvent selected");
    [self performSegueWithIdentifier:@"Show Web Infos" sender:self];
}

- (void)showEventDetails:(UIButton*)sender {
    NSLog(@"bouton info userEvent selected");
    [self performSegueWithIdentifier:@"Show Event Details" sender:self];
}

- (IBAction)eventCreated:(UIStoryboardSegue*)segue
{
    EditUserEvents *evc = segue.sourceViewController;

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm"]; //24hr time format
    NSString *hour = [outputFormatter stringFromDate:evc.datePickerEvent.date];
    NSLog(@"Hour: %@", hour);

    NSDate * dateofToday = [[NSDate alloc] init];
    NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc]init];
    [dateFormat1 setDateFormat:@"yyyy-MM-dd"];
    NSString* fechaDeHoy = [dateFormat1 stringFromDate:dateofToday];
    NSLog(@"%@", fechaDeHoy);

    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc]init];
    [dateFormat2 setDateFormat:@"yyyy-MM-dd"];
    NSString* fecha = [dateFormat2 stringFromDate:evc.datePickerEvent.date];
    NSLog(@"fecha: %@", fecha);
    
    PFUser * currentUser = [PFUser currentUser];
    PFObject * event = [PFObject objectWithClassName:@"Events"];
    [event setObject:evc.descriptionEventTF.text forKey:@"Description"];
    [event setObject:evc.adressLabel.text forKey:@"Adress"];
    [event setObject:fecha forKey:@"Day"];
    [event setObject:hour forKey:@"Hour"];
    [event setObject:@"userEvent" forKey:@"TypeOfEvent"];
    [event setObject:@"no link" forKey:@"LinkToWebsite"];
    
    [evc.emailsGuests addObject:currentUser.username];
    NSArray * guests = (NSArray*)evc.emailsGuests;
    
    [event setObject:guests forKey:@"Guests"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    [query whereKey:@"Email" equalTo:currentUser.username];
    PFObject * user = [query getFirstObject];
    NSString * userNameEvent = [NSString stringWithFormat:@"%@ %@", user[@"FirstName"], user[@"FamilyName"]];
    [event setObject:userNameEvent forKey:@"Creator"];
    [event setObject:@1 forKey:@"NbParticipants"];
    [event saveInBackgroundWithBlock:^(BOOL succeded, NSError *error)
     {
         if (!error) {
             NSLog(@"No error saving event");
         } else {
             NSLog(@"error saving user");
         }
     }];

    if ([fecha isEqualToString:fechaDeHoy]) {
    NSLog(@"Street value: %@", evc.street);
    [evc.placeDictionary setValue:evc.street forKey:@"Street"];
    [evc.placeDictionary setValue:evc.city forKey:@"City"];
    [evc.placeDictionary setValue:evc.state forKey:@"State"];
    [evc.placeDictionary setValue:evc.zip forKey:@"ZIP"];
    NSLog(@"end prepare for segue");
    NSLog(@"%@", evc.placeDictionary[[[evc.placeDictionary allKeys] objectAtIndex:0]]);
    NSLog(@"%@", evc.placeDictionary[[[evc.placeDictionary allKeys] objectAtIndex:1]]);
    NSLog(@"%@", evc.placeDictionary[[[evc.placeDictionary allKeys] objectAtIndex:2]]);
    NSLog(@"%@", evc.placeDictionary[[[evc.placeDictionary allKeys] objectAtIndex:3]]);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressDictionary:evc.placeDictionary completionHandler:^(NSArray *placemarks, NSError *error) {
        if([placemarks count]) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"placemark done");
            CLLocation *location = placemark.location;
            NSLog(@"location done");
            CLLocationCoordinate2D coordinate = location.coordinate;
            NSLog(@"coordinate done");
            [self.mapView setCenterCoordinate:coordinate animated:YES];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (coordinate, 20000, 20000);
            [self.mapView setRegion:region animated:NO];

            PFQuery *query = [PFQuery queryWithClassName:@"Events"];
            [query whereKey:@"Hour" equalTo:hour];
            [query whereKey:@"Creator" equalTo:userNameEvent];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (!error) {
                    NSLog(@"Successfully retrieved the event from: %@, created at: %@", object[@"Creator"], object[@"Hour"]);
                    Annotations *temp = [[Annotations alloc]init];
                    [temp setTitle:object[@"Description"]];
                    [temp setSubtitle:object[@"Creator"]];
                    [temp setCoordinate:coordinate];
                    [self.annotationsArray addObject:temp];
                    NSLog(@"new annotation added to the annotationsArray");
                    NSArray * annotations = self.annotationsArray;
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [self.mapView addAnnotations:annotations];
                    });
                    
                } else {
                    NSLog(@"Error");
                }
            }];
        } else {
            NSLog(@"error");
        }
    }];
    }
    
    if ([evc.emailsGuests count] > 0) {
        
        for (NSString * email in evc.emailsGuests) {
            
            NSLog(@"email: %@", email);

            PFUser * currentUser = [PFUser currentUser];

            if ([email isEqualToString:currentUser.username]) {
                //ne rien faire
            } else {
            PFObject * notification = [PFObject objectWithClassName:@"Notifications"];
            
            [notification setObject:currentUser.username forKey:@"SentFrom"];
            [notification setObject:email forKey:@"SentTo"];
            [notification setObject:@"userEvent" forKey:@"TypeOfNotif"];
            
            NSDate * date = [[NSDate alloc] init];
            NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
            [outputFormatter setDateFormat:@"HH:mm"]; //24hr time format
            NSString *hour = [outputFormatter stringFromDate:date];
            NSLog(@"Hour request sent: %@", hour);
            
            [notification setObject:hour forKey:@"Hour"];
            
            NSString * message = [NSString stringWithFormat:@"%@ %@ invites you", self.currentUserConnected[@"FirstName"], self.currentUserConnected[@"FamilyName"]];
            [notification setObject:message forKey:@"MessageDisplayed"];
            [notification setObject:@"YES" forKey:@"Friends"];
            [notification setObject:evc.descriptionEventTF.text forKey:@"descriptionEvent"];
            [notification saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
                if (!error) {
                    NSLog(@"No error saving notification of event");
                } else {
                    NSLog(@"Error saving notification of event");
                }
            }];
            }
        }
    }
    
    NSString *chatRoomName= [NSString stringWithFormat:@"%@",evc.descriptionEventTF.text];
    
    NSString * userName = [NSString stringWithFormat:@"%@%@", self.currentUserConnected[@"FirstName"], self.currentUserConnected[@"FamilyName"]];
    
    [[QBChat instance] createOrJoinRoomWithName:chatRoomName nickname:userName membersOnly:NO persistent:YES];

}

#pragma mark -
#pragma mark QBChatDelegate

- (void) chatRoomDidEnter:(QBChatRoom*) room {
    NSLog(@"Private room %@ created", room.name);
    
    [[ChatService instance] joinRoom:room completionBlock:^(QBChatRoom *joinedChatRoom) {
        NSString * emailAmandine = @"amandine@france.fr";
        [joinedChatRoom addUsers:@[emailAmandine]];
    }];

}

- (IBAction)refreshMap:(UIBarButtonItem *)sender {
    [self viewDidLoad];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Show Web Infos"]) {

        WebViewController * wvc = [segue destinationViewController];
        id<MKAnnotation> annotationSelected = [[self.mapView selectedAnnotations] objectAtIndex:0];
        wvc.annotationSub = annotationSelected.subtitle;
        NSLog(@"website link: %@", wvc.annotationSub);
    }
    if ([[segue identifier] isEqualToString:@"Show Event Details"]) {
        ShowUserEventSheetTableViewController * svc = [segue destinationViewController];
        id<MKAnnotation> annotationSelected = [[self.mapView selectedAnnotations] objectAtIndex:0];
        svc.creator = annotationSelected.subtitle;
        svc.description = annotationSelected.title;
    }
}


@end
