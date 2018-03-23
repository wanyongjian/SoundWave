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

@interface ViewController ()

@property (nonatomic, strong) WaveView *waveView;
@property (nonatomic, strong) EZMicrophone *microphone;
@property (nonatomic, strong) UIButton *startButton;
@end

@implementation ViewController

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
    [self.microphone startFetchingAudio];
}
- (void)stopAction{
    [self.microphone stopFetchingAudio];
    [self.waveView redraw];
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
        //创建麦克风
        self.microphone = [EZMicrophone microphoneWithDelegate:self];
        //设置输入设备
        [self.microphone setDevice:[[EZAudioDevice inputDevices] firstObject]];
    }
    return _waveView;
}

#pragma mark - 麦克风代理
//获取buffer流的音频数据信息
- (void)microphone:(EZMicrophone *)microphone hasAudioReceived:(float **)buffer withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    //线程安全的
    //buffer[0]是左声道 。buffer[1]是右声道
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.waveView updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------
//麦克风的AudioStreamBasicDescription流。这是非常有用的
//当配置EZRecorder或告诉另一个组件/ /音频格式类型。
- (void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
    
    [EZAudioUtilities printASBD:audioStreamBasicDescription];
}

@end
