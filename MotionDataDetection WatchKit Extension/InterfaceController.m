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
@synthesize speed_last;
@synthesize time_interval;
@synthesize mSpeedBias;
@synthesize mSpeedDelta;
@synthesize SPEED_BIAS_STEP;
@synthesize SPEED_ZERO_RANGE;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    [self initialVariables];
}

- (void)initialVariables{
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = time_interval;
    time_interval = 0.05;
    
    speed_last = [[NSMutableArray alloc] init];
    [speed_last addObject:[NSNumber numberWithDouble:0]];
    [speed_last addObject:[NSNumber numberWithDouble:0]];
    [speed_last addObject:[NSNumber numberWithDouble:0]];
    
    mSpeedDelta = @[@0, @0, @0];
    mSpeedBias = @[@0, @0, @0];
    SPEED_BIAS_STEP = @[@0.1f, @0.1f, @0.1f];
    SPEED_ZERO_RANGE = @[@0.05f, @0.05f, @0.05f];
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
        
        NSLog(@"acc_x: %f, acc_y: %f, acc_z: %f, speed_x: %@, speed_y: %@, speed_z: %@", acc_global_x, acc_global_y, acc_global_z, speed_last[0], speed_last[1], speed_last[2]);
    }];
}

-(void)calculateSpeed:(double)acc_x accY:(double)acc_y accZ:(double)acc_z{
//    myArray replaceObjectAtIndex:0 withObject:@"Y"
    for(int i=0; i<3; i++){
        double temp = [speed_last[i] doubleValue]+acc_x*time_interval;
        [speed_last replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:temp]];
    }
}

-(void)resetVariables{
    for(int i=0; i<3; i++){
        [speed_last replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:0]];
    }
}

-(void)speedCalibrationFilter{
    
}

- (IBAction)startButtonAction {
    [self startSensorUpdate];
}
- (IBAction)stopButtonAction {
    motionManager.stopDeviceMotionUpdates;
    [self resetVariables];
    mSpeedDelta = @[@0, @0, @0];
    mSpeedBias = @[@0, @0, @0];
}

@end



