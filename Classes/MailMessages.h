//
//  DolphinUsers.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/6/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BxMsg, BxUser, BxConnector;

@interface MailMessages : NSObject {
	BxUser *user;
	NSMutableArray *msgsList;
	BOOL initialized;
}

@property (nonatomic, retain) NSMutableArray *msgsList;
@property (nonatomic, retain) BxUser *user;
@property (nonatomic, assign) BOOL initialized;

- (id)initWithUserObject:(BxUser*)aUser;

- (void) resetData;

+ (MailMessages *)sharedMailMessages:(BxUser*)user;

- (void)setMessagesArray:(NSMutableArray*)anArray;

- (NSUInteger) countOfMessages;
- (NSMutableDictionary *) msgAtIndex:(NSUInteger)theIndex;
- (void) removeMsgAtIndex:(NSUInteger)theIndex;

@end