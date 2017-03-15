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
    GCDAsyncUdpSocket *udpSocket;
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
    // init udp socket
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error = nil;
    if(![udpSocket bindToPort:8001 error:&error]){
        NSLog(@"error in bindToPort");
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
    [udpSocket sendData:messageData toHost:@"10.0.0.189" port:8001 withTimeout:-1 tag:1];
    // change the UI in the main thread to eliminate the delay
    dispatch_async(dispatch_get_main_queue(), ^{
        self.gesture_result.text = str;
    });
}

@end
