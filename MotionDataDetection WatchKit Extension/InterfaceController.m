//
//  InterfaceController.m
//  MotionDataDetection WatchKit Extension
//
//  Created by qianyi wang on 3/11/17.
//  Copyright © 2017 qianyi wang. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController(){
    CMMotionManager *motionManager;
}

@end


@implementation InterfaceController

@synthesize acc_x_text;
@synthesize acc_y_text;
@synthesize acc_z_text;
@synthesize speed_last_x;
@synthesize speed_last_y;
@synthesize speed_last_z;
@synthesize time_interval;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = time_interval;
    time_interval = 0.05;
    speed_last_x = speed_last_y = speed_last_z = 0;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

-(void)startSensorUpdate{
    [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion  *deviceMotion, NSError *error) {
        CMAttitude *attitude = deviceMotion.attitude;
        CMRotationMatrix rot=attitude.rotationMatrix;
        double acc_global_x = deviceMotion.userAcceleration.x*rot.m11 + deviceMotion.userAcceleration.y*rot.m21 + deviceMotion.userAcceleration.z*rot.m31;
        double acc_global_y = deviceMotion.userAcceleration.x*rot.m12 + deviceMotion.userAcceleration.y*rot.m22 + deviceMotion.userAcceleration.z*rot.m32;
        double acc_global_z = deviceMotion.userAcceleration.x*rot.m13 + deviceMotion.userAcceleration.y*rot.m23 + deviceMotion.userAcceleration.z*rot.m33;
        
        self.acc_x_text.text = [NSString stringWithFormat:@"%f", acc_global_x];
        self.acc_y_text.text = [NSString stringWithFormat:@"%f", acc_global_y];
        self.acc_z_text.text = [NSString stringWithFormat:@"%f", acc_global_z];
        
        //        speed_last_x += acc_global_x*time_interval;
        //        speed_last_y += acc_global_y*time_interval;
        //        speed_last_z += acc_global_z*time_interval;
        
        [self calculateSpeed:acc_global_x accY:acc_global_y accZ:acc_global_z];
        
        NSLog(@"acc_x: %f, acc_y: %f, acc_z: %f, speed_x: %f, speed_y: %f, speed_z: %f", acc_global_x, acc_global_y, acc_global_z, speed_last_x, speed_last_y, speed_last_z);
    }];
}

-(void)calculateSpeed:(double)acc_x accY:(double)acc_y accZ:(double)acc_z{
    speed_last_x += acc_x*time_interval;
    speed_last_y += acc_y*time_interval;
    speed_last_z += acc_z*time_interval;
}

-(void)resetVariables{
    speed_last_x = speed_last_y = speed_last_z = 0;
}

- (IBAction)startButtonAction {
    [self startSensorUpdate];
}
- (IBAction)stopButtonAction {
    [self resetVariables];
    motionManager.stopDeviceMotionUpdates;
}

@end



