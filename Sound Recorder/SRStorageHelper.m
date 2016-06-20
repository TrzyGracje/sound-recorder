//
//  SRRequestManager.m
//  Sound Recorder
//
//  Created by Lukasz Komorowski on 19.06.2016.
//  Copyright © 2016 Lukasz Komorowski. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "SRStorageHelper.h"

NSString *const UploadEndpoint = @"http://private-a8480-4tune.apiary-mock.com/upload";

@interface SRStorageHelper ()
@property (strong, nonatomic) AFHTTPSessionManager *operationManager;
@end

@implementation SRStorageHelper

+ (instancetype)sharedInstance {
    static SRStorageHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedInstance = [self new];
    });
    return sharedInstance;
}

- (AFHTTPSessionManager *)operationManager {
    if (!_operationManager) {
        _operationManager = [AFHTTPSessionManager manager];
        _operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _operationManager.requestSerializer.timeoutInterval = 7.0;
    }
    return _operationManager;
}

- (NSURL *)fileURL {
    if (_fileURL == nil) {
        NSArray *pathComponents = @[
            [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
            @"tmpFile.m4a"
        ];
        _fileURL = [NSURL fileURLWithPathComponents:pathComponents];
    }
    return _fileURL;
}

- (void)uploadFileWithSuccess:(void (^)())successBlock
                      failure:(void (^)(NSError *error))failBlock {

    [self.operationManager POST:UploadEndpoint
        parameters:nil
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
          [formData appendPartWithFileURL:self.fileURL name:@"audio.m4a" error:nil];
        }
        progress:nil
        success:^(NSURLSessionDataTask *task, id responseObject) {
          successBlock();
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
          failBlock(error);
        }];
}


@end
