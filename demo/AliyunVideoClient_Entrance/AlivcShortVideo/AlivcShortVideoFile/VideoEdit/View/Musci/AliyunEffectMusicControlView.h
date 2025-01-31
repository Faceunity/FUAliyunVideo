//
//  AliyunEffectMusicControlView.h
//  AliyunVideo
//
//  Created by Worthy on 2017/3/15.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTRangeSlider.h"

@protocol AliyunEffectMusicControlViewDelegate <NSObject>

- (void)controlViewDidUpadteVolume:(CGFloat)volume;
- (void)controlViewDidUpdateMute:(BOOL)mute;

@end

@interface AliyunEffectMusicControlView : UIView
@property (nonatomic, strong) UIButton *buttonMute;
@property (nonatomic, strong) UISlider *sliderVolume;
@property (nonatomic, weak) id<AliyunEffectMusicControlViewDelegate> delegate;
@property (nonatomic, strong) TTRangeSlider *sliderTime;
@property (nonatomic, strong) TTRangeSlider *sliderStreamTime;
- (void)updateControlSliderWithWeight:(float)weight;

@end
