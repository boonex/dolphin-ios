//
//  ProfileIconBlock.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "ImageIconBlock.h"
#import "DataButton.h"
#import "Designer.h"
#import "config.h"

@implementation ImageIconBlock

@synthesize data;

- (id)initWithData:(id)aData reuseIdentifier:(NSString *)reuseIdentifier {
	
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
			
		self.data = aData; // retain
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		viewContainer = [[UIView alloc] initWithFrame:CGRectZero];
        
		// thumbnail
		CGRect r = CGRectMake(5, 10, 64, 64);
		icon = [[AsyncImageView alloc] initWithFrame:r];
		icon.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
		[viewContainer addSubview:icon];
		
		// title
		r = CGRectMake(74, 10, 220, 20);
		title = [[UILabel alloc] initWithFrame:r];
		[Designer applyStylesForLabelTitle:title];
		[viewContainer addSubview:title];
		
		// description
		r = CGRectMake(74, 38, 190, 11);
		desc = [[UILabel alloc] initWithFrame:r];
		[Designer applyStylesForLabelDesc:desc];
		[viewContainer addSubview:desc];
		
		// rating
        [self addRateSubview];		
        
		[self.contentView addSubview:viewContainer];
		[viewContainer release];
		
		[Designer applyStylesForCell:self];
	}
	
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    NSLog(@"setSelected: %d", selected);
	[super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
    if (NO == highlighted)
        [self addRateSubview];
}

- (void)dealloc {
	[data release];
	[icon release];
	[title release];
	[desc release];
	[rate release];
    [rateSubview release];
    [viewContainer release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)addRateSubview {
    
    if (rate != nil && rateSubview != nil) {
        [rate removeFromSuperview];
        [rateSubview removeFromSuperview];    
        [rate release];
        [rateSubview release];
    }
    
    CGRect r = CGRectMake(0.0, 0.0, rateValue*11.0, 11.0);
    rateSubview = [[UILabel alloc] initWithFrame:r];		
    rateSubview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"vote_star_active_16.png"]];
    [rateSubview setOpaque:NO];
    
    r = CGRectMake(74.0, 58.0, 55.0, 11.0);
    rate = [[UILabel alloc] initWithFrame:r];
    rate.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"vote_star_gray_16.png"]];
    [rate setOpaque:NO];
    [rate addSubview:rateSubview];
    
    [viewContainer addSubview:rate];    
}

- (void)setVote:(NSString*)vote {
	rateValue = [vote floatValue];
    CGRect r = CGRectMake(0, 0, rateValue*11.0, 11);
	NSArray *a = rate.subviews;
	UIView *v = [a objectAtIndex:0];
	v.frame = r;

}
    
- (void) setTitle:(NSString*)aTitle iconUrl:(NSString *)anIcon desc:(NSString*)aDesc  rate:(NSString*)aRate {
	
	if (nil == anIcon || [anIcon isEqualToString:@""])	{
		
		
	} else {
		
		NSURL *url = [[NSURL alloc] initWithString:anIcon];
		[icon loadImageFromURL:url];
	}
	
	title.text = aTitle;
	desc.text = aDesc;
	[self setVote:aRate];
}

+ (NSInteger)getHeight {
	return BX_TABLE_CELL_HEIGHT_THUMB; 
}

@end
