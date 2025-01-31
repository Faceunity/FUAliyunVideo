//
//  AlivcRecordFliterView.m
//  AliyunVideoClient_Entrance
//
//  Created by 张璠 on 2018/11/19.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcRecordFliterView.h"
#import "AliyunEffectFilterCell.h"
#import "AliyunEffectInfo.h"
#import "AliyunDBHelper.h"
#import "AVC_ShortVideo_Config.h"
#import "AliyunEffectResourceModel.h"
@interface AlivcRecordFliterView()
/**
 显示view
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 数据模型数组
 */
@property (nonatomic, strong) NSMutableArray *dataArray;

/**
 FMDB的封装类
 */
@property (nonatomic, strong) AliyunDBHelper *dbHelper;

/**
 数据类型
 */
@property (nonatomic, assign) NSInteger effectType;

/**
 选中滤镜的序号
 */
@property (nonatomic, assign) NSInteger selectIndex;
@end
@implementation AlivcRecordFliterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _dbHelper = [[AliyunDBHelper alloc] init];
        _dataArray = [[NSMutableArray alloc] init];
        _selectIndex = -1;
        [self addSubViews];
    }
    return self;
}


/**
 添加子控件
 */
- (void)addSubViews {
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(50, 70);
    layout.sectionInset = UIEdgeInsetsMake(5, 20, 20, 22);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 22, ScreenWidth, 102) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectFilterCell" bundle:nil] forCellWithReuseIdentifier:@"AliyunEffectFilterCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectFilterCell" bundle:nil] forCellWithReuseIdentifier:@"AliyunEffectFilterFuncCell"];
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    _collectionView.delegate = (id<UICollectionViewDelegate>)self;
    [self addSubview:_collectionView];
    
    [self reloadDataWithEffectType:AliyunEffectTypeFilter];
}




- (void)reloadDataWithEffectType:(NSInteger)eType {
    
    _effectType = eType;
    
    [_dataArray removeAllObjects];
    
    if (_selectIndex == -1) {
        _selectIndex = 0; //默认是不选中
    }
    
    [_dbHelper queryResourceWithEffecInfoType:eType success:^(NSArray *infoModelArray) {
        for (AliyunEffectMvGroup *mvGroup in infoModelArray) {
            [_dataArray addObject:mvGroup];
            if (_selectedEffect) {
                if (mvGroup.eid == _selectedEffect.eid) {
                    _selectIndex = [infoModelArray indexOfObject:mvGroup] + 1;
                }
            }
        }
        
        //        if (eType == AliyunEffectTypeFilter) {
        //            // 在这里可以自定义滤镜顺序或者在LocalFilter文件里修改
        //            AliyunEffectMvGroup *mvGroup = _dataArray[2];
        //            _dataArray[2] = _dataArray[1];
        //            _dataArray[1] = mvGroup;
        //        }
        if (eType != AliyunEffectTypeSpecialFilter) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_collectionView reloadData];
            });
        }
        
    } failure:^(NSError *error) {
        
    }];
    
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AliyunEffectFilterCell *cell;
    if (indexPath.row == 0 || indexPath.row == _dataArray.count - 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectFilterFuncCell" forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectFilterCell" forIndexPath:indexPath];
        
    }
    
    
    AliyunEffectInfo *effectInfo = _dataArray[indexPath.row];
    [cell cellModel:effectInfo];
    if (_effectType != AliyunEffectTypeSpecialFilter) {
        if (indexPath.row == _selectIndex) {
            [cell setSelected:YES];
            NSLog(@"滤镜测试%@：选中：%ld",effectInfo.name,_selectIndex);
        }else{
            [cell setSelected:NO];
            NSLog(@"滤镜测试%@：不选中：%ld",effectInfo.name,indexPath.row);
        }
    }
    if (_effectType == AliyunEffectTypeFilter) {
        if (indexPath.row == 0) {
            cell.imageView.contentMode = UIViewContentModeCenter;
            cell.imageView.backgroundColor = rgba(255, 255, 255, 0.2);
            cell.imageView.image = [AlivcImage imageNamed:@"shortVideo_clear"];
            cell.nameLabel.text = @"无效果";
        }else{
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imageView.backgroundColor = [UIColor clearColor];
        }
    }
    
    [cell setExclusiveTouch:YES];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_effectType != AliyunEffectTypeSpecialFilter) {
        AliyunEffectFilterCell *lastSelectCell = (AliyunEffectFilterCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectIndex inSection:0]];
        NSLog(@"滤镜测试：不选中：%ld",_selectIndex);
        [lastSelectCell setSelected:NO];
    }
    
    AliyunEffectInfo *currentEffect = _dataArray[indexPath.row];
    if (_effectType == AliyunEffectTypeFilter) {
        [_delegate didSelectEffectFilter:(AliyunEffectFilterInfo *)currentEffect];
        _selectIndex = indexPath.row;
    }
}


@end
