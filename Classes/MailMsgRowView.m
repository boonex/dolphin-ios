//
//  MailMsgRowView.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 10/27/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "MailMsgRowView.h"
#import "AsyncImageView.h"
#import "Designer.h"

@implementation MailMsgRowView


- (id)initWithNickname:(NSString*)aNick subject:(NSString*)aSubject date:(NSString*)aDate thumb:(NSString*)aThumb new:(BOOL)newFlag isInbox:(BOOL)inboxFlag selected:(BOOL)selectedFlag{
		
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"none"])) {
	
		int intMarginLeft = 74;
		
		UIView * v = [[UIView alloc] initWithFrame:CGRectZero];
		
		// title
		CGRect r = CGRectMake(intMarginLeft, 10, 220, 20);
		labelSubj = [[UILabel alloc] initWithFrame:r];
		labelSubj.text = aSubject;
		[Designer applyStylesForLabelTitle:labelSubj];
		[v addSubview:labelSubj];		
		
		// description
		r = CGRectMake(intMarginLeft, 38, 190, 11);
		labelNick = [[UILabel alloc] initWithFrame:r];
		if (inboxFlag)
			labelNick.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"From <User>", @"Display 'From: User' in mail messages list"), aNick];
		else
			labelNick.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"To <User>", @"Display 'To: User' in mail messages list"), aNick];
		[Designer applyStylesForLabelDesc:labelNick];
		[v addSubview:labelNick];

		// description
		r = CGRectMake(intMarginLeft, 58, 220, 11);
		labelDate = [[UILabel alloc] initWithFrame:r];
		labelDate.text = aDate;
		[Designer applyStylesForLabelDesc:labelDate];
		[v addSubview:labelDate];
		
		// NEW flag
		if (newFlag)
		{
			r = CGRectMake(200, 53, 50, 20); 
			labelNew = [[UILabel alloc] initWithFrame:r];
			labelNew.text = NSLocalizedString(@"New mail", @"New mail message marker");
			[Designer applyStylesForLabelNew:labelNew];
			[v addSubview:labelNew];
		}
		else
		{
			labelNew = nil;
		}
		
		// thumbnail
		NSURL *urlThumb = [NSURL URLWithString:aThumb];
		AsyncImageView *thumb = [[AsyncImageView alloc] initWithFrame:CGRectMake (5, 10, 64, 64)];
		thumb.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
		[thumb loadImageFromURL:urlThumb];
		[v addSubview:thumb];
		[thumb release];

		[self.contentView addSubview:v];
		[v release];
		
		[Designer applyStylesForCell:self];
	}
	return self;
}

- (void)dealloc {
	[labelNick release];
	[labelSubj release];
	[labelDate release];
	[labelNew release];
	[super dealloc];
}

@end
