//
//  DolphinUsers.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/6/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "config.h"
#import "DolphinUsers.h"
#import "User.h"

static DolphinUsers *sharedDolphinUsers;

@implementation DolphinUsers

@synthesize usersList, currentDirectoryPath;

- (void)dealloc {
	[usersList release];
	[currentDirectoryPath release];
	[super dealloc];
}

+(id)alloc {
	NSAssert(sharedDolphinUsers == nil, @"Attempted to allocate a second instance of a singleton.");
	sharedDolphinUsers = [super alloc];
	return sharedDolphinUsers;	
}

+ (DolphinUsers *)sharedDolphinUsers {
	
	if (!sharedDolphinUsers)
		sharedDolphinUsers = [[DolphinUsers alloc] init];
	
	return sharedDolphinUsers;
}

+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized) {
		// Load previously saved data
		[[DolphinUsers sharedDolphinUsers] loadUsers];
		
        initialized = YES;
    }
}

- (id)init
{
	if ((self = [super init]))
	{
		// Set current directory 
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		currentDirectoryPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"dolphin"] retain];
		
		BOOL isDir;
		if (![fileManager fileExistsAtPath:currentDirectoryPath isDirectory:&isDir] || !isDir) {
            [fileManager createDirectoryAtPath:currentDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
		}

		[fileManager changeCurrentDirectoryPath:currentDirectoryPath];
		NSLog(@"current directory is set to : %@", [fileManager currentDirectoryPath]);		
	}
	return self;
}

/**********************************************************************************************************************
 LOAD & SAVE FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Load & Save Functions

-(void)loadUsers {
	
	// look for file with data in currrent dir
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *filePath = [currentDirectoryPath stringByAppendingPathComponent:@"dolphin.users"];

	if ([fileManager fileExistsAtPath:filePath]) {
		NSMutableArray *arr = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
		[self setUsersList:arr];
	} else {
		NSMutableArray * arr = [NSMutableArray array];
		[self setUsersList:arr];
		[self saveUsers];
	}
	
	if (0 == [self countOfUsers] && nil != BX_LOCK_APP) {
        BxUser *aUser = [[BxUser alloc] initWithUser:@"" id:0 passwordHash:@"" site:BX_LOCK_APP protocolVer:2];
		[self addUser:aUser];
		[self saveUsers];
	}        
    
	NSLog(@"Number of users at launch: %d", [usersList count]);
}

- (void)saveUsers {
	
	NSString *filePath = [currentDirectoryPath stringByAppendingPathComponent:@"dolphin.users"];
	
	// check if file exists before saving
	if ([usersList count] || ([[NSFileManager defaultManager] fileExistsAtPath:filePath])) {
		
		NSLog(@"Saving %d users in list.", [usersList count]);
		[NSKeyedArchiver archiveRootObject:usersList toFile:filePath];	
		
	} else {
        
		NSLog(@"No users in list. there is nothing to save!");
        
	}
}

/**********************************************************************************************************************
 GET & SET DATA FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Get & Set Data Functions

- (NSUInteger)countOfUsers {
	return [usersList count];
}

- (BxUser*)userAtIndex:(NSUInteger)theIndex {
	return [usersList objectAtIndex:theIndex];
}

- (BxUser*)addUser:(BxUser*)anUser {
	[usersList addObject:anUser];
	return anUser;
}

- (void)removeUserAtIndex:(NSUInteger)theIndex {
	[usersList removeObjectAtIndex:theIndex];
}

@end
