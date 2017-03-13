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
    ACC_ZERO_RANGE = @[@0.05, @0.05, @0.05];
    
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
        
        CMAttitude *attitude = deviceMotion.attitude;
        CMRotationMatrix rot=attitude.rotationMatrix;
        double acc_global_x = deviceMotion.userAcceleration.x*rot.m11 + deviceMotion.userAcceleration.y*rot.m21 + deviceMotion.userAcceleration.z*rot.m31;
        double acc_global_y = deviceMotion.userAcceleration.x*rot.m12 + deviceMotion.userAcceleration.y*rot.m22 + deviceMotion.userAcceleration.z*rot.m32;
        double acc_global_z = deviceMotion.userAcceleration.x*rot.m13 + deviceMotion.userAcceleration.y*rot.m23 + deviceMotion.userAcceleration.z*rot.m33;
        
        
        NSLog(@"%f,%f,%f", acc_global_x, acc_global_y, acc_global_z);
        
        self.acc_x_text.text = [NSString stringWithFormat:@"%f", acc_global_x];
        self.acc_y_text.text = [NSString stringWithFormat:@"%f", acc_global_y];
        self.acc_z_text.text = [NSString stringWithFormat:@"%f", acc_global_z];
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



