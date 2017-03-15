//
//  ViewController.m
//  MotionDataDetection
//
//  Created by qianyi wang on 3/11/17.
//  Copyright © 2017 qianyi wang. All rights reserved.
//

#import "ViewController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface ViewController (){
    WCSession *session;
}

@end

@implementation ViewController

@synthesize gesture_result;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([WCSession isSupported]) {
        session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)session:(WCSession *)session didReceiveMessageData:(nonnull NSData *)messageData replyHandler:(nonnull void (^)(NSData * _Nonnull))replyHandler{
    replyHandler([@"received" dataUsingEncoding:NSUTF8StringEncoding]);
    NSString* str;
    str = [[NSString alloc] initWithData:messageData encoding:NSASCIIStringEncoding];
    NSLog(@"%@",str);
    // change the UI in the main thread to eliminate the delay
    dispatch_async(dispatch_get_main_queue(), ^{
        self.gesture_result.text = str;
    });
}

@end
