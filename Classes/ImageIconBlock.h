//
//  ProfileIconBlock.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ImageIconBlock : UITableViewCell {
	AsyncImageView *icon;
	UILabel *title;
	UILabel *desc;
	UIView *rate;
	UIView *rateSubview;
    UIView *viewContainer;
    float rateValue;
	id data;
}

@property (nonatomic, retain) id data;

+ (NSInteger)getHeight;

- (id)initWithData:(id)aData reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setTitle:(NSString*)aTitle iconUrl:(NSString *)anIcon desc:(NSString*)aDesc rate:(NSString*)aRate;
- (void)addRateSubview;

@end
