//
//  SRRequestManager.h
//  Sound Recorder
//
//  Created by Lukasz Komorowski on 19.06.2016.
//  Copyright © 2016 Lukasz Komorowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRStorageHelper : NSObject

@property (strong, nonatomic) NSURL *fileURL;

+ (instancetype)sharedInstance;

- (void)uploadFileWithSuccess:(void (^)())successBlock
                      failure:(void (^)(NSError *error))failBlock;

@end
