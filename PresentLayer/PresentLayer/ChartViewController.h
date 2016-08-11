//
//  ChartViewController.h
//  PresentLayer
//
//  Created by tiger on 16/8/11.
//  Copyright © 2016年 buystreet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPManager.h"
@interface ChartViewController : UICollectionViewController
@property (strong, nonatomic) NSArray * events;
@property (strong,nonatomic) XMPPUserCoreDataStorageObject *currentUser;
@end
