//
//  ViewController.h
//  MotionDataDetection
//
//  Created by qianyi wang on 3/11/17.
//  Copyright © 2017 qianyi wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncUdpSocket.h"

@interface ViewController : UIViewController <GCDAsyncUdpSocketDelegate>
@property (strong, nonatomic) IBOutlet UILabel *gesture_result;


@end

