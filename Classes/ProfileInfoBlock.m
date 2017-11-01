//
//  ProfileIconBlock.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "config.h"
#import "ProfileInfoBlock.h"
#import "Designer.h"

#define BX_PROFILE_INFO_CAPTION_HEIGHT 30.0
#define BX_PROFILE_INFO_LINE_HEIGHT 20.0
#define BX_PROFILE_INFO_MAX_AREA_HEIGHT 300.0
#define BX_PROFILE_INFO_D 5.0

#define BX_PROFILE_INFO_WIDTH_CORRECTION (-30.0)
#define BX_PROFILE_INFO_X 15.0
#define BX_PROFILE_INFO_Y 10.0

#define BX_PROFILE_INFO_WIDTH_CORRECTION_IPAD (-100.0)
#define BX_PROFILE_INFO_X_IPAD 50.0
#define BX_PROFILE_INFO_Y_IPAD 10.0


@implementation ProfileInfoBlock

@synthesize data;

- (id)initWithCaption:(NSString*)aCaption info:(NSArray*)anInfo data:(id)aData table:(UITableView *)tableView {
	
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil])) {
		
		info = [anInfo copy];
		caption = [aCaption copy];
		self.data = aData; // retain        
        
        float fX = BX_PROFILE_INFO_X;
        float fY = BX_PROFILE_INFO_Y;
        float fW = tableView.frame.size.width + BX_PROFILE_INFO_WIDTH_CORRECTION;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            fX = BX_PROFILE_INFO_X_IPAD;
            fY = BX_PROFILE_INFO_Y_IPAD;
            fW = tableView.frame.size.width + BX_PROFILE_INFO_WIDTH_CORRECTION_IPAD;
        }        		
		
		if (nil != caption && [caption length] > 0) {
            NSString *sCaption = [NSString stringWithFormat:@" %@ ", caption];
            CGSize sizeCaption = [Designer sizeForLabelProfileInfoCaption:sCaption maxWidth:fW maxHeight:BX_PROFILE_INFO_CAPTION_HEIGHT];            
            CGRect r = CGRectMake(
                           fX, 
                           fY, 
                           sizeCaption.width, 
                           BX_PROFILE_INFO_CAPTION_HEIGHT
            );		            
			UILabel *lableCaption = [[UILabel alloc] initWithFrame:r];
			lableCaption.text = sCaption;
			[Designer applyStylesForLabelProfileInfoCaption:lableCaption];
			[self addSubview:lableCaption];
		}
				
		BOOL isValue2;
		CGRect r = CGRectMake(
					   fX, 
					   fY, 
					   fW,
					   BX_PROFILE_INFO_LINE_HEIGHT
		);
				
        // add fields
        int iOriginYSum = BX_PROFILE_INFO_CAPTION_HEIGHT + fY;
        NSInteger iCount = [info count];
		for (int i=0 ; i < iCount ; ++i) {
			NSDictionary *dict = [info objectAtIndex:i];
			NSString *sType = [dict valueForKey:@"Type"];
            NSString *sCaption = [dict valueForKey:@"Caption"];
            NSString *sValue1 = [dict valueForKey:@"Value1"];
            NSString *sValue2 = [dict valueForKey:@"Value2"];
            
            if (nil != sValue2 && ![sValue2 isEqualToString:@""])
                isValue2 = YES;
            else
                isValue2 = NO;
            
            r.origin.x = BX_PROFILE_INFO_D + fX;
            r.origin.y = iOriginYSum;
            r.size.width = fW;
            r.size.height = BX_PROFILE_INFO_LINE_HEIGHT;
            
			UILabel *l = [[UILabel alloc] initWithFrame:r];
            if ([sType isEqualToString:@"area"] || [sType isEqualToString:@"html_area"]) {
                l.text = [NSString stringWithFormat:@"%@:", sCaption];
            } else {
                if (isValue2)
                    l.text = [NSString stringWithFormat:@"%@: %@ / %@", sCaption, sValue1, sValue2];
                else
                    l.text = [NSString stringWithFormat:@"%@: %@", sCaption, sValue1];
            }
                         
			[Designer applyStylesForLabelProfileInfo:l];
			
			[self addSubview:l];
			[l release];

            
            iOriginYSum += BX_PROFILE_INFO_LINE_HEIGHT;
            
            if ([sType isEqualToString:@"area"] || [sType isEqualToString:@"html_area"]) {

                if (isValue2)
                    sValue1 = [NSString stringWithFormat:@"%@\n / \n%@", sValue1, sValue2];
                
                CGSize sizeArea = [Designer sizeForProfileInfoArea:sValue1 maxWidth:fW maxHeight:BX_PROFILE_INFO_MAX_AREA_HEIGHT];

                r.origin.x = BX_PROFILE_INFO_D + fX;
                r.origin.y = iOriginYSum;
                r.size.width = fW;
                r.size.height = sizeArea.height;
                
                iOriginYSum += sizeArea.height;

                UILabel *lValue1 = [[UILabel alloc] initWithFrame:r];
                lValue1.text = sValue1;

                [Designer applyStylesForLabelProfileInfoArea:lValue1];
                [self addSubview:lValue1];
                [lValue1 release];
            }
                         
		}
		
		[Designer applyStylesForCell:self];
		
		self.accessoryType = UITableViewCellAccessoryNone;
		self.accessoryView = nil;
		
        fHeightSum = iOriginYSum + fY;
	}
	
	return self;
}

- (void)dealloc {
	[data release];	
	[caption release];
	[info release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (CGFloat)calcHeight {
	return fHeightSum;
}

@end
