//
//  SBSound.h
//  Sound Board
//
//  Created by Daniel Cervantes on 3/30/13.
//  Copyright (c) 2013 ima. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SBSound : NSManagedObject

@property (nonatomic, retain) NSString * command;
@property (nonatomic, retain) NSString * title;

@end
