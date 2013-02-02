//
//  DolphinUsers.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/6/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BxUser;

@interface DolphinUsers : NSObject {
	NSMutableArray *usersList;
	NSString *currentDirectoryPath;
}

@property (nonatomic, retain) NSMutableArray *usersList;
@property (nonatomic, copy) NSString *currentDirectoryPath;

+ (DolphinUsers *)sharedDolphinUsers;

- (void)loadUsers;
- (void)saveUsers;

- (NSUInteger)countOfUsers;
- (BxUser*)userAtIndex:(NSUInteger)theIndex;
- (BxUser*)addUser:(BxUser*)anUser;
- (void)removeUserAtIndex:(NSUInteger)theIndex;

@end