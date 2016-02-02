//
//  ProfileIconBlock.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProfileInfoBlock : UITableViewCell {
	NSString *caption;
	NSArray *info;
	id data;
    CGFloat fHeightSum;
}

@property (nonatomic, retain) id data;

- (id)initWithCaption:(NSString*)aCaption info:(NSArray*)anInfo data:(id)aData table:(UITableView *)tableView;
- (CGFloat)calcHeight;

@end
