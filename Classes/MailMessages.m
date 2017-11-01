//
//  DolphinUsers.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/6/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "MailMessages.h"
#import "Msg.h"
#import "User.h"
#import "Connector.h"

static MailMessages *sharedMailMessages = nil;

@implementation MailMessages

@synthesize msgsList, user, initialized;

- (void)dealloc {
	[msgsList release];
	[user release];
	sharedMailMessages = nil;
	[super dealloc];
}

+ (id)alloc {
	NSAssert(sharedMailMessages == nil, @"Attempted to allocate a second instance of a singleton.");
	sharedMailMessages = [super alloc];
	return sharedMailMessages;	
}

+ (MailMessages *)sharedMailMessages:(BxUser*)aUser {
	
	if (nil == sharedMailMessages) {
		sharedMailMessages = [[MailMessages alloc] initWithUserObject:aUser];
	}
	
	return sharedMailMessages;
}

- (id)initWithUserObject:(BxUser*)aUser {
	if ((self = [super init])) {
		self.user = aUser; // retain;
		initialized = NO;
	}
	return self;
}

- (void) resetData {
	self.msgsList = nil;
	initialized = NO;
}

- (void)setMessagesArray:(NSMutableArray*)anArray {
	self.msgsList = anArray; // retain
	NSLog(@"Number of messages: %d", (int)[msgsList count]);
	initialized = YES;
}

/**********************************************************************************************************************
 GET & SET DATA FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Get & Set Data Functions

- (NSUInteger)countOfMessages {
	return [msgsList count];
}

- (NSMutableDictionary *) msgAtIndex:(NSUInteger)theIndex {
	return [msgsList objectAtIndex:theIndex];
}

- (BxMsg*)add:(BxMsg*)aMsg {
	[msgsList addObject:aMsg];
	return aMsg;
}

- (void)removeMsgAtIndex:(NSUInteger)theIndex {
	[msgsList removeObjectAtIndex:theIndex];
}

@end
