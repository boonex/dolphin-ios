//
//  ProfileIconBlock.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "ProfileIconBlock.h"
#import "DataButton.h"
#import "Designer.h"
#import "config.h"

//#define BX_BUTTONS_OFFSET_X_IPAD 35.0

@implementation ProfileIconBlock

@synthesize data;

- (id)initWithData:(id)aData reuseIdentifier:(NSString *)reuseIdentifier {
	
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
			
		self.data = aData; // retain
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		UIView * v = [[UIView alloc] initWithFrame:CGRectZero];
		
		// thumb
		CGRect r = CGRectMake(5, 10, 64, 64);
		icon = [[AsyncImageView alloc] initWithFrame:r]; 
		icon.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
		[v addSubview:icon];
		
		// title
		r = CGRectMake(74, 10, 220, 20);
		title = [[UILabel alloc] initWithFrame:r];		
		[Designer applyStylesForLabelTitle:title];		
		[v addSubview:title];
		
		// desc
		r = CGRectMake(74, 31, 190, 20);
		info = [[UILabel alloc] initWithFrame:r];
		[Designer applyStylesForLabelDesc:info];
		[v addSubview:info];

		// desc
		r = CGRectMake(74, 52, 220, 20);
		location = [[UILabel alloc] initWithFrame:r];
		[Designer applyStylesForLabelDesc:location];
		[v addSubview:location];
		
		[self.contentView addSubview:v];
		[v release];
		
		[self setLoadingText];
		
		[Designer applyStylesForCell:self];
	}
	
	return self;
}

- (void)dealloc {
	[data release];
	[icon release];
	[title release];
	[info release];
	[location release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setLoadingText {
	title.text = NSLocalizedString(@"Loading...", @"Loading text");	
}
	
- (void) setProfile:(NSString*)aUsername title:(NSString*)aUserTitle iconUrl:(NSString *)anIcon info:(NSString*)anInfo location:(NSString*)aLocation {
	
	if (nil == anIcon || [anIcon isEqualToString:@""])	{
		
	} else {
		
		NSURL *url = [[NSURL alloc] initWithString:anIcon];		
		[icon loadImageFromURL:url];
	}
	
	title.text = aUserTitle;
	info.text = anInfo;
	location.text = aLocation;
}

- (void)setFriendRequestControlsTarget:(id)aTarget selectorAccept:(SEL)aSelectorAccept selectorDecline:(SEL)aSelectorDecline {
		
    // self.contentView.frame.origin.x
    
	CGRect r = CGRectMake(170, 32, 90, 28);
	DataButton *btn = [[DataButton alloc] initWithFrame:r]; //[DataButton buttonWithType:UIButtonTypeRoundedRect];
	[btn setButtonData:self];
	[btn setTitle:NSLocalizedString(@"Accept Invitation", @"Accept friend invitation button title") forState:UIControlStateNormal];
	[btn addTarget:aTarget action:aSelectorAccept forControlEvents:UIControlEventTouchUpInside];
	btn.backgroundColor = [UIColor colorWithRed:0 green:0.7 blue:0 alpha:1];
	[self.contentView addSubview:btn];
	[btn release];

	CGRect r2 = CGRectMake(75, 32, 90, 28);
	DataButton *btn2 = [[DataButton alloc] initWithFrame:r2]; //[DataButton buttonWithType:UIButtonTypeRoundedRect];
	[btn2 setButtonData:self];
	[btn2 setTitle:NSLocalizedString(@"Decline Invitation", @"Decline friend invitation button title") forState:UIControlStateNormal];
	[btn2 addTarget:aTarget action:aSelectorDecline forControlEvents:UIControlEventTouchUpInside];
	btn2.backgroundColor = [UIColor colorWithRed:0.7 green:0 blue:0 alpha:1];
	[self.contentView addSubview:btn2];
	[btn2 release];
	
	[location removeFromSuperview];
	[info removeFromSuperview];
}

+ (NSInteger)getHeight {
	return BX_TABLE_CELL_HEIGHT_THUMB; 
}

@end
