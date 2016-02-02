//
//  MailMsgRowView.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 10/27/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailMsgRowView : UITableViewCell {
	UILabel *labelNick;
	UILabel *labelSubj;
	UILabel *labelDate;	
	UILabel *labelNew;	
}

- (id)initWithNickname:(NSString*)aNick subject:(NSString*)aSubject date:(NSString*)aDate thumb:(NSString*)aThumb new:(BOOL)newFlag isInbox:(BOOL)inboxFlag selected:(BOOL)selectedFlag;

@end
