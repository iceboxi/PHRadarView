//
//  PHRadarView.h
//  PHRadarView
//
//  Created by Yang on 2015/05/29.
//  Copyright (c) 2015年 Yang PowHu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHRadarLineView : UIView

@end

IB_DESIGNABLE
@interface PHRadarView : UIView
{
    PHRadarLineView *radarLine;
}
@end

