//
//  MovieViewController.m
//  MoviePlayer
//
//  Created by TuFa on 16/7/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "MovieViewController.h"
#import <AVKit/AVKit.h>  //iOS 8.0提供的框架,支持视频播放
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h> //iOS 9以后可能要弃用掉
#import "UIViewExt.h"

#define KSCreenWidth [UIScreen mainScreen].bounds.size.width
#define KSCreenHeight [UIScreen mainScreen].bounds.size.height

@interface MovieViewController ()
{
    MPMoviePlayerController *player;//可任意修改播放页面尺寸
    
    UIView *viewPop;
    NSInteger playerState;
}

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /*
     系统内部封装了很多通知,可以监听视频播放的不同状态,下面只是列举两种
     */
    //视频播放完成的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didFinish1:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    //视频播放状态改变的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playStateChangeNotifation1:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
//1.构建URL
    NSURL *url=[NSURL URLWithString:@"http://vf1.mtime.cn/Video/2012/06/21/mp4/120621104820876931.mp4"];
//或2：构建本地视频URL
//    NSString *filePath=[[NSBundle mainBundle]pathForResource:@"video.mp4" ofType:nil];
//    NSURL *url=[NSURL fileURLWithPath:filePath];
    player=[[MPMoviePlayerController alloc]initWithContentURL:url];
    player.view.frame=CGRectMake(0, 20, KSCreenWidth, 350);
    //添加播放视图
    [self.view addSubview:player.view];
    //设置播放页面的按钮样式
    /*
     MPMovieControlStyleNone,       // No controls
     MPMovieControlStyleEmbedded,   // Controls for an embedded view  //嵌入式  默认
     MPMovieControlStyleFullscreen, // Controls for fullscreen playback     //全屏
     */
    player.controlStyle=MPMovieControlStyleEmbedded;
    //背景色会在电影播放器转入转出时使用
    player.view.backgroundColor = [UIColor blackColor];
    //设置视频宽高比
    /*
     MPMovieScallingModeNone            不做任何缩放
     MPMovieScallingModeAspectFit       适应屏幕大小，保持宽高比
     MPMovieScallingModeAspectFill      适应屏幕大小，保持宽高比，可裁剪
     MPMovieScallingModeFill            充满屏幕，不保持宽高比
     */
    /*
     播放页面上下黑框问题
     1.视频本身带有边框
     2.视频分辨率与播放页面尺寸不匹配,小于播放页面尺寸,会默认用黑色填充
     */
    player.scalingMode=MPMovieScalingModeAspectFit;
    //手动开始播放
    [player prepareToPlay];
    [player play];
    
    playerState = 0;
    
    
    viewPop = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KSCreenWidth-60, 240)];
    viewPop.backgroundColor = [UIColor whiteColor];
    viewPop.center = player.view.center;
    [player.view addSubview:viewPop];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, viewPop.frame.size.width-40, 30)];
    label.text = @"学习目标";
    label.font = [UIFont systemFontOfSize:22];
    label.textAlignment = NSTextAlignmentCenter;
    [viewPop addSubview:label];
    
    UILabel *labelLine = [[UILabel alloc]initWithFrame:CGRectMake(20, 40+35, viewPop.width-40, 1)];
    labelLine.backgroundColor = [UIColor blackColor];
    [viewPop addSubview:labelLine];
    
    UIButton *removBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    removBtn.frame = CGRectMake(viewPop.frame.size.width-45, 10, 35, 35);
    [removBtn setBackgroundImage:[UIImage imageNamed:@"icon_goodsdetail_cancel"] forState:UIControlStateNormal];
    [viewPop addSubview:removBtn];
//    removBtn.layer.cornerRadius = 17.5;
    [removBtn addTarget:self action:@selector(removeButton) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *arr = @[@"1.播放本地或网络视频.",@"2.自定义视频播放器尺寸,视频分辨率与播放页面尺寸不匹配,小于播放页面尺寸,会默认用黑色填充，保持宽高比.",@"3.暂停时弹出视图."];
    
    int textLabelY = labelLine.bottom+10;
    for (int i=0; i<arr.count; i++) {
        
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, textLabelY, viewPop.width-40, 30)];
        textLabel.text = arr[i];
        [viewPop addSubview:textLabel];
        
        textLabel.numberOfLines = 0;
        [textLabel sizeToFit];
        
        textLabelY = textLabelY +textLabel.height+7;
    }
    
    
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, player.view.bottom, KSCreenWidth, KSCreenHeight-player.view.bottom)];
    textView.backgroundColor = [UIColor darkGrayColor];
    textView.text = @"现在出发\n 准备好了吗\n 提问开始\n 你们都要回答\n 跟上节奏\n 启动查克拉\n Are you ready\n Let' go\n 穿越时间\n 来到新的起点\n 魔法世界\n 幻想都会实现\n 他们宣言\n 善良勤奋还有勇敢\n 使用比啵比啵比啵\n 还有比啵比啵比啵\n 带上梦想乐园的魔力\n 寻找快乐宝藏的秘密\n 打开蔚蓝色的新世纪\n 大声念你的咒语\n 一起快乐做游戏";
    textView.textColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize:18];
    textView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:textView];
    
}

-(void)removeButton{
    
//    [viewPop removeFromSuperview];
    viewPop.hidden = YES;
    playerState = 100;
    
    [player play];
}


//播放完成
-(void)didFinish1:(NSNotification *)notification{
    NSLog(@"播放结束");
}
//播放状态改变
-(void)playStateChangeNotifation1:(NSNotification *)notification{
    MPMoviePlayerController *MPplayer=notification.object;
    if(MPplayer.playbackState==MPMoviePlaybackStatePaused){
        
        viewPop.hidden = NO;
        NSLog(@"暂停");
    }  if(MPplayer.playbackState==MPMoviePlaybackStatePlaying){
        
        if (playerState != 100) {
            
            [player pause];
        }else{
            
            NSLog(@"开始播放");
        }
    }else if(MPplayer.playbackState==MPMoviePlaybackStateSeekingForward){

        viewPop.hidden = YES;

        NSLog(@"快进");
    }
}


@end
