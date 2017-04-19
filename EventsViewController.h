//
//  EventsViewController.h
//
//  Created by Ghita Tazi on 09/05/2014.
//  Copyright (c) 2014 Ghita Tazi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface EventsViewController : UIViewController<MKMapViewDelegate, QBChatDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)eventCreated:(UIStoryboardSegue*)segue;
@property (strong, nonatomic) NSString * streetName;
@property (strong, nonatomic) NSString * cityName;
@property (strong, nonatomic) NSString * stateName;
@property (strong, nonatomic) NSString * zipCode;
@property (strong, nonatomic) NSMutableArray *annotationsArray;

@property (strong, nonatomic) NSString * addressUserEvent;
@property (strong, nonatomic) NSString * descriptionEvent;
@property (strong, nonatomic) NSString * creatorEvent;
@property (strong, nonatomic) NSString * typeEvent;
@property (strong, nonatomic) NSString * linkEvent;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *createBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButton;

@property (strong, nonatomic) NSMutableArray *chatRoomsArray;

@end
