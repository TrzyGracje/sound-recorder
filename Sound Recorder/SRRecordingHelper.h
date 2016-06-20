//
//  SRRecordingHelper.h
//  Sound Recorder
//
//  Created by Lukasz Komorowski on 19.06.2016.
//  Copyright © 2016 Lukasz Komorowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SRRecordinghelperDelegate
- (void)audioRecorderDidFinishRecording;
@end

@interface SRRecordingHelper : NSObject

+ (instancetype)sharedInstance;
@property (nonatomic, weak) id<SRRecordinghelperDelegate> delegate;

- (void)setup;
- (void)startRecording;
- (void)stopRecording;
- (void)play; // for testing purposes only

@end
