//
//  InterfaceController.h
//  MotionDataDetection WatchKit Extension
//
//  Created by qianyi wang on 3/11/17.
//  Copyright © 2017 qianyi wang. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface InterfaceController : WKInterfaceController
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *acc_x_text;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *acc_y_text;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *acc_z_text;
@property (nonatomic) double speed_last_x;
@property (nonatomic) double speed_last_y;
@property (nonatomic) double speed_last_z;
@property (nonatomic) double time_interval;

-(void) calculateSpeed: (double) acc_x accY: (double) acc_y accZ: (double) acc_z;
-(void) resetVariables;
-(void) startSensorUpdate;
-(void) speedCalibrationFilter;

@end
