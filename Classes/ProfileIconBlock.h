//
//  ProfileIconBlock.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ProfileIconBlock : UITableViewCell {
	AsyncImageView *icon;
	UILabel *title;
	UILabel *info;
	UILabel *location;
	id data;
}

@property (nonatomic, retain) id data;

+ (NSInteger)getHeight;

- (id)initWithData:(id)aData reuseIdentifier:(NSString *)reuseIdentifier;

- (void) setProfile:(NSString*)aUsername title:(NSString*)aUserTitle iconUrl:(NSString *)anIcon info:(NSString*)anInfo location:(NSString*)aLocation;
- (void) setFriendRequestControlsTarget:(id)aTarget selectorAccept:(SEL)aSelectorAccept selectorDecline:(SEL)aSelectorDecline;
- (void) setLoadingText;

@end
