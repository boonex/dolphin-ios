//
//  User.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/21/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Connector.h"
#import "AsyncImageView.h"

@interface BxUser : NSObject {
	NSString *strSite;
	NSString *strUsername;
	NSString *strPwdHash;
    NSInteger intProtocolVer;
	NSInteger intId;
	NSInteger numUnreadLetters;
	NSInteger numFriendRequests;	
	BxConnector *connector;	
	AsyncImageView *iconSite;
	UITableViewCell *cell;
	BOOL rememberPassword;
}

@property (nonatomic, retain) UITableViewCell *cell;
@property (nonatomic, retain) AsyncImageView *iconSite;
@property (nonatomic, copy) NSString *strSite;
@property (nonatomic, copy) NSString *strUsername;
@property (nonatomic, copy) NSString *strPwdHash;
@property (assign) NSInteger intId;
@property (assign, readonly) NSInteger numUnreadLetters;
@property (assign, readonly) NSInteger numFriendRequests;
@property (nonatomic, retain) BxConnector *connector;
@property (nonatomic, assign) BOOL rememberPassword;
@property (assign) NSInteger intProtocolVer;

- (void)setUnreadLettersNum:(NSInteger)aNum;
- (void)setFriendRequestsNum:(NSInteger)aNum;

- (void)decUnreadLettersNum;
- (void)decFriendRequestsNum;

- (id)initWithUser:(NSString*)anUsername id:(NSInteger)anId passwordHash:(NSString*)aHash site:(NSString*)aSite protocolVer:(NSInteger)aProtocolVer;
- (void)setUser:(NSString*)anUsername id:(NSInteger)anId passwordHash:(NSString*)aHash site:(NSString*)aSite protocolVer:(NSInteger)aProtocolVer;

- (void)setLoggenInCookiesForRequest:(NSMutableURLRequest*)request;

@end
