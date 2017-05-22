//
//  XMGameVC.m
//  零派socket
//
//  Created by RenXiangDong on 2017/5/17.
//  Copyright © 2017年 RenXiangDong. All rights reserved.
//
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#import "XMGameVC.h"
#import "XMUserTool.h"
#import "MBProgressHUD+MJ.h"
#import <MJExtension.h>
#import "XMSocketManager.h"


typedef NS_ENUM(NSUInteger, GameProgress) {
    GameProgress_RoomNotFull,//人不全
    GameProgress_RoomFull,//人刚刚全了
    GameProgress_PayFinish,//平家全都下注完成
    GameProgress_OwnerStarted,//庄家开牌完成
    GameProgress_GameOver//游戏结束
};
@interface XMGameVC ()<UIActionSheetDelegate,XMSocketManagerDelegate>
/* 我的信息 */
@property (weak, nonatomic) IBOutlet UILabel *myUseID;
@property (weak, nonatomic) IBOutlet UILabel *myMoney;
@property (weak, nonatomic) IBOutlet UILabel *myStatus;
@property (weak, nonatomic) IBOutlet UILabel *myFirstCard;
@property (weak, nonatomic) IBOutlet UILabel *mySecondCard;
@property (weak, nonatomic) IBOutlet UILabel *payMoney;
@property (weak, nonatomic) IBOutlet UIView *myFirstCardBg;
@property (weak, nonatomic) IBOutlet UIView *mySecondCardBg;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIButton *begainButton;
@property (weak, nonatomic) IBOutlet UIImageView *myOwnerImage;

@property (weak, nonatomic) IBOutlet UIView *startButtonBg;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (nonatomic, assign) int selectMoney;//选择的押注金额
@property (nonatomic, assign) BOOL isPayLock;//我下注锁定
@property (weak, nonatomic) IBOutlet UIView *leftCardBg;


/* 左边小人 */
@property (weak, nonatomic) IBOutlet UILabel *leftUserID;
@property (weak, nonatomic) IBOutlet UILabel *leftMoney;
@property (weak, nonatomic) IBOutlet UILabel *leftStatus;
@property (weak, nonatomic) IBOutlet UIView *leftFirstCardBg;
@property (weak, nonatomic) IBOutlet UIView *leftSecondCardBg;
@property (weak, nonatomic) IBOutlet UIImageView *leftOwnerImage;
@property (weak, nonatomic) IBOutlet UILabel *leftPayMoney;


/* 右边小人 */
@property (weak, nonatomic) IBOutlet UILabel *rightUserID;
@property (weak, nonatomic) IBOutlet UILabel *rightMoney;
@property (weak, nonatomic) IBOutlet UILabel *rightStatus;
@property (weak, nonatomic) IBOutlet UIView *rightFirstCardBg;
@property (weak, nonatomic) IBOutlet UIView *rightSecondCardBg;
@property (weak, nonatomic) IBOutlet UIImageView *rightOwnerImage;
@property (weak, nonatomic) IBOutlet UILabel *rightPayMoney;


/* 全局 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moneyTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moneyBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightMoneyTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightMoneyBottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightRight;
/* 数据类 */
@property (nonatomic, weak) XMUserTool *userTool;
@property (nonatomic, strong) XMSocketManager *socketManager;
@property (nonatomic, assign) GameProgress gameProgress;//游戏进度

@property (nonatomic, strong) NSTimer *putCardTimer;
@property (nonatomic, strong) NSArray *cardBgs;
@property (nonatomic, assign)int putCardIndex;
/* 提示点击开始下一局 */
@property (weak, nonatomic) IBOutlet UILabel *nextPartLabel;
@property (nonatomic, strong) CAGradientLayer *griLayer;
@property (nonatomic, strong) CABasicAnimation *animation;
@property (nonatomic, assign) BOOL canEnterNextPart;//是否可玩下局
@property (nonatomic, assign) BOOL canTouchRestart;
@end

@implementation XMGameVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.userTool reloadUser];
    self.socketManager = [XMSocketManager share];
    self.socketManager.delegate = self;
    self.userTool = [XMUserTool share];
    [self prepareUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftUserComing) name:kLeftUserComming object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightUserComing) name:kRightUserComming object:nil];
}

- (void)prepareUI {
    if (self.userTool.leftUser == nil) {
        self.leftLeft.constant = -250;
    }
    if (self.userTool.rightUser == nil) {
        self.rightRight.constant = -250;
    }
    if (kScreenHeight == 320) {
        self.moneyTop.constant = 5;
        self.moneyBottom.constant = 5;
        self.rightMoneyTop.constant = 5;
        self.rightMoneyBottom.constant = 5;
        [self.view layoutIfNeeded];
    }
    [self cardRevert:self.myFirstCardBg animation:NO];
    [self cardRevert:self.mySecondCardBg animation:NO];
    [self cardRevert:self.leftFirstCardBg animation:NO];
    [self cardRevert:self.leftSecondCardBg animation:NO];
    [self cardRevert:self.rightFirstCardBg animation:NO];
    [self cardRevert:self.rightSecondCardBg animation:NO];
    [self reloadUserOnSeat];
    self.gameProgress = self.userTool.rightUser == nil?GameProgress_RoomNotFull:GameProgress_RoomFull;
    [self startButtonEnable:NO];
}
/* 刷新在座的状态信息 */
- (void)reloadUserOnSeat {
    XMUserModel *myUser = self.userTool.myUser;
    UIColor *green = [UIColor greenColor];
    UIColor *red = [UIColor redColor];
    if (myUser != nil) {
        self.myUseID.text = myUser.user_id;
        self.myMoney.text = myUser.money;
        self.myOwnerImage.hidden = !myUser.isOwner;
        self.startButtonBg.hidden = !myUser.isOwner;
        if (self.gameProgress == GameProgress_GameOver) {
            self.myStatus.text = myUser.result.intValue > 0?@"赢":@"输";
            self.myStatus.textColor = myUser.result.intValue > 0?green:red;
        } else {
            self.myStatus.text = myUser.payMoney == nil?@"未下注":@"已下注";
            self.myStatus.textColor = myUser.payMoney == nil?red:green;
        }
        if (myUser.cards.count == 2) {
            self.myFirstCardBg.tag = [myUser.cards[0] intValue];
            self.mySecondCardBg.tag = [myUser.cards[1] intValue];
        }
    }
    XMUserModel *leftUser = self.userTool.leftUser;
    if (leftUser != nil) {
        self.leftUserID.text = leftUser.user_id;
        self.leftMoney.text = leftUser.money;
        self.leftOwnerImage.hidden = !leftUser.isOwner;
        self.leftPayMoney.text = leftUser.formatPayMoney;
        if (self.gameProgress == GameProgress_GameOver) {
            self.leftStatus.text = leftUser.result.intValue > 0?@"赢":@"输";
            self.leftStatus.textColor = leftUser.result.intValue > 0?green:red;
        } else {
            self.leftStatus.text = leftUser.payMoney == nil?@"未下注":@"已下注";
            self.leftStatus.textColor = leftUser.payMoney == nil?red:green;
        }
        if (leftUser.cards.count == 2) {
            self.leftFirstCardBg.tag = [leftUser.cards[0] intValue];
            self.leftSecondCardBg.tag = [leftUser.cards[1] intValue];
        }
    }
    XMUserModel *rightUser = self.userTool.rightUser;
    if (rightUser != nil) {
        self.rightUserID.text = rightUser.user_id;
        self.rightMoney.text = rightUser.money;
        self.rightOwnerImage.hidden = !rightUser.isOwner;
        self.rightStatus.text = rightUser.payMoney == nil?@"未下注":@"已下注";
        self.rightPayMoney.text = rightUser.formatPayMoney;
        
        if (self.gameProgress == GameProgress_GameOver) {
            self.rightStatus.text = rightUser.result.intValue > 0?@"赢":@"输";
            self.rightStatus.textColor = rightUser.result.intValue > 0?green:red;
        } else {
            self.rightStatus.text = rightUser.payMoney == nil?@"未下注":@"已下注";
            self.rightStatus.textColor = rightUser.payMoney == nil?red:green;
        }
        self.rightPayMoney.text = rightUser.formatPayMoney;
        if (rightUser.cards.count == 2) {
            self.rightFirstCardBg.tag = [rightUser.cards[0] intValue];
            self.rightSecondCardBg.tag = [rightUser.cards[1] intValue];
        }
    }
}


#pragma mark - Event
- (IBAction)payAction:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择下注金额" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"5元",@"10元",@"20元", nil];
    [sheet showInView:self.view];
    
}
/* 确定下注 */
- (IBAction)beigainAction:(id)sender {
    NSString *roomID = self.userTool.room_id;
    NSString *userID = self.userTool.myUser.user_id;
    NSString *moneyStr = [NSString stringWithFormat:@"%d",self.selectMoney];
    [self.socketManager sendDict:@{@"type":@"pay",
                                   @"room_id":roomID,
                                   @"user_id":userID,
                                   @"money":moneyStr}];
    [self begainButtonEnable:NO];
    [self payButtongEnable:NO];
}

/* 庄家开始发牌 */
- (IBAction)ownerStartAction:(id)sender {
    NSString *roomID = self.userTool.room_id;
    NSString *userID = self.userTool.myUser.user_id;
    [self.socketManager sendDict:@{@"type":@"deal",
                                   @"room_id":roomID,
                                   @"user_id":userID}];
    [self startButtonEnable:NO];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            self.selectMoney = 5;
            break;
        case 1:
            self.selectMoney = 10;
            break;
        case 2:
            self.selectMoney = 20;
            break;
        default:
            break;
    }
}
/* 筒子翻转 */
- (void)cardRevert:(UIView *)card animation:(BOOL)animate {
    if (animate) {
        [UIView animateWithDuration:0.5 animations:^{
            card.layer.transform = CATransform3DRotate(card.layer.transform, M_PI_2, 0, 1, 0);
        } completion:^(BOOL finished) {
            NSString *imageName = [NSString stringWithFormat:@"%ld",(long)card.tag];
            [card setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:imageName]]];
            [UIView animateWithDuration:0.5 animations:^{
                card.layer.transform = CATransform3DRotate(card.layer.transform, M_PI_2, 0, 1, 0);
            } completion:^(BOOL finished) {
                if (self.gameProgress != GameProgress_GameOver) {
                    self.gameProgress = GameProgress_GameOver;
                    [self reloadUserOnSeat];
                }
            }];
        }];
    } else {
        card.layer.transform = CATransform3DRotate(card.layer.transform, M_PI, 0, 1, 0);
        card.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CardBg"]] ;
        card.contentMode = UIViewContentModeScaleAspectFit;
        for (UIView *subView in card.subviews) {
            subView.alpha = 0;
        }
        card.hidden= YES;
    }
}

/* 有人刚刚进入 */
- (void)leftUserComing {
    if (self.userTool.leftUser != nil) {
        [UIView animateWithDuration:0.7 animations:^{
            self.leftLeft.constant = 0;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)rightUserComing {
    if (self.userTool.rightUser != nil) {
        [UIView animateWithDuration:0.7 animations:^{
            self.rightRight.constant = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.gameProgress = GameProgress_RoomFull;
        }];
    }
}

/* socket代理 */
#pragma mark - 收到socket信息
- (void)SocketManagerDidReceiveDict:(NSDictionary *)dict {
    NSString *type = dict[@"type"];
    if ([type isEqualToString:@"start"]) {
        NSArray *users = dict[@"users"];
        NSArray *userModels = [XMUserModel mj_objectArrayWithKeyValuesArray:users];
        [[XMUserTool share].users removeAllObjects];
        [[XMUserTool share].users addObjectsFromArray:userModels];
        [[XMUserTool share] reloadUser];
        [self reloadUserOnSeat];
    } else if ([type isEqualToString:@"pay"]) {
        NSString *userID = dict[@"user_id"];
        NSString *money = dict[@"money"];
       BOOL isPayFinish = [self.userTool payMoney:money withUserID:userID];
        if (isPayFinish) {
            [self startButtonEnable:YES];
            self.gameProgress = GameProgress_PayFinish;
        }
        [self reloadUserOnSeat];
    } else if ([type isEqualToString:@"over"]) {
        self.gameProgress = GameProgress_OwnerStarted;
        self.canEnterNextPart = [dict[@"is_over"] isEqualToString:@"0"];
        NSArray *tmpArray = dict[@"users"];
        [self.userTool putCardsWithArray:tmpArray];
        [self initPutCarsAction];
    }
}

- (void)payButtongEnable:(BOOL)enable {
    self.payButton.enabled = enable;
    self.payButton.backgroundColor = enable?[UIColor colorWithRed:43/255.0 green:191/255.0 blue:191/255.0 alpha:1]:[UIColor grayColor];
}

- (void)begainButtonEnable:(BOOL)enable {
    self.begainButton.enabled = enable;
    self.begainButton.backgroundColor = enable?[UIColor colorWithRed:1.0 green:114/255.0 blue:0 alpha:1]:[UIColor grayColor];
}

- (void)startButtonEnable:(BOOL)enable {
    self.startButton.enabled = enable;
    self.startButton.backgroundColor = enable?[UIColor colorWithRed:1.0 green:114/255.0 blue:0 alpha:1]:[UIColor grayColor];
}

#pragma mark - Getter & Setter
- (void)setGameProgress:(GameProgress)gameProgress {
    switch (gameProgress) {
        case GameProgress_RoomNotFull: {
            [self payButtongEnable:NO];
            [self begainButtonEnable:NO];
        }
            break;
        case GameProgress_RoomFull: {
                [self payButtongEnable:YES];
                self.selectMoney = 5;
        }
            break;
        case GameProgress_PayFinish: {
            NSLog(@"平家都押注完了");
            
        }
            break;
        case GameProgress_OwnerStarted: {
            NSLog(@"庄家发牌完成");
        }
            break;
        case GameProgress_GameOver: {
            [self performSelector:@selector(showTouchReset) withObject:nil afterDelay:3];
        }
            break;
            
        default:
            break;
    }
    _gameProgress = gameProgress;
}

- (void)showTouchReset {
    self.nextPartLabel.alpha = 0;
    self.nextPartLabel.hidden = NO;
    
    [UIView animateWithDuration:1 animations:^{
        self.nextPartLabel.alpha = 1;
    } completion:^(BOOL finished) {
        self.nextPartLabel.layer.mask = self.griLayer;
        self.canTouchRestart = YES;
    }];
}

/* 选择押注金额 */
- (void)setSelectMoney:(int)selectMoney {
    _selectMoney = selectMoney;
    self.payMoney.text = [NSString stringWithFormat:@"%d元",self.selectMoney];
    int myMoney = [self.userTool.myUser.money intValue];
    if (myMoney >= self.selectMoney) {
        [self begainButtonEnable:YES];
    } else {
        [self begainButtonEnable:NO];
    }
}
/* 发单张牌 */
- (void)putCard:(UIView *)card {
    CGRect endFrame = [card.superview convertRect:card.frame toView:self.view];
    CGFloat W = 50;
    CGFloat H = 68;
    CGFloat X = (kScreenWidth - W) * 0.5;
    CGFloat Y = (kScreenHeight - 100 - H) * 0.5;
    UIView *tmpCard = [[UIView alloc] initWithFrame:CGRectMake(X, Y, W, H)];
    tmpCard.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CardBg"]];
    tmpCard.contentMode = UIViewContentModeScaleAspectFit;
    tmpCard.layer.cornerRadius = 5;
    tmpCard.layer.masksToBounds = YES;
    [self.view addSubview:tmpCard];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:1 animations:^{
        tmpCard.frame = endFrame;
    } completion:^(BOOL finished) {
        [tmpCard removeFromSuperview];
        card.hidden = NO;
    }];
}
/* 全体发牌 */
- (void)initPutCarsAction {
    self.cardBgs = @[self.leftFirstCardBg,self.leftSecondCardBg,self.myFirstCardBg,self.mySecondCardBg,self.rightFirstCardBg,self.rightSecondCardBg];
    self.putCardIndex = 0;
    self.putCardTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(putCardsAction) userInfo:nil repeats:YES];
    [self.putCardTimer fire];
}
                         
 - (void)putCardsAction {
     if (self.putCardIndex < self.cardBgs.count) {
         [self putCard:self.cardBgs[self.putCardIndex]];
         self.putCardIndex ++;
     } else {
         [self.putCardTimer invalidate];
         self.putCardTimer = nil;
         [self reloadCardsOnSeat];
         [self allUserRevertCards];
     }
 }
- (void)reloadCardsOnSeat {
    XMUserModel *myUser = self.userTool.myUser;
    if (myUser != nil) {
        if (myUser.cards.count == 2) {
            self.myFirstCardBg.tag = [myUser.cards[0] intValue];
            self.mySecondCardBg.tag = [myUser.cards[1] intValue];
        }
    }
    XMUserModel *leftUser = self.userTool.leftUser;
    if (leftUser != nil) {
        if (leftUser.cards.count == 2) {
            self.leftFirstCardBg.tag = [leftUser.cards[0] intValue];
            self.leftSecondCardBg.tag = [leftUser.cards[1] intValue];
        }
    }
    XMUserModel *rightUser = self.userTool.rightUser;
    if (rightUser != nil) {
        if (rightUser.cards.count == 2) {
            self.rightFirstCardBg.tag = [rightUser.cards[0] intValue];
            self.rightSecondCardBg.tag = [rightUser.cards[1] intValue];
        }
    }

}
/* 全体翻牌 */
- (void)allUserRevertCards {
    [self cardRevert:self.myFirstCardBg animation:YES];
    [self cardRevert:self.mySecondCardBg animation:YES];
    [self cardRevert:self.leftFirstCardBg animation:YES];
    [self cardRevert:self.leftSecondCardBg animation:YES];
    [self cardRevert:self.rightFirstCardBg animation:YES];
    [self cardRevert:self.rightSecondCardBg animation:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.gameProgress == GameProgress_GameOver  && self.canTouchRestart) {
        if (self.canEnterNextPart) {
            self.gameProgress = GameProgress_RoomFull;
            self.nextPartLabel.alpha = 0;
            [self.userTool resetUsers];
            [self reloadUserOnSeat];
            for (UIView *card in self.cardBgs) {
                card.hidden = YES;
            }
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        
    }
}

- (CAGradientLayer *)griLayer {
    if (!_griLayer) {
        _griLayer = [[CAGradientLayer alloc] init];
        
        _griLayer.colors = @[(__bridge id)[UIColor blackColor].CGColor,(__bridge id)[UIColor colorWithWhite:1 alpha:0.3].CGColor,(__bridge id)[UIColor blackColor].CGColor];
        _griLayer.frame = _nextPartLabel.bounds;
        _griLayer.startPoint = CGPointMake(0, 0.5);
        _griLayer.endPoint = CGPointMake(1, 0.5);
        _griLayer.locations = @[@0, @0.15, @0.3];
        [_griLayer addAnimation:self.animation forKey:nil];
    }
    return _griLayer;
}

- (CABasicAnimation *)animation {
    if (!_animation) {
        _animation = [[CABasicAnimation alloc] init];
        _animation.keyPath = @"locations";
        _animation.fromValue = @[@0,@(0.15),@(0.3)];
        _animation.toValue = @[@0.7,@0.85,@1.0];
        _animation.repeatCount = NSIntegerMax;
        _animation.duration = 2;
        _animation.removedOnCompletion = NO;
        
    }
    return _animation;
}

@end
