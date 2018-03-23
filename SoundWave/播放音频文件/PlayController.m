//
//  ViewController.m
//  SoundWave
//
//  Created by wanyongjian on 2018/3/23.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "PlayController.h"
#import "WaveView.h"
#import <EZMicrophone.h>
#import <EZAudioPlayer.h>
#import <EZAudioFile.h>

@interface PlayController () <EZAudioPlayerDelegate>

@property (nonatomic, strong) WaveView *waveView;
//@property (nonatomic, strong) EZMicrophone *microphone;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) EZAudioPlayer *player;
@property (nonatomic, strong) EZAudioFile *audioFile;
@end

@implementation PlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.waveView];
    [self.view addSubview:self.startButton];
    
}

- (UIButton *)startButton{
    if (!_startButton) {
        _startButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 300, 100, 100)];
        _startButton.backgroundColor = [UIColor blueColor];
        [_startButton addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchDown];
        [_startButton addTarget:self action:@selector(stopAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

- (void)startAction{
    [self.player playAudioFile:self.audioFile];
}
- (void)stopAction{
    [self.player pause];
}
- (EZAudioFile *)audioFile{
    if (!_audioFile) {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Wave" ofType:@"bundle"]];
        NSString *path = [[bundle resourcePath] stringByAppendingPathComponent:@"sound/test.m4a"];
        NSURL *url = [NSURL URLWithString:path];
        _audioFile = [EZAudioFile audioFileWithURL:url];
    }
    return _audioFile;
}
- (EZAudioPlayer *)player{
    if (!_player) {

        _player = [EZAudioPlayer audioPlayerWithDelegate:self];
    }
    return _player;
}
- (WaveView *)waveView{
    if(!_waveView) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (error) {
            NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
        }
        [session setActive:YES error:&error];
        if (error) {
            NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
        }
        _waveView = [[WaveView alloc] initWithFrame:CGRectMake(0, 100, 300, 200)];
        _waveView.backgroundColor = [UIColor colorWithRed:0.569 green:0.82 blue:0.478 alpha:1.0];
        
        //声波颜色
        _waveView.color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        _waveView.plotType = EZPlotTypeRolling;//声波类型
        _waveView.gain = 3.0; //波形大小比例，默认1.0
        _waveView.shouldFill = YES;
        _waveView.shouldMirror = YES;
        [_waveView setRollingHistoryLength:200];

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
