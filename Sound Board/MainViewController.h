//
//  MainViewController.h
//  Sound Board
//
//  Created by Daniel Cervantes on 3/30/13.
//  Copyright (c) 2013 ima. All rights reserved.
//

#import "FlipsideViewController.h"

#import <CoreData/CoreData.h>

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
