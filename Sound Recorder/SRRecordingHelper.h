//
//  SRRecordingHelper.h
//  Sound Recorder
//
//  Created by Lukasz Komorowski on 19.06.2016.
//  Copyright © 2016 Lukasz Komorowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRRecordingHelper : NSObject

+ (instancetype)sharedInstance;

- (void)setupRecording;
- (void)startRecording;
- (void)stopRecording;
- (void)play; //

@end
