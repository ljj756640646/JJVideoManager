//
//  ViewController.m
//  JJVideoManagerKit
//
//  Created by lujunjie on 2019/4/1.
//  Copyright © 2019 JJ. All rights reserved.
//

#import "ViewController.h"
#import "JJVideoCompression.h"
#import "TZImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
@interface ViewController ()<TZImagePickerControllerDelegate>

@end

@implementation ViewController
- (NSString *)getOutputPath
{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"output-%@.mp4",[formater stringFromDate:[NSDate date]]];
    //NSString *outputPath = [NSTemporaryDirectory() stringByAppendingFormat:@"%@", fileName];
    NSString *outputPath = [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory , NSUserDomainMask , YES ) firstObject]stringByAppendingFormat:@"/%@", fileName];
    //NSString *outputPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", fileName];
    
    return outputPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}
- (IBAction)OpenAction:(UIButton *)sender {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = NO;
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.circleCropRadius = 100;
    [self presentViewController:imagePickerVc
                       animated:YES completion:nil];
}
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //__weak typeof(self) weakSelf = self;
    PHAsset *phAsset = asset;
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    options.progressHandler =  ^(double progress,NSError *error,BOOL* stop, NSDictionary* dict) {};
    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
        
        //NSString *videoPath = [((AVURLAsset*)avasset).URL absoluteString];
        
        JJVideoCompression *compression = [[JJVideoCompression alloc]init]; // 创建对象
        compression.inputURL = ((AVURLAsset*)avasset).URL; // 视频输入路径
        compression.exportURL = [NSURL fileURLWithPath:[self getOutputPath]]; // 视频输出路径
        
        
        JJAudioConfigurations audioConfigurations;// 音频压缩配置
        audioConfigurations.samplerate = JJAudioSampleRate_11025Hz; // 采样率
        audioConfigurations.bitrate = JJAudioBitRate_32Kbps;// 音频的码率
        audioConfigurations.numOfChannels = 1;// 声道数
        audioConfigurations.frameSize = 8; // 采样深度
        
        compression.audioConfigurations = audioConfigurations;
        
        
        JJVideoConfigurations videoConfigurations;
        
        videoConfigurations.fps = 15; // 帧率 一秒中有多少帧
        videoConfigurations.videoBitRate = JJ_VIDEO_BITRATE_LOW; // 视频质量 码率
        videoConfigurations.videoResolution =  JJ_VIDEO_RESOLUTION_SUPER; //视频尺寸
        
        compression.videoConfigurations = videoConfigurations;
        
        [compression startCompressionWithCompletionHandler:^(JJVideoCompressionState State) {
            if (State == JJ_VIDEO_STATE_FAILURE) {
                NSLog(@"压缩失败");
            }else
            {
                NSLog(@"压缩成功");
            }
        }];
        
    }];
    
}
@end
