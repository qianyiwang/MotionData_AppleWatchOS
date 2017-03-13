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
@synthesize acc_array;
@synthesize speed_last;
@synthesize time_interval;
@synthesize mAccBias;
@synthesize mAccDelta;
@synthesize mSpeedBias;
@synthesize mSpeedDelta;
@synthesize SPEED_BIAS_STEP;
@synthesize SPEED_ZERO_RANGE;
@synthesize ACC_BIAS_STEP;
@synthesize ACC_ZERO_RANGE;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    [self initialVariables];
}

- (void)initialVariables{
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = time_interval;
    time_interval = 0.05;
    
    acc_array = [[NSMutableArray alloc] init];
    [acc_array addObject:[NSNumber numberWithDouble:0]];
    [acc_array addObject:[NSNumber numberWithDouble:0]];
    [acc_array addObject:[NSNumber numberWithDouble:0]];
    
    mAccDelta = [[NSMutableArray alloc] init];
    [mAccDelta addObject:[NSNumber numberWithDouble:0]];
    [mAccDelta addObject:[NSNumber numberWithDouble:0]];
    [mAccDelta addObject:[NSNumber numberWithDouble:0]];
    
    mAccBias = [[NSMutableArray alloc] init];
    [mAccBias addObject:[NSNumber numberWithDouble:0]];
    [mAccBias addObject:[NSNumber numberWithDouble:0]];
    [mAccBias addObject:[NSNumber numberWithDouble:0]];
    
    speed_last = [[NSMutableArray alloc] init];
    [speed_last addObject:[NSNumber numberWithDouble:0]];
    [speed_last addObject:[NSNumber numberWithDouble:0]];
    [speed_last addObject:[NSNumber numberWithDouble:0]];
    
    mSpeedDelta = [[NSMutableArray alloc] init];
    [mSpeedDelta addObject:[NSNumber numberWithDouble:0]];
    [mSpeedDelta addObject:[NSNumber numberWithDouble:0]];
    [mSpeedDelta addObject:[NSNumber numberWithDouble:0]];
    
    mSpeedBias = [[NSMutableArray alloc] init];
    [mSpeedBias addObject:[NSNumber numberWithDouble:0]];
    [mSpeedBias addObject:[NSNumber numberWithDouble:0]];
    [mSpeedBias addObject:[NSNumber numberWithDouble:0]];
    
    ACC_BIAS_STEP = [[NSArray alloc] init];
    ACC_BIAS_STEP = @[@0.01, @0.01, @0.01];
    
    ACC_ZERO_RANGE= [[NSArray alloc] init];
    ACC_ZERO_RANGE = @[@0.1, @0.1, @0.1];
    
    SPEED_BIAS_STEP = [[NSArray alloc] init];
    SPEED_BIAS_STEP = @[@0.1, @0.1, @0.1];
    
    SPEED_ZERO_RANGE= [[NSArray alloc] init];
    SPEED_ZERO_RANGE = @[@0.05, @0.05, @0.05];
    
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
        
        // apply calibration filter for Acceleration
        
        [acc_array replaceObjectAtIndex:0 withObject:[NSNumber numberWithDouble:deviceMotion.userAcceleration.x]];
        [acc_array replaceObjectAtIndex:1 withObject:[NSNumber numberWithDouble:deviceMotion.userAcceleration.y]];
        [acc_array replaceObjectAtIndex:2 withObject:[NSNumber numberWithDouble:deviceMotion.userAcceleration.z]];
        
        for(int i=0; i<3; i++){

            double temp = [acc_array[i] doubleValue] - [mAccBias[i] doubleValue];
            [mAccDelta replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:temp]];
            
            if ([mAccDelta[i] doubleValue]> 0){
                if ([mAccDelta[i] doubleValue] > [ACC_BIAS_STEP[i] doubleValue]) {
                    [mAccBias replaceObjectAtIndex:i withObject:
                     [NSNumber numberWithDouble:[mAccBias[i] doubleValue]+[ACC_BIAS_STEP[i] doubleValue]]];
                } else {
                    [mAccBias replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:
                                                                   [mAccBias[i] doubleValue]+[acc_array[i] doubleValue]]];
                }
            }
            else{
                if ([mAccDelta[i] doubleValue] < -[ACC_BIAS_STEP[i] doubleValue]) {
                    [mAccBias replaceObjectAtIndex:i withObject:
                     [NSNumber numberWithDouble:[mAccBias[i] doubleValue]-[ACC_BIAS_STEP[i] doubleValue]]];
                } else {
                    [mAccBias replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:
                                                                   [mAccBias[i] doubleValue]-[acc_array[i] doubleValue]]];
                }
            }
            [mSpeedDelta replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:
                                                            [acc_array[i] doubleValue]-[mAccBias[i] doubleValue]]];
            
            if([mAccDelta[i] doubleValue]<[ACC_ZERO_RANGE[i] doubleValue] && [mAccDelta[i] doubleValue]>-[ACC_ZERO_RANGE[i] doubleValue]){
                [mAccDelta replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:0]];
            }
        }
        // end calibration filter for Acceleration
        
        CMAttitude *attitude = deviceMotion.attitude;
        CMRotationMatrix rot=attitude.rotationMatrix;
        double acc_global_x = [mAccDelta[0] doubleValue]*rot.m11 + [mAccDelta[1] doubleValue]*rot.m21 + [mAccDelta[2] doubleValue]*rot.m31;
        double acc_global_y = [mAccDelta[0] doubleValue]*rot.m12 + [mAccDelta[1] doubleValue]*rot.m22 + [mAccDelta[2] doubleValue]*rot.m32;
        double acc_global_z = [mAccDelta[0] doubleValue]*rot.m13 + [mAccDelta[1] doubleValue]*rot.m23 + [mAccDelta[2] doubleValue]*rot.m33;
        
        
        NSLog(@"%f,%f,%f", acc_global_x, acc_global_y, acc_global_z);
        
        self.acc_x_text.text = [NSString stringWithFormat:@"%f", acc_global_x];
        self.acc_y_text.text = [NSString stringWithFormat:@"%f", acc_global_y];
        self.acc_z_text.text = [NSString stringWithFormat:@"%f", acc_global_z];
        
        //        speed_last_x += acc_global_x*time_interval;
        //        speed_last_y += acc_global_y*time_interval;
        //        speed_last_z += acc_global_z*time_interval;
        
//        [self calculateSpeed:acc_global_x accY:acc_global_y accZ:acc_global_z];
//        [self speedCalibrationFilter];
//        NSLog(@"acc_x: %f, acc_y: %f, acc_z: %f, speed_x: %@, speed_y: %@, speed_z: %@", acc_global_x, acc_global_y, acc_global_z, mSpeedDelta[0], mSpeedDelta[1], mSpeedDelta[2]);
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
        [mSpeedBias replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:0]];
        [mSpeedDelta replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:0]];
    }
}

-(void)speedCalibrationFilter{
    for(int i=0; i<3; i++){
        double temp = [speed_last[i] doubleValue] - [mSpeedBias[i] doubleValue];
        [mSpeedDelta replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:temp]];
        
        if ([mSpeedDelta[i] doubleValue]> 0){
            if ([mSpeedDelta[i] doubleValue] > [SPEED_BIAS_STEP[i] doubleValue]) {
                [mSpeedBias replaceObjectAtIndex:i withObject:
                 [NSNumber numberWithDouble:[mSpeedBias[i] doubleValue]+[SPEED_BIAS_STEP[i] doubleValue]]];
            } else {
                [mSpeedBias replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:
                                                               [mSpeedBias[i] doubleValue]+[speed_last[i] doubleValue]]];
            }
        }
        else{
            if ([mSpeedDelta[i] doubleValue] < -[SPEED_BIAS_STEP[i] doubleValue]) {
                [mSpeedBias replaceObjectAtIndex:i withObject:
                 [NSNumber numberWithDouble:[mSpeedBias[i] doubleValue]-[SPEED_BIAS_STEP[i] doubleValue]]];
            } else {
                [mSpeedBias replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:
                                                               [mSpeedBias[i] doubleValue]-[speed_last[i] doubleValue]]];
            }
        }
        [mSpeedDelta replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:
                                                        [speed_last[i] doubleValue]-[mSpeedBias[i] doubleValue]]];
        
        if([mSpeedDelta[i] doubleValue]<[SPEED_ZERO_RANGE[i] doubleValue] && [mSpeedDelta[i] doubleValue]>-[SPEED_ZERO_RANGE[i] doubleValue]){
            [mSpeedDelta replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:0]];
        }
    }
}

- (IBAction)startButtonAction {
    [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeClick];
//    dispatch_queue_t async_queue = dispatch_queue_create("async queue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(async_queue, ^{
//        [self startSensorUpdate];
//    });
    [self startSensorUpdate];
}
- (IBAction)stopButtonAction {
    [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeClick];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"stop update");
//        [motionManager stopDeviceMotionUpdates];
//    });
    [motionManager stopDeviceMotionUpdates];
    [self resetVariables];
}

@end



