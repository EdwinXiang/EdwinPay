//
//  payApiRequestHandler.h
//  Pay
//
//  Created by Edwin on 16/2/16.
//  Copyright © 2016年 Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface payApiRequestHandler : NSObject
/**
 *  微信支付
 *
 *  @return 支付结果
 */
+ (NSString *)jumpToBizPay;
@end
