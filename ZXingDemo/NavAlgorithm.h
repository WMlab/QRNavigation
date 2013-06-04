//
//  NavAlgorithm.h
//  QRNavigation
//
//  Created by 史 丹青 on 13-6-3.
//  Copyright (c) 2013年 tongji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavAlgorithm : NSObject

+(NSMutableArray*) dijkstraWithStart:(int)start End:(int)end;

@end
