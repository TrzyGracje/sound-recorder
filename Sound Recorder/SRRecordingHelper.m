//
//  SRRecordingHelper.m
//  Sound Recorder
//
//  Created by Lukasz Komorowski on 19.06.2016.
//  Copyright © 2016 Lukasz Komorowski. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SRRecordingHelper.h"

@interface SRRecordingHelper ()<AVAudioRecorderDelegate, AVAudioPlayerDelegate> //

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player; //

@end

@implementation SRRecordingHelper

+ (instancetype)sharedInstance {
    static SRRecordingHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)setupRecording {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil]; //

    NSArray *pathComponents = @[
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
        @"tmpFile.m4a"
    ];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    NSDictionary *recordSettings = @{ AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                      AVSampleRateKey : @(44100),
                                      AVNumberOfChannelsKey : @(2) };

    self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSettings error:nil];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
}

- (void)startRecording {
    if (self.recorder.recording == NO) {
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [self.recorder record];
    }
}

- (void)stopRecording {
    if (self.recorder.recording == YES) {
        [self.recorder stop];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
}

- (void)play { //
    if (self.recorder.recording == NO) {
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
        [self.player setDelegate:self];
        [self.player play];
    }
}

#pragma mark - delegates

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag {
    [self play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
}

@end
