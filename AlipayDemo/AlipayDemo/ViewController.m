//
//  ViewController.m
//  AlipayDemo
//
//  Created by Edwin on 16/2/16.
//  Copyright © 2016年 EdwinXiang. All rights reserved.
//

#import "ViewController.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "payApiRequestHandler.h"
#import "WXApiObject.h"
#define WX_NOTIFY_KEY @"weixin"
#define PayUrl @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php?plat=ios"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)alipayBtn:(id)sender {
    
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    /**
     可以改，改成自己公司的账号
     */
    NSString *partner = @"2088801142678498";//商户账号，企业申请资质的时候支付宝给分配的
    /**
     可以改，改成自己公司的支付宝账号
     */
    NSString *seller = @"lisa@newv.com.cn";//公司的收款支付宝账号
    /**
     可以改，改成自己公司的私钥
     */
    //私钥，用来加密订单的
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKADO4HcskWfaWCSLSdCqPMWymC2m3paALX6jVjpz/eIFajO/hbOec1IZB8yLImClKTyke9kGy2IwVSt1QNugxx/u6lUEoE6LeO2LKR37YnopdgKxXVITX5Ymn0yJdI3WWFiqfcFXzAHq3D5Il9zfTVRyOTHfRTC05EML7F1hV/1AgMBAAECgYBeUKlxqQk3OngdYOvWeVcmOae+C8RnAMfse6t23hIkAAVsQ93GyZtHocTKEoPn5Z0CAKx+I05Vr4btB61H4YrLga89mbXjP+YoYejNRVoZBjEpkf7NgMh7ScQIhx3hHk2IuCO6syz/cR5zNWpK47gMSWtS3/xoWjX9aicKcsTNgQJBANQd3qZZeo1XTi4qugp8AAvCwsy4IGM1LztahKIll+XMTLHxF6e5WTEQTuRe6fQzfbP7emNX3aAwqLRhgez+hmECQQDBHdOGsuqGQkes1VO9C9zEOegjEgv+Dzxq3Wj8AeVzO4idUJ2Gl6IV4EWflev9kZGX6CXFjJ3RngM6dsoejpoVAkEAj36Rc7mOhXVtZx/ycUtHgK1FuNZK2rJM/HsUxNhntMaLj8kIdqeVpfJhXG61GEWJISvbtL7pKAgi6LwZ9+iLoQJAWO5HTqxt284B+9FxcolX7PVNtXjGFQUnKX80rXiiFWLBEtDg+e4yMijJZyg/ONIkXfQGEOckdjdx/SZfBZtd0QJAPL0+YBO5Bvbb4/VRIeoww+4pAd46f9Ews0a0gYjOrTL+tNomvVet92HgJJQIEIoLbqh4NTDJDFgC8rmh7UBeSg==";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    /**
     订单号要服务器给，需要根据接口来
     */
    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定,服务器给）
    /**
     可以改，改成自己公司的产品名字
     */
    order.productName = @"茅台"; //商品标题
    /**
     可以改，改成自己公司的产品描述
     */
    order.productDescription = @"70年茅台"; //商品描述
    /**
     可以改，改成自己公司规定的价格
     */
    order.amount = @"0.01"; //商品价格
    /**
     可以改，改成自己公司的回调url，服务器给
     */
    order.notifyURL =  @"http://www.xxx.com"; //回调URL,服务器给
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    /**
     可以改，改成自己公司的scheme
     */
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"alisdkdemo";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
    
}
- (IBAction)weixinPayBtn:(id)sender {
    
        
        if (![WXApi isWXAppInstalled]) {
            NSLog(@"没有安装微信客户端");
            return;
        }
        NSString *res = [payApiRequestHandler jumpToBizPay];
        if( ![@"" isEqual:res] ){
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"支付失败" message:res delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alter show];
        }else{
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"支付成功" message:res delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alter show];
        }
}

//#pragma mark 微信支付成功通知
//-(void)payWxResultOpt:(NSNotification *)notification
//{
////    SumbitOrderModel *model = [_sumbitArr lastObject];
//    //这里是支付结果
//    PayResp *response = (PayResp*)notification.object;
//    if (response.errCode == WXSuccess) {
//        
//        //        PayForResultsVC *view = [[PayForResultsVC alloc]init];
//        //        view.orderStr = [NSString stringWithFormat:@"订单号：%ld",model.order_sn];
//        //        view.is_succeed = 1;
//        //        [self.navigationController pushViewController:view animated:YES];
//        NSLog(@"支付成功");
//    }
//    else
//    {
//        
//        //        PayForResultsVC *view = [[PayForResultsVC alloc]init];
//        //        view.is_succeed = response.errCode;
//        //        [self.navigationController pushViewController:view animated:YES];
//        NSLog(@"支付失败");
//    }
//}
- (NSString *)generateTradeNO{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
