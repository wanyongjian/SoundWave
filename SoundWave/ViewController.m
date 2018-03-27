//
//  ViewController.m
//  SoundWave
//
//  Created by wanyongjian on 2018/3/23.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "ViewController.h"
#import "WaveView.h"
#import <EZMicrophone.h>
#import <EZAudioPlayer.h>
#import <EZAudioFile.h>

@interface ViewController () <EZAudioPlayerDelegate>

@property (nonatomic, strong) WaveView *waveView;
//@property (nonatomic, strong) EZMicrophone *microphone;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) EZAudioPlayer *player;
@property (nonatomic, strong) EZAudioFile *audioFile;
@property (nonatomic, strong) UIView *lineView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.waveView];
    [self.view addSubview:self.startButton];
//    [self.view addSubview:self.lineView];
    
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(250, 60, 125, 1)];
        _lineView.backgroundColor = [UIColor darkGrayColor];
    }
    return _lineView;
}
- (UIButton *)startButton{
    if (!_startButton) {
        _startButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 300, 100, 100)];
        _startButton.backgroundColor = [UIColor blueColor];
        [_startButton addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
//        [_startButton addTarget:self action:@selector(stopAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

- (void)startAction{
    if ([self.player isPlaying]) {
        [self.player pause];
    }else{
        [self.player play];
    }
}
- (void)stopAction{
    [self.player pause];
}
- (EZAudioFile *)audioFile{
    if (!_audioFile) {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Wave" ofType:@"bundle"]];
//        NSString *path = [[bundle resourcePath] stringByAppendingPathComponent:@"sound/111.mp3"];
        NSString *path = [[bundle resourcePath] stringByAppendingPathComponent:@"sound/111.mp3"];
        NSURL *url = [NSURL URLWithString:path];
        _audioFile = [EZAudioFile audioFileWithURL:url];
    }
    return _audioFile;
}
- (EZAudioPlayer *)player{
    if (!_player) {

        _player = [EZAudioPlayer audioPlayerWithDelegate:self];
        _player.shouldLoop = YES;
        [_player setAudioFile:self.audioFile];
    }
    return _player;
}
- (WaveView *)waveView{
    if(!_waveView) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error;
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error)
        {
            NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
        }
        [session setActive:YES error:&error];
        if (error)
        {
            NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
        }
        
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        if (error)
        {
            NSLog(@"Error overriding output to the speaker: %@", error.localizedDescription);
        }
        
        
        _waveView = [[WaveView alloc] initWithFrame:CGRectMake(50, 0, 275, 120)];
        _waveView.backgroundColor = [UIColor clearColor];
//        _waveView.backgroundColor = [UIColor colorWithRed:0.569 green:0.82 blue:0.478 alpha:1.0];
        
        //声波颜色
//        _waveView.color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        _waveView.color = [UIColor darkGrayColor];
        _waveView.plotType = EZPlotTypeRolling;//声波类型
        _waveView.gain = 1.5; //波形大小比例，默认1.0
//        _waveView.shouldFill = YES;
        _waveView.shouldMirror = YES;
//        _waveView.initialPointCount = 100;
        [_waveView setRollingHistoryLength:200];
//        _waveView.shouldOptimizeForRealtimePlot = YES;
//        _waveView.shouldCenterYAxis = NO;
//        _waveView.shouldGroupAccessibilityChildren = YES;

    }
    return _waveView;
}
- (void)audioPlayer:(EZAudioPlayer *)audioPlayer playedAudio:(float **)buffer withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels inAudioFile:(EZAudioFile *)audioFile{
        //线程安全的
        //buffer[0]是左声道 。buffer[1]是右声道
        __weak typeof (self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.waveView updateBuffer:buffer[0] withBufferSize:bufferSize];
        });
}

@end
