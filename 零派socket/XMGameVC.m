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


/* 左边小人 */
@property (weak, nonatomic) IBOutlet UILabel *leftUserID;
@property (weak, nonatomic) IBOutlet UILabel *leftMoney;
@property (weak, nonatomic) IBOutlet UILabel *leftStatus;
@property (weak, nonatomic) IBOutlet UIView *leftFirstCardBg;
@property (weak, nonatomic) IBOutlet UIView *leftSecondCardBg;
@property (weak, nonatomic) IBOutlet UIImageView *leftOwnerImage;


/* 右边小人 */
@property (weak, nonatomic) IBOutlet UILabel *rightUserID;
@property (weak, nonatomic) IBOutlet UILabel *rightMoney;
@property (weak, nonatomic) IBOutlet UILabel *rightStatus;
@property (weak, nonatomic) IBOutlet UIView *rightFirstCardBg;
@property (weak, nonatomic) IBOutlet UIView *rightSecondCardBg;
@property (weak, nonatomic) IBOutlet UIImageView *rightOwnerImage;


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


@end

@implementation XMGameVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
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
}
/* 刷新在座的状态信息 */
- (void)reloadUserOnSeat {
    XMUserModel *myUser = self.userTool.myUser;
    if (myUser != nil) {
        self.myUseID.text = myUser.user_id;
        self.myMoney.text = myUser.money;
        self.myOwnerImage.hidden = !myUser.isOwner;
    }
    XMUserModel *leftUser = self.userTool.leftUser;
    if (leftUser != nil) {
        self.leftUserID.text = leftUser.user_id;
        self.leftMoney.text = leftUser.money;
        self.leftOwnerImage.hidden = !leftUser.isOwner;
    }
    XMUserModel *rightUser = self.userTool.rightUser;
    if (rightUser != nil) {
        self.rightUserID.text = rightUser.user_id;
        self.rightMoney.text = rightUser.money;
        self.rightOwnerImage.hidden = !rightUser.isOwner;
    }
}


#pragma mark - Event
- (IBAction)payAction:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择下注金额" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"5元",@"10元",@"20元", nil];
    [sheet showInView:self.view];
    
}
- (IBAction)beigainAction:(id)sender {
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            self.payMoney.text = @"5元";
            break;
        case 1:
            self.payMoney.text = @"10元";
            break;
        case 2:
            self.payMoney.text = @"20元";
            break;
        default:
            break;
    }
}
/* 筒子翻转 */
- (void)cardRevert:(UIView *)card animation:(BOOL)animate {
    if (animate) {
        [UIView animateWithDuration:1 animations:^{
            card.layer.transform = CATransform3DRotate(card.layer.transform, M_PI, 0, 1, 0);
            card.backgroundColor = [UIColor whiteColor];
            for (UIView *subView in card.subviews) {
                subView.alpha = 1;
            }
        } completion:^(BOOL finished) {
            
        }];
    } else {
        card.layer.transform = CATransform3DRotate(card.layer.transform, M_PI, 0, 1, 0);
        card.backgroundColor = [UIColor greenColor];
        for (UIView *subView in card.subviews) {
            subView.alpha = 0;
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
        }];
    }
}

/* socket代理 */
- (void)SocketManagerDidReceiveDict:(NSDictionary *)dict {
    NSString *type = dict[@"type"];
    if ([type isEqualToString:@"start"]) {
        NSArray *users = dict[@"users"];
        NSArray *userModels = [XMUserModel mj_objectArrayWithKeyValuesArray:users];
        [[XMUserTool share].users removeAllObjects];
        [[XMUserTool share].users addObjectsFromArray:userModels];
        [[XMUserTool share] reloadUser];
        [self reloadUserOnSeat];
    }
}

@end
