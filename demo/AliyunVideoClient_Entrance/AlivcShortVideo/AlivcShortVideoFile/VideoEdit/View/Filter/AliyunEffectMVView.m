//
//  AliyunEffectFilterView.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMVView.h"
#import "AliyunEffectFilterCell.h"
#import "AliyunEffectInfo.h"
#import "AliyunDBHelper.h"
//#import "AVC_ShortVideo_Config.h"
#import "UIView+AlivcHelper.h"
#import "AliyunEffectResourceModel.h"

#import "AlivcEditBottomHeaderView.h"

@interface AliyunEffectMVView()

/**
 显示MV列表的View
 */
@property (nonatomic , strong) UICollectionView *collectionView;

/**
 MV数据数组
 */
@property (nonatomic , strong) NSMutableArray *dataArray;

/**
 封装FMDB的工具类
 */
@property (nonatomic , strong) AliyunDBHelper *dbHelper;

/**
 MV的类型
 */
@property (nonatomic , assign) NSInteger effectType;

@end

@implementation AliyunEffectMVView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _dbHelper = [[AliyunDBHelper alloc] init];
        _dataArray = [[NSMutableArray alloc] init];
        _selectIndex = 0;
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews {
    
    [self addVisualEffect];

    
    AlivcEditBottomHeaderView *headerView = [[AlivcEditBottomHeaderView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 45)];
    [headerView setTitle:@"MV" icon:[AlivcImage imageNamed:@"shortVideo_MV"]];
    [headerView hiddenButton];
    [self addSubview:headerView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(50, 70);
    layout.sectionInset = UIEdgeInsetsMake(15, 22, 20, 22);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 62.5, ScreenWidth, 102) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectFilterCell" bundle:nil] forCellWithReuseIdentifier:@"AliyunEffectFilterCell"];
     [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectFilterCell" bundle:nil] forCellWithReuseIdentifier:@"AliyunEffectFilterFuncCell"];
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    _collectionView.delegate = (id<UICollectionViewDelegate>)self;
    [self addSubview:_collectionView];
    
}


- (void)reloadDataWithEffectType:(NSInteger)eType {
    _effectType = eType;
    [_dataArray removeAllObjects];

    __block BOOL isNewSelectIndex = NO;
    [_dbHelper queryResourceWithEffecInfoType:eType success:^(NSArray *infoModelArray) {
        for (AliyunEffectMvGroup *mvGroup in infoModelArray) {
            [_dataArray addObject:mvGroup];
           
                if (_selectedEffect) {
                    if (mvGroup.eid == _selectedEffect.eid) {
                        NSInteger idx= [infoModelArray indexOfObject:mvGroup] + 1;
                        if (idx != _selectIndex) {
                            isNewSelectIndex = YES;
                            _selectIndex = idx;
                        }
                    }
                }
            
        }
        if (eType == AliyunEffectTypeMV) {
            [self insertDataArray];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (_selectIndex >= 0 && isNewSelectIndex) {
                [_collectionView.delegate collectionView:_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:_selectIndex inSection:0]];
            }
            
            [_collectionView reloadData];
        });
    } failure:^(NSError *error) {
        
    }];
}

- (void)reloadDataWithEffectTypeWithDelete:(NSInteger)eType {
    _effectType = eType;
    [_dataArray removeAllObjects];
    
    __block BOOL isNewSelectIndex = NO;
    [_dbHelper queryResourceWithEffecInfoType:eType success:^(NSArray *infoModelArray) {
        for (AliyunEffectMvGroup *mvGroup in infoModelArray) {
            [_dataArray addObject:mvGroup];
            
            if (_selectedEffect) {
                if (mvGroup.eid == _selectedEffect.eid) {
                    NSInteger idx= [infoModelArray indexOfObject:mvGroup] + 1;
                    if (idx != _selectIndex) {
                        isNewSelectIndex = YES;
                        _selectIndex = idx;
                    }
                }
            }
            
        }
        if (eType == AliyunEffectTypeMV) {
            [self insertDataArray];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_collectionView reloadData];
        });
    } failure:^(NSError *error) {
        
    }];
}
/**
 插入原片和更多数据
 */
- (void)insertDataArray {
    
    AliyunEffectInfo *effctMore = [[AliyunEffectInfo alloc] init];
    effctMore.name = @"更多";
    effctMore.eid = -1;
    effctMore.effectType = AliyunEffectTypeMV;
    effctMore.icon = @"shortVideo_edit_more";
    [_dataArray addObject:effctMore];
    
    
    AliyunEffectInfo *effctNone = [[AliyunEffectInfo alloc] init];
    effctNone.name = @"原片";
    effctNone.eid = -1;
    effctNone.effectType = AliyunEffectTypeMV;
    effctNone.icon = @"shortVideo_edit_mvDefault";
    effctNone.resourcePath = nil;
    [_dataArray insertObject:effctNone atIndex:0];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AliyunEffectFilterCell *cell = [[AliyunEffectFilterCell alloc] init];
    
    if (indexPath.row == 0 || indexPath.row == _dataArray.count - 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectFilterFuncCell" forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectFilterCell" forIndexPath:indexPath];
    }
    
    AliyunEffectInfo *effectInfo = _dataArray[indexPath.row];
    [cell cellModel:effectInfo];
    if (indexPath.row == _selectIndex) {
        [cell setSelected:YES];
    }else{
        [cell setSelected:NO];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AliyunEffectFilterCell *lastSelectCell = (AliyunEffectFilterCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectIndex inSection:0]];
    [lastSelectCell setSelected:NO];
    
    AliyunEffectInfo *currentEffect = _dataArray[indexPath.row];
     if (_effectType == AliyunEffectTypeMV) {
        if ([currentEffect.name isEqualToString:@"更多"]) {

            [collectionView reloadData];
            [_delegate didSelectEffectMoreMv];
            
            return;
        }
        _selectIndex = indexPath.row;
        if (indexPath.row == 0) {
            _selectedEffect = nil;
            [_delegate didSelectEffectMV:nil];
            return;
        }

        
        _selectedEffect = currentEffect;
        
        [_delegate didSelectEffectMV:(AliyunEffectMvGroup *)currentEffect];
        [collectionView reloadData];
    }
}



@end
