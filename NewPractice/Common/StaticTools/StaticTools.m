//
//  StaticTools.m
//  MLife
//
//  Created by user on 11-8-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StaticTools.h"
#import <QuartzCore/QuartzCore.h>
#import "zlib.h"
#import <objc/runtime.h>// 导入运行时文件
#import <sys/utsname.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "NSDictionary+NULLObject.h"
#import "HttpDefine.h"

#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define screenProportion  [UIScreen mainScreen].bounds.size.width/320
#define screenProportionNew  [UIScreen mainScreen].bounds.size.width/375

@implementation StaticTools

#define TEXT_COLOR_GRAY0	 [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0]


//获取当前语言环境
+(NSString*)deviceLanguages {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
}

//校验字符串是否为空
+(BOOL)isEmptyString:(NSString*)string {
    if (string == nil) return YES;
    //去空格之后判断length是否为0
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString* content = [string stringByTrimmingCharactersInSet:whitespace];
    if ([content length] == 0) return YES;
    
    return NO;
}

+ (void)saveFile:(NSMutableArray *)array
        fileName:(NSString *)fileName
{
    if ([array count] == 0 || !array)
        return;
    
    //往document里写文件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",fileName]];
    [array writeToFile:writePath atomically:YES];
}

//检查Documents里是否有此文件
+ (BOOL)fileExistsAtPath:(NSString *)fileName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *DocumentsPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return [fileManager fileExistsAtPath:DocumentsPath];
}

+ (NSString *)getFilePath:(NSString *)fileName {
    if ([fileName length] == 0) {
        return @"";
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *DocumentsPath = [documentsDirectory stringByAppendingPathComponent:@"cached_img"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:DocumentsPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:DocumentsPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    DocumentsPath = [DocumentsPath stringByAppendingPathComponent:fileName];
    return DocumentsPath;
}
+ (NSString *)getShoppingCartFilePath:(NSString *)fileName {
    if ([fileName length] == 0) {
        return @"";
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *DocumentsPath = [documentsDirectory stringByAppendingPathComponent:@"shoppingCart"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:DocumentsPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:DocumentsPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    DocumentsPath = [DocumentsPath stringByAppendingPathComponent:fileName];
    return DocumentsPath;
}

//判断是否超过规定时间 add by zhangke 2013424
+ (BOOL)OutofDate:(NSTimeInterval)anotherDate userDefined:(NSTimeInterval)timerInterval{
    
    NSTimeInterval nowDate = [[NSDate date] timeIntervalSinceReferenceDate];
    
    NSTimeInterval exDate=nowDate - anotherDate;//两个时间的差
    
    //    NSLog(@"da %f",exDate);
    //    NSLog(@"nowDate %f",nowDate);
    
    if (exDate > timerInterval) {
        return NO;
    }
    return YES;
}

//获取临时文件大小 added by yaozhaofeng 20120630
+(void)getCacheSize:(void (^)(unsigned long long int))sizeBlock
{
    unsigned long long int plistSize = 0;
    unsigned long long int imgSize = 0;
    unsigned long long int folderSize = 0;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    
    
    NSString *plistPath = [docPaths stringByAppendingPathComponent:@"cacheArray.plist"];
    NSDictionary *arrayAttributes = [manager attributesOfItemAtPath:plistPath error:nil];
    if ([manager fileExistsAtPath:plistPath]) {
        plistSize = [arrayAttributes fileSize];
    }
    
    NSString *imgPath = [docPaths stringByAppendingPathComponent:@"cached_img"];
    
    if ([manager fileExistsAtPath:imgPath]) {
        NSEnumerator *fileEnumerator = [[manager subpathsAtPath:imgPath] objectEnumerator];
        NSString *fileName;
        while ((fileName = [fileEnumerator nextObject])!=nil) {
            NSString *filePath = [imgPath stringByAppendingPathComponent:fileName];
            NSDictionary *fileAttributes = [manager attributesOfItemAtPath:filePath error:nil];
            imgSize += [fileAttributes fileSize];
        }
    }

    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    if (![manager fileExistsAtPath:cachePath]) {
        folderSize = 0;//文件夹不存在返回0
    } else {
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:cachePath] objectEnumerator];//枚举器
        NSString *fileName;
        while ((fileName = [childFilesEnumerator nextObject]) != nil){
            NSString* fileAbsolutePath = [cachePath stringByAppendingPathComponent:fileName];
            folderSize += [[manager attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
        }
    }
    
    sizeBlock(plistSize + imgSize + folderSize);
    
}

+ //清除默认列表数据
(void)cleanCacheArray{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *DocumentsPath = [documentsDirectory stringByAppendingPathComponent:@"cacheArray.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:DocumentsPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:DocumentsPath error:nil];
    }
}

+ (void)cleanCacheImg:(void (^) (BOOL))completion {
    
    dispatch_async(dispatch_queue_create("com.image", DISPATCH_QUEUE_SERIAL), ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *DocumentsPath = [documentsDirectory stringByAppendingPathComponent:@"cached_img"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:DocumentsPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:DocumentsPath error:nil];
        }
        
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSEnumerator *filesEnumerator = [[manager subpathsAtPath:path] objectEnumerator];//枚举 caches下所有文件路径
        NSString *filePath;//文件名
        while ((filePath = [filesEnumerator nextObject]) != nil) {
            NSString *string = [path stringByAppendingPathComponent:filePath];
            [manager removeItemAtPath:string error:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(YES);
        });
        
    });
    
}


//删除用户的购物车数据
+ (void)cleanShoppinCartCache:(NSString *)plistName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *DocumentsPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"shoppingCart/%@",plistName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:DocumentsPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:DocumentsPath error:nil];
    }
}

//网上预约 登录页面 生成随机验证码
+ (NSString *)randomCode:(int)codeLength{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *radomString = [(NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj)) substringToIndex:codeLength];
    CFRelease(uuidObj);
    return radomString;
}

//判断邮政编码格式是否正确
+ (BOOL)checkZipCode:(NSString *)coder{
    if(coder.length != 6) return NO;
    
    NSError *error = NULL;
    NSString *ruleString = @"[0-9]\\d{5}(?!\\d)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:ruleString
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:coder
                                                        options:0
                                                          range:NSMakeRange(0, [coder length])];
    if(numberOfMatches == 1)
        return YES;
    else
        return NO;
}

//航空会员号检验
+ (BOOL)checkAirMemberNo:(NSString *)memberNo airCode:(NSString *)airCode{
    if(memberNo.length == 0)
        return NO;
    NSError *error = NULL;
    NSString *ruleString = @"";
    int length = (int)memberNo.length;
    if ([airCode isEqualToString:@"GH"]) {
        //modify by ly 20130829
        //        if(length != 11 ) return NO;
        if(!(length == 11 ||length == 14)) return NO;
        //m_zhanggaofeng20130812 修改航空会员号校验规则
        //		ruleString = @"^[CA]+\\d{9}";
        ruleString = @"^CA(\\d{9}|\\d{12})$";
    }
    else if ([airCode isEqualToString:@"NH"]) {
        if(length != 12) return NO;
        ruleString = @"\\d{12}";
    }
    else if ([airCode isEqualToString:@"DH"]) {
        if(!(length == 12 || length == 9)) return NO;
        ruleString = @"\\d{9}|\\d{12}";
    }
    else if ([airCode isEqualToString:@"SH"]) {
        if(length != 9) return NO;
        ruleString = @"\\d{9}";
    }
    else if ([airCode isEqualToString:@"HH"]) {
        if(length != 10) return NO;
        ruleString = @"\\d{10}";
    }
    else return YES;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:ruleString
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:memberNo
                                                        options:0
                                                          range:NSMakeRange(0, [memberNo length])];
    if(numberOfMatches == 1)
        return YES;
    else
        return NO;
}

//判断输入是否全部都是字符（不允许有汉字、数字等） 不能为空
+ (BOOL)checkAllIsLetter:(NSString *)psw{
    BOOL hasOther = NO;
    
    int length = (int)[psw length];
    if(0 == length) return NO;
    
    //判断是否有汉字
    for (int i = 0; i < length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [psw substringWithRange:range];
        const char    *cString = [subString UTF8String];
        if (strlen(cString) == 3)
            return NO;
    }
    
    //判断是否含有数字
    const char *s=[psw UTF8String];
    for(int i = 0;i < length; i++){
        if(s[i] >= '0' && s[i] <= '9')
            hasOther = YES;
    }
    return !hasOther;
}

//判断输入是否全部都是数字
+ (BOOL)checkAllIsNumber:(NSString *)psw{
    
    int length = (int)[psw length];
    if(0 == length) return NO;
    
    //判断是否有汉字
    for (int i = 0; i < length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [psw substringWithRange:range];
        const char    *cString = [subString UTF8String];
        if (strlen(cString) == 3)
            return NO;
    }
    
    //判断是否是数字＋字母
    const char *s=[psw UTF8String];
    for(int i = 0;i < length; i++){
        if(s[i] >= 'a' && s[i] <= 'z')
            return NO;
        else if(s[i] >= 'A' && s[i] <= 'Z')
            return NO;
    }
    return YES;
}

/**
 *	@brief	判断一个字符串是否为整型数字
 *
 *	@param 	string
 *
 *	@return BOOL
 */
+ (BOOL) isPUreInt:(NSString*)string
{
    NSScanner *scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val]&&[scan isAtEnd];
}


//判断用户名 1：30位之内。2：数字＋字母。
+ (BOOL)checkUserName:(NSString *)psw{
    BOOL hasOther = NO;
    
    int length = (int)[psw length];
    
    //判断是否是小于30位
    if(length > 30)
        return NO;
    
    //判断是否有汉字
    for (int i = 0; i < length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [psw substringWithRange:range];
        const char    *cString = [subString UTF8String];
        if (strlen(cString) == 3)
            return NO;
    }
    
    //判断是否是数字＋字母
    const char *s=[psw UTF8String];
    for(int i = 0;i < length; i++){
        if(s[i] >= '0' && s[i] <= '9')
            continue;
        else if(s[i] >= 'a' && s[i] <= 'z')
            continue;
        else if(s[i] >= 'A' && s[i] <= 'Z')
            continue;
        else
            hasOther = YES;
    }
    
    if(hasOther)
        return NO;
    else
        return YES;
}

//判断密码 1：8－16位置。2：数字＋字母。3：不能全是数字或全是字母
+ (BOOL)checkPsw:(NSString *)psw{
    BOOL hasNum = NO;
    BOOL hasLetter = NO;
    BOOL hasOther = NO;
    
    int length = (int)[psw length];
    
    //判断是否是8－16位
    if(length > 16 || length < 8)
        return NO;
    
    //判断是否有汉字
    for (int i = 0; i < length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [psw substringWithRange:range];
        const char    *cString = [subString UTF8String];
        if (strlen(cString) == 3)
            return NO;
    }
    
    //判断是否是数字＋字母
    const char *s=[psw UTF8String];
    for(int i = 0;i < length; i++){
        if(s[i] >= '0' && s[i] <= '9')
            hasNum = YES;
        else if(s[i] >= 'a' && s[i] <= 'z')
            hasLetter = YES;
        else if(s[i] >= 'A' && s[i] <= 'Z')
            hasLetter = YES;
        else
            hasOther = YES;
    }
    
    if(hasNum && hasLetter && !hasOther)
        return YES;
    else
        return NO;
}

//判断输入是否有特殊字符
+ (BOOL)checkIsThereHasSpecialLetter:(NSString *)psw{
    
    int length = (int)[psw length];
    if(0 == length) return NO;
    
    //判断是否是数字＋字母
    const char *s=[psw UTF8String];
    for(int i = 0;i < length; i++){
        if (s[i]=='<'||s[i]=='>'||s[i]=='&') {
            return NO;
        }
    }
    return YES;
}

+ (NSString *)getUserNameFromPlist{
    NSString *userName= @"";
    if ([StaticTools fileExistsAtPath:@"userInfo.plist"]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"userInfo.plist"];
        
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        userName = [tempDic valueForKey:@"userName"];
    }
    
    return userName;
}

//把2002-09-12变成2002年09月12日
+ (NSString *)stringFormat:(NSString *)sourceString{
    NSString *timeString = sourceString;
    NSRange yearRange = NSMakeRange(0, 4);
    NSString *yearString = [timeString substringWithRange:yearRange];
    NSRange monthRange = NSMakeRange(5, 2);
    NSString *monthString = [timeString substringWithRange:monthRange];
    //	NSRange dayRange = NSMakeRange(8, 2);
    //	NSString *dayString = [timeString substringWithRange:dayRange];
    
    return [NSString stringWithFormat:@"%@年%@月",yearString,monthString];
}


//获取当前时间 精确到毫秒
+ (NSString *)getCurrencyTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SSS"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

#pragma mark - ---UIAlertController---
//只有一个确定按钮 用来提示 点击确定后 不做任何操作
+ (void)showAlertTitle:(NSString *)titleStr withMessage:(NSString *)alertString withController:(UIViewController *)controller
{
    [StaticTools showAlertTitle:titleStr message:alertString attribute:NO isTurn:NO viewController:controller cancalTitle:nil otherTitle:@"确定" btnTitles:nil btnColors:nil alertStyle:UIAlertControllerStyleAlert seletIndex:^(int index) {
        
    }];
}


+ (void)showAlertTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewC cancelTitle:(NSString *)cancelTitle cancelMethod:(void(^)(void))cancelBlock otherTitle:(NSString *)otherTitle otherMethod:(void(^)(void))otherBlock
{
    [StaticTools showAlertTitle:title message:message attribute:NO isTurn:NO viewController:viewC cancalTitle:cancelTitle otherTitle:otherTitle btnTitles:nil btnColors:nil alertStyle:UIAlertControllerStyleAlert seletIndex:^(int index) {
        if (index == 0) {
            cancelBlock?cancelBlock():nil;
        } else {
            otherBlock?otherBlock():nil;
        }
    }];
}

+ (void)showAttributeAlertTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewC cancelTitle:(NSString *)cancelTitle cancelMethod:(void(^)(void))cancelBlock otherTitle:(NSString *)otherTitle otherMethod:(void(^)(void))otherBlock
{
    [StaticTools showAlertTitle:title message:message attribute:YES isTurn:NO viewController:viewC cancalTitle:cancelTitle otherTitle:otherTitle btnTitles:nil btnColors:nil alertStyle:UIAlertControllerStyleAlert seletIndex:^(int index) {
        if (index == 0) {
            cancelBlock?cancelBlock():nil;
        } else {
            otherBlock?otherBlock():nil;
        }
    }];
}

+ (void)showAlertTurnTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewC cancelTitle:(NSString *)cancelTitle cancelMethod:(void(^)(void))cancelBlock otherTitle:(NSString *)otherTitle otherMethod:(void(^)(void))otherBlock {
    [StaticTools showAlertTitle:title message:message attribute:NO isTurn:YES viewController:viewC cancalTitle:cancelTitle otherTitle:otherTitle btnTitles:nil btnColors:nil alertStyle:UIAlertControllerStyleAlert seletIndex:^(int index) {
        if (index == 0) {
            cancelBlock?cancelBlock():nil;
        } else {
            otherBlock?otherBlock():nil;
        }
    }];
}

+ (void)showActionTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewC buttonTitles:(NSArray *)btnArr seletIndex:(void(^)(int index))selectBlock
{
    
    [StaticTools showAlertTitle:title message:message attribute:NO isTurn:NO viewController:viewC cancalTitle:nil otherTitle:nil btnTitles:btnArr btnColors:nil alertStyle:UIAlertControllerStyleActionSheet seletIndex:^(int index) {
        if (index > 0 && selectBlock) {
            selectBlock(index-1);
        }
    }];
}

+ (void)showAlertTitle:(NSString *)titleStr message:(NSString *)messageStr attribute:(BOOL)isAttribute isTurn:(BOOL)isTurn viewController:(UIViewController *)viewC cancalTitle:(NSString *)cancelTitle otherTitle:(NSString *)otherTitle btnTitles:(NSArray *)btnArr btnColors:(NSArray *)btnColor alertStyle:(UIAlertControllerStyle)style  seletIndex:(void(^)(int index))selectBlock {
    
    if (!titleStr) {
        titleStr = @"";
    }
    
    if (!messageStr) {
        messageStr = @"";
    }
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:titleStr message:messageStr preferredStyle:style];

    if (btnArr.count || style == UIAlertControllerStyleActionSheet) {
        
        NSMutableArray *arr = [NSMutableArray arrayWithArray:btnArr];
        [arr insertObject:@"取消" atIndex:0];
        
        for (int i = 0; i < arr.count; i ++) {
            
            NSString *btnTitle = [arr objectAtIndex:i];
            UIAlertAction *action = [UIAlertAction actionWithTitle:btnTitle style:i == 0?UIAlertActionStyleCancel:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                selectBlock(i);
            }];
            
            if (btnColor && btnColor[i]) {
                [action setValue:btnColor[i] forKeyPath:@"titleTextColor"];
            }
            
            [alertC addAction:action];
            
        }
        
    } else {
        
        UIColor *red    = [self colorWithHexString:@"#f72539"];
        UIColor *gray   = [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00];
        
        if (cancelTitle.length) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                selectBlock(0);
            }];
            [action setValue:isTurn?red:gray forKeyPath:@"titleTextColor"];
            [alertC addAction:action];
        }
        
        if (otherTitle.length) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:otherTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                selectBlock(1);
            }];
            [action setValue:isTurn?gray:red forKeyPath:@"titleTextColor"];
            [alertC addAction:action];
        }
        
    }

    if (isAttribute) {
        //富文本
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        //    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        [paragraphStyle setLineSpacing:5];
        [paragraphStyle setParagraphSpacing:9];
        //    [paragraphStyle setParagraphSpacingBefore:10];
        //    ,NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleNone]
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc]initWithString:messageStr attributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        //设置attributedMessage属性
        [alertC setValue:attrStr forKey:@"attributedMessage"];
        
        NSMutableParagraphStyle * paragraphStyle2 = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle2.alignment = NSTextAlignmentCenter;
        NSMutableAttributedString * attrStr2 = [[NSMutableAttributedString alloc]initWithString:titleStr attributes:@{NSParagraphStyleAttributeName:paragraphStyle2,NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        //设置attributedMessage属性
        [alertC setValue:attrStr2 forKey:@"attributedTitle"];
    }

    if ([viewC.presentedViewController isKindOfClass:UIViewController.class]) {

        if ([viewC.presentedViewController isKindOfClass:UIAlertController.class]) {
            UIAlertController *showAlert = (UIAlertController *)viewC.presentedViewController;
            if ([showAlert.message isEqualToString:messageStr]) {
                return;
            }
        }
        if (!viewC.presentedViewController.beingDismissed) {
            //页面是否将要消失
            viewC = viewC.presentedViewController;
        }
    } else {
        if (!viewC) {
            viewC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        } else {
            viewC.presentedViewController?[[[UIApplication sharedApplication] keyWindow] rootViewController] : viewC;
        }
    }

    [viewC presentViewController:alertC animated:YES completion:nil];
    
}


+ (void)showActionTitleOfChecking:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewC buttonTitles:(NSArray *)btnArr seletIndex:(void(^)(int index))selectBlock
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t alertTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    for (int i = 0; i < btnArr.count; i ++) {
        NSString *listTitle = [btnArr objectAtIndex:i];
        UIAlertAction *actionList = [UIAlertAction actionWithTitle:listTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            if (alertTimer)
            {
                dispatch_cancel(alertTimer);
            }
            selectBlock(i);
        }];
        if (i == 0)
        {
            [actionList setValue:[self colorWithHexString:@"#f72539"] forKey:@"titleTextColor"];

        }
        else
        {
            [actionList setValue:[StaticTools colorWithHexString:@"#333333"] forKeyPath:@"titleTextColor"];

        }
        [alertC addAction:actionList];
    }
    if (!viewC || ![viewC isKindOfClass:[UIViewController class]]) {
        viewC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    }

    alertTimerCount = 30;
    [viewC presentViewController:alertC animated:YES completion:^{
        
        dispatch_source_set_timer(alertTimer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(alertTimer, ^{
            if(alertC.presentedViewController)
                return ;
            alertTimerCount--;
            if (alertTimerCount == 0)
            {
                if (alertC)
                {
                    [alertC dismissViewControllerAnimated:YES completion:nil];
                }
                dispatch_cancel(alertTimer);
            }
            else
            {
                alertC.message = [NSString stringWithFormat:@"%ds后默认选择“下次提醒”",alertTimerCount];
            }
            
        });
        dispatch_resume(alertTimer);
        
    }];
    
}

//MARK: -

//判断两个时间的日期间隔
+ (double)checkTimeInterval:(NSString *)beginData endData:(NSString *)endData{
    NSString *beginYearString = [beginData substringWithRange:NSMakeRange(0, 4)];
    NSString *beginMonthString = [beginData substringWithRange:NSMakeRange(5, 2)];
    NSString *beginDayString = [beginData substringWithRange:NSMakeRange(8, 2)];
    double beginYearDouble = [beginYearString doubleValue]*365;
    double beginMonthDouble = [beginMonthString doubleValue]*30;
    double beginDayDouble = [beginDayString doubleValue];
    
    NSString *endYearString = [endData substringWithRange:NSMakeRange(0, 4)];
    NSString *endMonthString = [endData substringWithRange:NSMakeRange(5, 2)];
    NSString *endDayString = [endData substringWithRange:NSMakeRange(8, 2)];
    double endYearDouble = [endYearString doubleValue]*365;
    double endMonthDouble = [endMonthString doubleValue]*30;
    double endDayDouble = [endDayString doubleValue];
    
    return (endYearDouble+endMonthDouble+endDayDouble)-(beginYearDouble+beginMonthDouble+beginDayDouble);
}

+ (double)checkTimeIntervalbeginTime:(NSString *)beginTime endData:(NSString *)endTime
{// 08:00  21:30
    NSString *beginHourStr = @"";
    beginHourStr = [beginTime substringWithRange:NSMakeRange(0, 2)];
    
    NSString *beginMinStr = [beginTime substringWithRange:NSMakeRange(3, 2)];
    double beginHourDouble = [beginHourStr doubleValue]*60;
    double beginMinDouble = [beginMinStr doubleValue];
    
    NSString *endHourStr = [endTime substringWithRange:NSMakeRange(0, 2)];
    NSString *endMinStr = [endTime substringWithRange:NSMakeRange(3, 2)];
    double endHourDouble = [endHourStr doubleValue]*60;
    double endMinDouble = [endMinStr doubleValue];
    
    return (endHourDouble + endMinDouble - beginHourDouble - beginMinDouble);
}

//返回各个列表页面的缓存数据
+ (NSMutableArray *)getCacheArray:(NSString *)cacheType{
    NSMutableArray *cacheArray = [[NSMutableArray alloc] init];
    if ([cacheType length] == 0) return cacheArray;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path_ = [documentsDirectory stringByAppendingPathComponent:@"cacheArray.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path_]) {
        [cacheArray writeToFile:path_ atomically:YES];
        return cacheArray;
    }
    else
    {
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path_];
        //modify by yzf 20130118  判断字典对应的cacheType的键值是否为空
        //		cacheArray = [[tempDictionary objectForKey:cacheType] retain];
        if ([tempDictionary objectForKey:cacheType]) {
            cacheArray = [tempDictionary objectForKey:cacheType];
        }
        
        return cacheArray;
    }
}

//保存各个列表页面的缓存数据
+ (void)saveDefaultData:(NSMutableArray *)dateArray cacheType:(NSString *)cacheType showMore:(BOOL)showMore{
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:dateArray];
    
    if([tempArray count] > 10 && showMore){
        NSRange range = NSMakeRange(10, [tempArray count]-10);
        [tempArray removeObjectsInRange:range];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path_ = [documentsDirectory stringByAppendingPathComponent:@"cacheArray.plist"];
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path_];
    if(!tempDictionary)
        tempDictionary = [[NSMutableDictionary alloc] init];
    [tempDictionary setObject:tempArray forKey:cacheType];
    [tempDictionary writeToFile:path_ atomically:YES];
}

//add by yzf 20121217   保存数据到缓存
+ (void)saveData:(NSMutableArray *)dataArray cacheType:(NSString *)cacheType dataNum:(NSInteger)num{
    //dataArray是要保存的数组 cacheType是对应的key  num是要保存的数据条数
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:dataArray];
    
    if([tempArray count] > num){
        NSRange range = NSMakeRange(num, [tempArray count] - num);
        [tempArray removeObjectsInRange:range];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path_ = [documentsDirectory stringByAppendingPathComponent:@"cacheArray.plist"];
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path_];
    if(!tempDictionary)
        tempDictionary = [[NSMutableDictionary alloc] init];
    [tempDictionary setObject:tempArray forKey:cacheType];
    [tempDictionary writeToFile:path_ atomically:YES];
}

//add by yzf 20121217  删除缓存数据
+ (void)removeDataForKey:(NSString *)key
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path_ = [documentsDirectory stringByAppendingPathComponent:@"cacheArray.plist"];
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path_];
    if (!tempDictionary) {  //如果不存在文件，返回   该种情况一般不会存在
        return;
    }
    [tempDictionary removeObjectForKey:key];
    [tempDictionary writeToFile:path_ atomically:YES];
}


//取得今天的日期 yyyy-MM-dd
+ (NSString *)getTodayDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

//取得今天的日期 yyyy-MM-dd 用typeStr (- /分割)
+ (NSString *)getTodayDateWithType:(NSString *)typeStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *str = [NSString stringWithFormat:@"yyyy%@MM%@dd",typeStr,typeStr];
    [formatter setDateFormat:str];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

//返回给定时间加减年月日后的日期
+(NSString *)backTheDateAdding:(NSDate *)date year:(int)epYear month:(int)epMonth day:(int)epDay{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    
    [offsetComponents setYear:epYear];
    [offsetComponents setMonth:epMonth];
    [offsetComponents setDay:epDay];
    
    // Calculate when, according to Tom Lehrer, World War III will end
    NSDate *endOfWorldWar3 = [gregorian dateByAddingComponents:offsetComponents toDate:date options:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString* beforeOneYearStr = [dateFormatter stringFromDate:endOfWorldWar3];
    beforeOneYearStr =  [beforeOneYearStr substringToIndex:8];
    return beforeOneYearStr;
}

//取得startDate后days的日期 yyyy-MM-dd
+ (NSString *)getAfterDate:(NSDate *)startDate days:(int)days{
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([startDate timeIntervalSinceReferenceDate] + 24*3600*days)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}

//取得startDate前days的日期 yyyy-MM-dd
+ (NSString *)getBeforeDate:(NSDate *)startDate days:(int)days{
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([startDate timeIntervalSinceReferenceDate] - 24*3600*days)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}

//取得startDate前days的日期 yyyy-MM-dd (string:输入-，或者/判断不同的格式)
+ (NSString *)getBeforeDate:(NSDate *)startDate days:(int)days for:(NSString *)string{
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([startDate timeIntervalSinceReferenceDate] - 24*3600*days)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateString = [NSString stringWithFormat:@"yyyy%@MM%@dd",string,string];
    [formatter setDateFormat:dateString];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}

//把string，以type0分割，并，以type1拼接
+ (NSString *)changeString:(NSString *)string fromType:(NSString *)type0 withType:(NSString *)type1
{
    NSArray *tArray = [string componentsSeparatedByString:type0];
    NSString *tmpString = @"";
    for (int i = 0;i < tArray.count ;i++)// id t in tArray)
    {
        NSString *tt = [tArray objectAtIndex:i];
        tmpString = [NSString stringWithFormat:@"%@%@",tmpString,tt];
        //        [tmpString appendString:tt];
        if (i != tArray.count - 1) {
            tmpString = [NSString stringWithFormat:@"%@%@",tmpString,type1];
            //            [tmpString appendString:@"-"];
        }
    }
    return tmpString;
}
+ (NSString *)getDateStrWithDate:(NSDate*)someDate withCutStr:(NSString*)cutStr hasTime:(BOOL)hasTime
{
    if (cutStr == nil) {
        cutStr = @"-";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *str = nil;
    if (hasTime) {
        str = [NSString stringWithFormat:@"yyyy%@MM%@dd HH:mm:ss",cutStr,cutStr];
    }
    else
    {
        str = [NSString stringWithFormat:@"yyyy%@MM%@dd",cutStr,cutStr];
    }
    [formatter setDateFormat:str];
    NSString *date = [formatter stringFromDate:someDate];
    return date;
}

/**
 *	@brief	从指定日期字符串的初始化一个NSdate
 *
 *	@param 	dateStr 指定日期的字符串 注意分割线 支持 2012-12-12 和 2012/12/12 两种形式分隔
 *       可以带时间 如2012-12-12 10:12:12 若未带时间 则返回的date的时间为默认的08:00:00(系统默认时间为00:00:00 调用convertDateToLocalTime后变成 08:00:00)
 *	@return NSDate
 */
+ (NSDate*)getDateFromDateStr:(NSString*)dateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([dateStr rangeOfString:@"-"].location!=NSNotFound) {
        if (dateStr.length>10) {
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        else
        {
            [formatter setDateFormat:@"yyyy-MM-dd"];
        }
    }
    else
    {
        if (dateStr.length>10) {
            [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        }
        else
        {
            [formatter setDateFormat:@"yyyy/MM/dd"];
        }
    }
    NSDate *date = [formatter  dateFromString:dateStr];
    date = [StaticTools convertDateToLocalTime:date];
    return date;
}

/**
 *	@brief	获取指定日期的年份字符串
 *
 *	@param 	someDate 	指定的日期
 *
 *	@return NSString
 */
+ (NSString *)getYearStrOfDate:(NSDate*)someDate
{
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY"];
    NSString* yearStr=[formatter stringFromDate:someDate];
    return yearStr;
}

/**
 *	@brief	获取指定日期的月份字符串
 *
 *	@param 	someDate 	指定的日期
 *
 *	@return NSString
 */
+ (NSString *)getMonthStrOfDate:(NSDate*)someDate
{
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM"];
    NSString* monthStr=[formatter stringFromDate:someDate];
    return monthStr;
}
/**
 *	@brief	获取指定日期的日期字符串
 *
 *	@param 	someDate 	指定的日期
 *
 *	@return NSString
 */
+ (NSString *)getDayStrOfDate:(NSDate*)someDate
{
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"dd"];
    NSString* dayStr=[formatter stringFromDate:someDate];
    return dayStr;
}

/**
 *	@brief	获取指定格式日期的字符串
 *
 *	@param 	someDate 	指定的格式
 *  YYYY年 MM月 dd日 HH时 mm分 ss秒
 *	@return NSString
 */
+ (NSString *)getHourStrOfDate:(NSDate*)someDate withFormat:(NSString *)format
{
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSString* dayStr=[formatter stringFromDate:someDate];
    return dayStr;
}

/**
 *	@brief	返回对指定日期进行年 月 日加减操作后的日期
 *
 *	@param 	someDate 	指定的操作日期
 *	@param 	changYear 	加减的年份数  正数为指定日期的年份往后推 负数为往前推
 *	@param 	changeMonth 加减的月份数  正数为指定日期的月份往后推 负数为往前推
 *	@param 	changeDay 	加减的天数  正数为指定日期的天数往后推 负数为往前推
 *
 *	@return NSDate
 */
+ (NSDate*)getDateFromDate:(NSDate*)someDate withYear:(int)changYear month:(int)changeMonth day:(int)changeDay
{
    
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    
    [dateComponents setYear:changYear];
    [dateComponents setMonth:changeMonth];
    [dateComponents setDay:changeDay];
    
    NSDate *date = [gregorian dateByAddingComponents:dateComponents toDate:someDate options:0];
    return date;
    
}

/**
 *	@brief	获取两个指定日期之间相隔的长度
 *
 *	@param 	beginDate 	开始时间
 *	@param 	endDate 	结束时间
 *  @param 	type 	unitFlags标志  以 开始时间：2013-1-1 10:08:08 和结束时间：2014-2-2 11:09:09 数据为例
 *   0：表示包含相差年份  此时返回相差 1年 1月 1日 1小时 1分钟 1秒
 *   1: 表示不包含相差年数 将年数转成对于数量的月份  此时返回相差 0年 13月 1日 1小时 1分钟 1秒
 *   2: 表示不包含年份及月份 将相差的年数和月数转成对应数量的天数   此时返回相差0年0月 （365+31+1）日
 *   以此类推 3：表示只返回相差小时以下 4：表示只返回相差分钟以下数据 5：表示只返回相差秒数
 *	@return	 以NSDateComponents的属性 components.year components.month components.day 等属性取相差的年数 月数 天数等
 若开始时间小于结束时间 返回的components.day等属性值为负数  反之为正数
 */
+ (NSDateComponents*)getDateDistanceFromDate:(NSDate*)beginDate toDate:(NSDate*)endDate withType:(int)type
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[[NSTimeZone alloc]initWithName:@"GMT"]];
    NSDateComponents *components;
    
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [zone secondsFromGMTForDate: endDate];  //转化为北京时间
//    NSDate *localeDate = [endDate  dateByAddingTimeInterval: interval];
    
    // unsigned int unitFlags = kCFCalendarUnitMonth|NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitMinute;  加入月份的flags后就有相差月份数  否则会将月份数转化为对应的天数
    
    unsigned int unitFlags = 0;
    switch (type) {
        case 0:
            unitFlags = kCFCalendarUnitYear|kCFCalendarUnitMonth|NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            break;
        case 1:
            unitFlags = kCFCalendarUnitMonth|NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            break;
        case 2:
            unitFlags = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            break;
        case 3:
            unitFlags =  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            break;
        case 4:
            unitFlags = NSCalendarUnitMinute | NSCalendarUnitSecond;
            break;
        case 5:
            unitFlags =  NSCalendarUnitSecond;
            break;
            
        default:
            break;
    }
    components= [calendar components:unitFlags fromDate:endDate toDate:beginDate options:0];
    
    return components;
}

#pragma mark - 金额添加千分符
//A_wangchuan20160613
+ (NSString *)moneyWithComma:(NSString *)moneyStr
{
    if (!moneyStr || moneyStr.length == 0 ) {
        return @"0.00";
    }
//    if ([moneyStr rangeOfString:@","].location != NSNotFound) {
//        return moneyStr;
//    }
//    if ([moneyStr rangeOfString:@"，"].location != NSNotFound) {
//        moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@"，" withString:@","];
//        return moneyStr;
//    }
    moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@"," withString:@""];
    moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@"，" withString:@""];
    //应该是绝对值
    if (fabs([moneyStr doubleValue]) < 1000) {
        return  [NSString stringWithFormat:@"%.2f",[moneyStr doubleValue]];
    }
    
    NSNumber *number = [NSNumber numberWithDouble:[moneyStr doubleValue]];
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    [format setPositiveFormat:@",###.00"];
    NSString *resutlStr = [format stringFromNumber:number];
    
    return resutlStr;
}


//A_wangchuan20180223  金额整数部分格式化,小数部分不做处理
+ (NSString *)intMoneyWithComma:(NSString *)moneyStr
{
    if (!moneyStr || moneyStr.length == 0 ) {
        return @"";
    }
    moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@"," withString:@""];
    moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@"，" withString:@""];
    
    //绝对值
    if (fabs([moneyStr doubleValue]) < 1000) {
        return  moneyStr;
    }
    
    NSString * intMoneyStr = @"";
    NSString * piontStr = @"";
    
    if ([moneyStr rangeOfString:@"."].location != NSNotFound)
    {
        intMoneyStr = [moneyStr substringToIndex:[moneyStr rangeOfString:@"."].location ];
        piontStr = [moneyStr substringFromIndex:[moneyStr rangeOfString:@"."].location];
    }
    else
    {
        intMoneyStr = moneyStr;
    }
    
    NSNumber *number = [NSNumber numberWithDouble:[intMoneyStr doubleValue]];
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    [format setPositiveFormat:@",###"];
    NSString  * resutlStr = [format stringFromNumber:number];
    resutlStr =  [resutlStr stringByAppendingString:piontStr];
    
    return resutlStr;
}

//根据币种的精度，格式化金额，小数点后保留N位，加入千分符
//precision: 币种精度，传@""或者nil 小数部分不做处理，保持原样
+ (NSString *)moneyWithComma:(NSString *)moneyStr precision:(NSString *)precision
{
    if (!moneyStr || moneyStr.length == 0 )
    {
        return @"";
    }
    if (!precision || precision.length == 0)
    {
        return [self intMoneyWithComma:moneyStr];
    }
    NSString * pre = [NSString stringWithFormat:@"%%.%@f",precision];
    moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@"," withString:@""];
    moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@"，" withString:@""];
    //应该是绝对值
    if (fabs([moneyStr doubleValue]) < 1000)
    {
        return  [NSString stringWithFormat:pre,[moneyStr doubleValue]];
    }
    NSNumber *number = [NSNumber numberWithDouble:[moneyStr doubleValue]];
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    NSString * zero = [NSString stringWithFormat:pre,@"0"];
    NSString * formatStr = [NSString stringWithFormat:@",###"];
    
    if (![precision isEqualToString:@"0"])
    {
        zero = @"000000000000000000000000000000000000000000000";
        formatStr = [NSString stringWithFormat:@",###.%@",[zero substringToIndex:[precision intValue]]];
    }
    [format setPositiveFormat:formatStr];
    NSString *resutlStr = [format stringFromNumber:number];
    
    return resutlStr;
}

#pragma mark - 日期格式yymmdd转换成yy-mm-dd
//A_liuxiaolong
+ (NSString *)changeDateString:(NSString *)dateStr
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyymmdd"];
    NSDate *date = [df dateFromString:dateStr];
    NSDateFormatter *dfChange = [[NSDateFormatter alloc]init];
    [dfChange setDateFormat:@"yyyy-mm-dd"];
    NSString *string = [NSString stringWithFormat:@"%@",[dfChange stringFromDate:date]];
    return string;
}

/*
 *image拼图
 *返回一个拼好的image
 */
+ (UIImage *)getImageFromImage:(UIImage *)imageLeftOrTop
                   centerImage:(UIImage *)imageCenter
                    finalImage:(UIImage *)imageRightOrBottom
                      withSize:(CGSize)resultSize
{
    UIGraphicsBeginImageContext(resultSize);
    
    // Draw image1
    [imageLeftOrTop drawInRect:CGRectMake(0, 0, imageLeftOrTop.size.width, imageLeftOrTop.size.height)];
    
    // Draw image2
    if (resultSize.height == imageLeftOrTop.size.height)
    {
        //如果高度相等 则从左到右画图
        [imageCenter drawInRect:CGRectMake(imageLeftOrTop.size.width, 0, resultSize.width -imageLeftOrTop.size.width - imageRightOrBottom.size.width, imageCenter.size.height)];
        // Draw image3
        [imageRightOrBottom drawInRect:CGRectMake(resultSize.width-imageRightOrBottom.size.width, 0, imageRightOrBottom.size.width, imageRightOrBottom.size.height)];
    }
    else if(resultSize.width == imageLeftOrTop.size.width)
    {
        //宽度相同 则从上到下画图
        [imageCenter drawInRect:CGRectMake(0, imageLeftOrTop.size.height, imageCenter.size.width, resultSize.height - imageLeftOrTop.size.height-imageRightOrBottom.size.height)];
        // Draw image3
        [imageRightOrBottom drawInRect:CGRectMake(0, resultSize.height - imageRightOrBottom.size.height, imageRightOrBottom.size.width, imageRightOrBottom.size.height)];
    }
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
    //    [resultingImage release];
}

//计算两个时间差
+ (int)getLeftTime:(NSString *)dateTimeString messageTime:(NSString *)messageTime
{
    //    OutLog(@"dateTimeString=%@",dateTimeString);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateTime = [dateFormatter  dateFromString:dateTimeString];//下单时间
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *nowDate = [formatter dateFromString:messageTime];  //当前时间
    
    //计算两个时间差 就是还剩下多长时间
    NSTimeInterval date0 = [dateTime timeIntervalSinceReferenceDate];
    NSTimeInterval date1 = [nowDate timeIntervalSinceReferenceDate];
    return 900-(int)(date1-date0);
}

//endTime - startTimeStr  是否为正
+ (int)getFromTime:(NSString *)startTimeStr toTime:(NSString *)endTimeStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *dateTime = [dateFormatter  dateFromString:startTimeStr];
    NSDate *nowDate = [dateFormatter dateFromString:endTimeStr];
    NSTimeInterval date0 = [dateTime timeIntervalSinceReferenceDate];
    NSTimeInterval date1 = [nowDate timeIntervalSinceReferenceDate];
    
    return (date1-date0);
}

//16进制颜色(html颜色值)字符串转为UIColor
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor blackColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

//格式化电话号码
+(NSString *)formatedString:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];//这个是中文空格
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];//英文空格
    
    return string;
}

//返回label的高度
+(float)getLabelHeigth:(NSString *)textString defautWidth:(float)defautWidth defautHeigth:(float)defautHeigth fontSize:(int)fontSize{
    CGSize size = CGSizeMake(defautWidth,defautHeigth);
    //计算实际frame大小，并将label的frame变成实际大小
//    CGSize labelsize = [textString sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    
    //7.0适配方法
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize labelsize = [textString boundingRectWithSize:size options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    //M_fangmiaorui 不+1 无法正常显示
    return labelsize.height + 1;
}

//返回label的宽度
+(float)getLabelWidth:(NSString *)textString defautWidth:(float)defautWidth defautHeigth:(float)defautHeigth fontSize:(int)fontSize{
    CGSize size = CGSizeMake(defautWidth,defautHeigth);
    //计算实际frame大小，并将label的frame变成实际大小
    //CGSize labelsize = [textString sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    
    //7.0适配方法
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize labelsize = [textString boundingRectWithSize:size options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return labelsize.width;
}


//add by chenqingxian 20121223
+ (double)rad:(double)d {
    return d * M_PI / 180.0;
}

//转换时区 输入时间 输出＋8时间
+(NSDate *)convertDateToLocalTime:(NSDate *)forDate {
    
    NSTimeZone *nowTimeZone = [NSTimeZone localTimeZone];
    
    NSInteger timeOffset = [nowTimeZone secondsFromGMTForDate:forDate];
    
    NSDate *newDate = [forDate dateByAddingTimeInterval:timeOffset];
    
    return newDate;
    
}

// 正则判断手机号码地址格式
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,,183,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[2378])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSString * GUHUA = @"^(\\d{3,4}-)?\\d{7,8}(-\\d{3,4})?$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs =[NSPredicate predicateWithFormat:@"SELF MATCHES %@",PHS];
    NSPredicate *regextestguhua = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",GUHUA];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES)
        || ([regextestphs evaluateWithObject:mobileNum] == YES)||([regextestguhua evaluateWithObject:mobileNum]))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}



/**
 展示文字标签

 @param superView 展示图层
 @param lableText 展示文字
 @param bgColor 背景颜色
 @param hudColor hud颜色
 */
+(void)showTextHUDInView:(UIView*)superView withText:(NSString*)lableText withBGColor:(UIColor *)bgColor withHudColor:(UIColor *)hudColor{
    
    MBProgressHUD*HUD=[[MBProgressHUD alloc] initWithView:superView];
    HUD.bezelView.backgroundColor = hudColor;
    HUD.margin = 17.f;
    [HUD setBackgroundColor:bgColor];
    [superView addSubview:HUD];
    
    //自定义文字
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.label.text = lableText;
    HUD.label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];

    [HUD showAnimated:NO whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [HUD removeFromSuperview];
    }];
    
}
/**
 自定义hud样式 可设置自定义背景色,自定义图片,自定义文字
 
 @param superView 图层位置
 @param lableText 展示文字
 @param image 展示图片
 @param hudColor 背景颜色
 */
+(void)showCustomHUDInView:(UIView*)superView withText:(NSString*)lableText withImage:(NSString *)image withHudColor:(UIColor *)hudColor{
    
    MBProgressHUD*HUD=[[MBProgressHUD alloc] initWithView:superView];
    HUD.bezelView.backgroundColor = hudColor;
    HUD.margin = 12.f;
    [HUD setBackgroundColor:[UIColor clearColor]];
    [superView addSubview:HUD];
    
    //自定义文字
    HUD.mode=MBProgressHUDModeCustomView;
    HUD.label.text = lableText;
    HUD.label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    
    //自定义图片
    UIImageView *iamgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    [iamgeView setContentMode:UIViewContentModeCenter];
    HUD.customView = iamgeView;
    [HUD.customView sizeToFit];
    //为了适配UI 把图片的坐标写大点;
    [HUD.customView setFrame:CGRectMake(0, 0, 75, 50)];
    
    [HUD showAnimated:NO whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [HUD removeFromSuperview];
    }];

}
//HUD 样式 ...待定
+(void)showHUDInView:(UIView*)superView HudType:(MBProgressHUDMode)hudType withText:(NSString*)lableText
{
    MBProgressHUD*HUD=[[MBProgressHUD alloc] initWithView:superView];
    [superView addSubview:HUD];

    switch (hudType)
    {
        case MBProgressHUDModeIndeterminate:
        {
            //带activeView的 不断转动
            HUD.mode=MBProgressHUDModeIndeterminate;
            //            HUD.label.text = lableText;
            
            //            [HUD showAnimated:YES whileExecutingBlock:^{
            //                sleep(3);
            //            } completionBlock:^{
            //
            //            }];
            [HUD showAnimated:YES];
        }
            break;
        case MBProgressHUDModeDeterminate:
        {
            //设置模式为进度框形的
            HUD.mode=MBProgressHUDModeDeterminate;
            HUD.label.text = lableText;
            [HUD showAnimated:YES whileExecutingBlock:^{
                float progress = 0.0f;
                while (progress < 1.0f) {
                    progress += 0.01f;
                    HUD.progress = progress;
                    usleep(30000);
                }
            } completionBlock:^{
                
            }];
        }
            break;
        case MBProgressHUDModeAnnularDeterminate:
        {
            //进度框模式2
            HUD.mode=MBProgressHUDModeAnnularDeterminate;
            HUD.label.text = lableText;
            [HUD showAnimated:YES whileExecutingBlock:^{
                float progress = 0.0f;
                while (progress < 1.0f) {
                    progress += 0.01f;
                    HUD.progress = progress;
                    usleep(30000);
                }
            } completionBlock:^{
                
            }];
        }
            break;
        case MBProgressHUDModeCustomView:
        {
            //自定义类型 3秒消失
            HUD.mode=MBProgressHUDModeCustomView;
            HUD.label.text = lableText;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_toast.png"]];
            [HUD.customView setFrame:CGRectMake(0, 0, 170, 60)];
            [HUD setBackgroundColor:[UIColor clearColor]];
            [HUD showAnimated:NO whileExecutingBlock:^{
                sleep(3);
            } completionBlock:^{
                [HUD removeFromSuperview];
            }];
        }
            
            break;
        case MBProgressHUDModeText:
        {//纯文本
            HUD.mode=MBProgressHUDModeText;
            HUD.label.text = lableText;
            [HUD showAnimated:YES whileExecutingBlock:^{
                sleep(3);
            } completionBlock:^{
                
            }];
        }
            break;
        default:
            break;
    }
    
}

/*
 隐藏hud
 
 */
+(void)removeHUDFromView:(UIView*)superView{
    //superView上的hud都会被释放掉
    //[MBProgressHUD hideHUDForView:superView animated:YES];
    NSArray *hudArray=[MBProgressHUD allHUDsForView:superView];
    
    for (MBProgressHUD *hud in hudArray) {
        [hud removeFromSuperview];
    }
}

#pragma mark - A_liuxl:新加 HUD 样式
+ (void)showHUDInView:(UIView *)superView HudType:(MBProgressHUDMode)hudType withText:(NSString *)labelText delegate:(id)delegate delay:(float)delay animated:(BOOL)animated
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:superView];
    [superView addSubview:HUD];
    HUD.removeFromSuperViewOnHide = YES;
    if (delegate) {
        HUD.delegate = delegate;
    }
    if (labelText) {
        HUD.labelText = labelText;
    }
    
    switch (hudType) {
        case MBProgressHUDModeIndeterminate:
        {
            //带activeView的 不断转动
            HUD.mode = MBProgressHUDModeIndeterminate;
            [HUD showAnimated:animated];
            if (delay > 0) {
                [HUD hideAnimated:animated afterDelay:delay];
            }
            break;
        }
        case MBProgressHUDModeDeterminate:
        {
            //设置模式为进度框形的
            HUD.mode = MBProgressHUDModeDeterminate;
            [HUD showAnimated:animated whileExecutingBlock:^{
                float progress = 0.0f;
                while (progress < 1.0f) {
                    progress += 0.01f;
                    HUD.progress = progress;
                    usleep(30000);
                }
            } completionBlock:^{
                
            }];
            break;
        }
        case MBProgressHUDModeAnnularDeterminate:
        {
            //进度框模式2
            HUD.mode = MBProgressHUDModeAnnularDeterminate;
            [HUD showAnimated:animated whileExecutingBlock:^{
                float progress = 0.0f;
                while (progress < 1.0f) {
                    progress += 0.01f;
                    HUD.progress = progress;
                    usleep(30000);
                }
            } completionBlock:^{
            }];
            break;
        }
        case MBProgressHUDModeCustomView:
        {
            //对号 3秒消失
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            [HUD.customView setFrame:CGRectMake(0, 0, 37, 37)];
            [HUD showAnimated:animated];
            if (delay > 0) {
                [HUD hideAnimated:animated afterDelay:delay];
            }
            break;
        }
        case MBProgressHUDModeText:
        {
            //纯文本 3秒消失
            HUD.mode = MBProgressHUDModeText;
            [HUD showAnimated:animated];
            if (delay > 0) {
                [HUD hideAnimated:animated afterDelay:delay];
            }
            break;
        }
        default:
            break;
    }
}


//解析的时候检测数组array是否有效
+ (BOOL)checkArrayValid:(NSArray *)array{
    if(array && [array count] != 0 && [[array objectAtIndex:0] stringValue].length != 0) return YES;
    else return NO;
}

#pragma mark -
#pragma mark 存储操作

#pragma mark -
#pragma mark plist、userDefault、db


//add by wangxin 20130829   保存二维码图片的字节流到缓存
+ (void)saveTwoCodeData:(NSString *)twoDImageStr cacheType:(NSString *)cacheType{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path_ = [documentsDirectory stringByAppendingPathComponent:@"twoDCodeArray.plist"];
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path_];
    if(!tempDictionary)
        tempDictionary = [[NSMutableDictionary alloc] init];
    [tempDictionary setObject:twoDImageStr forKey:cacheType];
    [tempDictionary writeToFile:path_ atomically:YES];
    
}

+ (NSString *)readTwoCodeData:(NSString *)cacheType{
    NSString *twoDImageString = @"";
    NSMutableDictionary *cacheDict = [[NSMutableDictionary alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path_ = [documentsDirectory stringByAppendingPathComponent:@"twoDCodeArray.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path_]) {
        [cacheDict writeToFile:path_ atomically:YES];
    }
    else{
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithContentsOfFile:path_];
        twoDImageString = [tempDict objectForKey:cacheType];
    }
    return twoDImageString;
}
#pragma mark -
#pragma mark 读取plist、userDefault、db中的数据
/*
 *从plist、userDefault、db中读取数据
 *
 *@param cacheType
 *  类型有三种：DataModePlist：plist，
 DataModeUserDefault：userDefault，
 DataModeDB：db
 *
 *@param name
 *  用存储时的名字读取
 *
 *@调用举例
 *    [StaticTools readData:DataModePlist dataName:@"test"];
 *
 *@返回值 BOOL
 *                  YES：成功
 NO：失败
 *
 *@说明
 *   若读取DB，返回该表中所有的记录，类型为NSArray，数组中每条为一个NSMutableDictionary,为了和plist和userDefault统一，方法整体返回为NSMutableDictionary，用参数name的值取得数组
 */
+(NSMutableDictionary*)readData:(DataMode)cacheType dataName:(NSString*)name{
    NSMutableDictionary *cacheDict = [[NSMutableDictionary alloc] init];
    if ([name length] == 0)
        return cacheDict;
    
    //Plist
    if (cacheType == DataModePlist) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path_ = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",name]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path_]) {
            [cacheDict writeToFile:path_ atomically:YES];
        }
        else {
            NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path_];
            cacheDict = [tempDictionary objectForKey:name];
        }
    }
    
    //UserDefault
    else if (cacheType ==DataModeUserDefault){
        NSUserDefaults* muDefault = [NSUserDefaults standardUserDefaults];
        cacheDict = [muDefault objectForKey:name];
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary:cacheDict];
        return dict;
    }
    
    //其他
    else{
        NSLog(@"ReadDataMode Error");
    }
    return cacheDict;
}

#pragma mark -
#pragma mark 更新plist、userDefault、db中的数据
/*
 *从plist、userDefault、db中更新数据
 *
 *@param newDataDic
 *  想要更新的数据，类型为NSMutableDictionary
 *
 *@param cacheType
 *  类型有三种：DataModePlist：plist，
 DataModeUserDefault：userDefault，
 DataModeDB：db
 *
 *@param name
 *  用存储时的名字更新
 *
 *@param dbWhere
 *  更新条件，类型为NSMutableDictionary
 *
 *@返回值 BOOL
 *                  YES：成功
 NO：失败
 *
 *@调用举例
 *    [StaticTools updateData:new cacheType:DataModePlist name:@"test" DBWhere:nil];
 *
 *@说明
 *   若更新plist或userDefault，则dbWhere参数传入nil
 eg: NSMutableDictionary* new = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"e",@"A", nil];
 [StaticTools updateData:new cacheType:DataModePlist name:@"test" DBWhere:nil];
 若为db
 eg:    NSMutableDictionary* new = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"e",@"A", nil];
 NSMutableDictionary* where = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"b",@"B", nil];
 [StaticTools updateData:new cacheType:DataModeDB name:@"test" DBWhere:where];
 */
+ (BOOL)updateData:(NSMutableDictionary *)newDataDic cacheType:(DataMode)cacheType name:(NSString*)name DBWhere:(NSMutableDictionary*)dbWhere{
    if ([newDataDic count] == 0 || !newDataDic) {
        return NO;
    }
    
    //Plist
    if (cacheType == DataModePlist) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *DocumentsPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",name]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:DocumentsPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:DocumentsPath error:nil];
        }
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:DocumentsPath];
        if(!tempDictionary)
            tempDictionary = [[NSMutableDictionary alloc] init];
        [tempDictionary setObject:newDataDic forKey:name];
        [tempDictionary writeToFile:DocumentsPath atomically:YES];
        
        return YES;
    }
    
    //UserDefault
    else if (cacheType ==DataModeUserDefault){
        NSUserDefaults* muDefault = [NSUserDefaults standardUserDefaults];
        [muDefault setObject:newDataDic forKey:name];
        return YES;
    }
    //其他
    else{
        NSLog(@"SaveDataMode Error");
        return NO;
    }
}

#pragma mark -
#pragma mark 清空plist、userDefault、db中指定名称的数据
/*
 *清空plist、userDefault、db中指定名称的数据
 *
 *@param cacheType
 *  类型有三种：DataModePlist：plist，
 DataModeUserDefault：userDefault，
 DataModeDB：db
 *
 *@param name
 *  要删除数据的名称，即存储时传入的名称
 *
 *@返回值 BOOL
 *                  YES：成功
 NO：失败
 *
 *@调用举例
 *   [StaticTools clearData:DataModePlist dataName:@"test"];
 */
+(BOOL)clearData:(DataMode)cacheType dataName:(NSString*)name{
    //Plist
    if (cacheType == DataModePlist) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *DocumentsPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",name]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:DocumentsPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:DocumentsPath error:nil];
        }
        return YES;
    }
    
    //UserDefault
    else if (cacheType ==DataModeUserDefault){
        NSUserDefaults* muDefault = [NSUserDefaults standardUserDefaults];
        [muDefault setObject:@"" forKey:name];
        return YES;
    }
    //其他
    else{
        NSLog(@"ReadDataMode Error");
        return NO;
    }
}

#pragma mark - A_liuxiaolong20130701:去掉cell多余的分割线
+ (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

//格式化money格式(后台获取到的和上传的两种）
+(NSString *)formatMoney:(NSString *)money withLength:(int)length withFloat:(int)num withType:(int)type
{
    //length是money长度，num是小数位数  type是money类型，0代表获取到的money，1代表上传的money
    if (type == 0) {
        //获取到的，没有小数点  需要加上小数点并去掉多余的0
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSString *leftStr = [money substringWithRange:NSMakeRange(0, length-num)];  //整数部分
        NSString *rightStr = [money substringWithRange:NSMakeRange(length-num, num)]; //小数部分
        leftStr = [formatter stringFromNumber:[NSNumber numberWithLongLong:[leftStr longLongValue]]];
        if ([rightStr integerValue] == 0) {
            NSString *newStr = [NSString stringWithFormat:@"%@.00",[leftStr isEqualToString:@"-"]?@"-0":leftStr];
            return newStr;
        }
        NSString *formatMoney = [NSString stringWithFormat:@"%@.%@",[leftStr isEqualToString:@"-"]?@"-0":leftStr,rightStr];
        
        return formatMoney;
    }else if (type == 1){
        //上传的，有无小数点不确定，需要格式化为长度位length的格式
        NSString *leftStr = @"";
        NSString *rightStr = @"";
        if ([money rangeOfString:@"."].length >0) {
            //有小数点
            NSRange point = [money rangeOfString:@"."];
            leftStr = [money substringToIndex:point.location];
            rightStr = [money substringFromIndex:point.location+1];
        }else{
            //没有小数点
            leftStr = [NSString stringWithString:money];
        }
        for (int i =1; i < length; i++) {
            if (i <= num) {
                //给小数部分补0
                rightStr = [NSString stringWithFormat:@"%@0",rightStr];
            }
            if (i <= length - num) {
                //给整数部分补0
                leftStr = [NSString stringWithFormat:@"0%@",leftStr];
            }
        }
        leftStr = [leftStr substringFromIndex:leftStr.length - (length-num)];
        rightStr = [rightStr substringToIndex:num];
        NSString *formatMoney = [NSString stringWithFormat:@"%@.%@",leftStr,rightStr];
        
        return formatMoney;
        
    }
    else if (type == 2){
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSString *leftStr = [money substringWithRange:NSMakeRange(0, length-num)];  //整数部分
        NSString *rightStr = [money substringWithRange:NSMakeRange(length-num, num)]; //小数部分
        NSString *newStr= @"0";
        for (int i =0 ; i<leftStr.length; i++) {
            NSString *tempStr = [leftStr substringWithRange:NSMakeRange(i, 1)];
            if(![tempStr isEqualToString:@"0"]){
                newStr = [leftStr substringWithRange:NSMakeRange(i, leftStr.length-i)];
                break;
            }
        }
        if ([rightStr integerValue] == 0) {
            newStr = [NSString stringWithFormat:@"%@.00",[newStr isEqualToString:@"-"]?@"-0":newStr];
            return newStr;
        }
        NSString *formatMoney = [NSString stringWithFormat:@"%@.%@",[newStr isEqualToString:@"-"]?@"-0":newStr,rightStr];
        
        return formatMoney;
    }
    else{
        //用来扩展类型
        return @"";
    }
}

/*
 add by ly 201307  设置金额格式,传入金额和币种，如果金额中包含该币种，设置金额数目为小数点后两位的形式，如果未包含该币种，则设置金额数目形式后添加该币种,如果金额中不添加币种，则直接传空。该方法只用于显示金额，调完得确认返回有没有什么问题
 */
+ (NSString *)setFloatMoneyString :(NSString *)moneyStr moneyCode:(NSString *)moneyCodeStr
{
    NSString *money = [NSString stringWithFormat:@"%@",moneyStr];
    if (!money||money.length == 0)
    {
        money = @"0";
    }
    else
    {
        if (moneyCodeStr != nil||moneyCodeStr.length != 0)
        {
            //如果有币种
            if ([money rangeOfString:moneyCodeStr].location != NSNotFound)
            {
                NSRange range;
                range = [money rangeOfString:moneyCodeStr];
                money = [money substringToIndex:range.location];
            }
        }
    }
    //如果没有小数点
    if ([money rangeOfString:@"."].location == NSNotFound)
    {
        money = [money stringByAppendingString:@".00"];
    }
    else
    {
        if ([money substringFromIndex:[money rangeOfString:@"."].location].length == 2)
        {
            money = [money stringByAppendingString:@"0"];
        }
        else if ([money substringFromIndex:[money rangeOfString:@"."].location].length == 1)
        {
            money = [money stringByAppendingString:@"00"];
        }
    }
    if (moneyCodeStr != nil||moneyCodeStr.length != 0)
    {
        //拼接币种
        money = [money stringByAppendingString:moneyCodeStr];
    }
    
    return money;
}

/*
 // add by ly 201308 键盘编辑时,控制金额的输入，精确到小数点后两位
 */
+ (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""])
    {
        return YES;
    }
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@".0123456789\b"];
    if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound)
    {
        return NO;
    }
    else if(textField.text.length == 0&&[string isEqualToString:@"."])
    {
        return NO;
    }
    else if ([textField.text rangeOfString:@"."].location != NSNotFound )
    {
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
        if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound)
        {
            return NO;
        }
        else if ([textField.text substringFromIndex:[textField.text rangeOfString:@"."].location + 1].length == 2)
        {
            return NO;
        }
    }
    if ([textField.text hasPrefix:@"0"]&&textField.text.length == 1)
    {
        if (![string isEqualToString:@"."])
        {
            return NO;
        }
    }
    return YES;
}


// add by wangxin 20130911 格式化输入金额

// 调用方法
// 1:在-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 方法中用正则表达式控制不能输入非法字段（即数字和小数点以外的字符）
// 2:在-(void)textFieldDidEndEditing:(UITextField *)textField方法中调用此方法:
//   [textField setText:[StaticTools moneyFormatterMethod:textField.text]];

// 方法说明
//  此方法不关心小数点前面具体有几位，只是将输入的金额格式化成: xxx.xx（注意：xxx为任意位）
//  如果输入0.0或者0.00或者000.00即0与小数点的任意组合，则return @"";
+ (NSString *)moneyFormatterMethod:(NSString *)textFieldTextStr{
    
    // 先把金额所有前面的0全部截掉！
    NSString *tempMoney = textFieldTextStr;
    int j;
    j= 0;
    for (int i =0; i< [tempMoney length]; i++)
    {
        NSRange range = NSMakeRange(i, 1);
        NSString *subTemp = [tempMoney substringWithRange:range];
        if ([subTemp isEqualToString:@"0"])
        {
            j++;
        }
        else
        {
            break;
        }
    }
    tempMoney = [textFieldTextStr substringFromIndex:j];
    // 截取0完成！
    
    if ([tempMoney isEqualToString:@"."]||[tempMoney isEqualToString:@".0"]||[tempMoney isEqualToString:@".00"])
    {
        // 如果截取0之后，出现以上三种情况，则：
        tempMoney = @"";// 此目的是让下面的if判断不能蹦掉！！！
        
    }
    
    if ([tempMoney rangeOfString:@"."].location != NSNotFound)
    {
        // 如果有小数点的情况 目前做一下四种处理
        
        if (tempMoney.length - ([tempMoney rangeOfString:@"."].location +1) >2)
        {
            // 正确格式为34.56 如果小数点后大于两位，截取成正确格式(此种情况用于在其他地方复制粘贴过来的数据，因为正则表达式已经控制小数点后只能输入两位)
            tempMoney = [tempMoney substringWithRange:NSMakeRange(0, [tempMoney rangeOfString:@"."].location +3)];
        }
        if (tempMoney.length - ([tempMoney rangeOfString:@"."].location + 1) ==0)
        {
            // 如果已小数点结尾如13. 则补00格式为：13.00
            tempMoney = [NSString stringWithFormat:@"%@00",tempMoney];
        }
        if (tempMoney.length - ([tempMoney rangeOfString:@"."].location + 1) ==1)
        {
            // 88.9 格式为：88.90
            tempMoney = [NSString stringWithFormat:@"%@0",tempMoney];
        }
        if ([[tempMoney substringToIndex:1] isEqualToString:@"."])
        {
            // 如果以小数点开始，则补零
            if (tempMoney.length == 2)
            {   // .9 格式为0.90
                tempMoney = [NSString stringWithFormat:@"0%@0",tempMoney];
            }
            if (tempMoney.length ==3)
            {   // .09格式为：0.09;       .9格式为：0.90
                tempMoney = [NSString stringWithFormat:@"0%@",tempMoney];
            }
        }
    }
    else
    {
        // 如果是整数，则补00； 如果输入的是零，也会走
        tempMoney = [NSString stringWithFormat:@"%@.00",tempMoney];
    }
    if ([tempMoney isEqualToString:@".00"])
    {   // 如果输入0.或者0.0或者0.00或者000.00即0与小数点的任意组合，则return @"";
        tempMoney = @"";
    }
    return tempMoney;
}
/**
 *	@brief	判断证件号码正确性
 *
 *	@param 	bankNum 	证件号码
 *
 *	@return BOOL
 */
+(BOOL)isIdentityNum:(NSString*)bankNum

{
    NSString*  IDENTITYNUM= @"^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}(\\d|x|X)$";
    NSPredicate* regextestBankNum = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",IDENTITYNUM];
    if ([regextestBankNum evaluateWithObject:bankNum] == YES) {
        return YES;
    }else {
        return NO;
    }
}


/*
 设置卡号的显示形式，不管原卡号长度，都显示前四位和后四位，中间8个*，并每4位加一个空格。
 
 cardNoStr为传入的卡号
 */
+ (NSString *)setCardNoAsterisk:(NSString *)cardNoStr
{
    //安全长度  可能没必要。。。
    if (cardNoStr.length >= 15)
    {
        NSString * prefixStr = [cardNoStr substringToIndex:4];
        NSString * suffixStr = [cardNoStr substringFromIndex:cardNoStr.length - 4];
        cardNoStr = [NSString stringWithFormat:@"%@ **** **** %@",prefixStr,suffixStr];
    }

    return cardNoStr;
}

//把卡号每个四位添加一个空格
+(NSString *)formatterBankCardNum:(NSString *)cardNo
{
    
    NSString *tempStr = [cardNo stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (tempStr.length == 0)
    {
        return @"";
    }
    NSInteger size =(tempStr.length / 4);
    
    NSMutableArray *tmpStrArr = [[NSMutableArray alloc] init];
    
    for (int n = 0;n < size; n++)
    {
        [tmpStrArr addObject:[tempStr substringWithRange:NSMakeRange(n*4, 4)]];
    }
    
    [tmpStrArr addObject:[tempStr substringWithRange:NSMakeRange(size*4, (tempStr.length % 4))]];
    
    tempStr = [tmpStrArr componentsJoinedByString:@" "];
    
    return tempStr;
    
}



/**
 证件号加*

 @param certNo 全显示的证件号
 @return 加*后的证件号
 */
+ (NSString *)setCertNoAsterisk:(NSString *)certNo
{
    NSString * certStr;
    if (certNo.length >= 4 && certNo.length < 15)
    {
        NSString * tempStr = [certNo substringToIndex:certNo.length - 2];
        certStr = [NSString stringWithFormat:@"%@**",tempStr];
    }
    else if (certNo.length >= 15)
    {
        NSString * tempStr = [certNo substringToIndex:certNo.length - 4];
        certStr = [NSString stringWithFormat:@"%@****",tempStr];
    }
    else
    {
        certStr = certNo;
    }
    return certStr;
}


/**
 姓名加*

 @param nameStr 姓名
 @return *名
 */
+ (NSString *)setNameAsterisk:(NSString *)nameStr
{
    if (nameStr.length >= 2)
    {
        return [NSString stringWithFormat:@"*%@",[nameStr substringFromIndex:1]];
    }
    else
    {
        return nameStr;
    }
}


/**
 安全模式手机号
 fmr
 @param phoneNoStr 手机号
 @return 133****3345手机号
 */
+ (NSString *)setPhoneNoAsterisk:(NSString *)phoneNoStr
{
    //暂时只允许11位，否则不处理，方便用户再修改   如果要修改规则，一定要全局搜索这个方法名，看是否影响现有用到这个方法的代码规则。
    if (phoneNoStr.length == 11)
    {
        NSString * prefixStr = [phoneNoStr substringToIndex:3];
        NSString * suffixStr = [phoneNoStr substringFromIndex:7];
        phoneNoStr = [NSString stringWithFormat:@"%@****%@",prefixStr,suffixStr];
    }
    return phoneNoStr;
}
/**
 安全模式手机号 3 4 4形式
 @param phoneNoStr 手机号
 @return 133 **** 3345手机号
 */
+ (NSString *)setSafePhoneNum:(NSString *)phoneNoStr
{
    //暂时只允许11位，否则不处理，方便用户再修改   如果要修改规则，一定要全局搜索这个方法名，看是否影响现有用到这个方法的代码规则。
    if (phoneNoStr.length == 11)
    {
        NSString * prefixStr = [phoneNoStr substringToIndex:3];
        NSString * suffixStr = [phoneNoStr substringFromIndex:7];
        phoneNoStr = [NSString stringWithFormat:@"%@ **** %@",prefixStr,suffixStr];
    }
    return phoneNoStr;
}

#pragma mark - 指定某个角设置为圆角
+ (void)setRound:(UIView *)view byCorners:(UIRectCorner)corner radius:(CGFloat)radius
{
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = bezierPath.CGPath;
    view.layer.mask = maskLayer;
}


#pragma mark - A_liuxl20140320:给view加圆角和边框及颜色
+ (void)setRoundView:(UIView *)view radius:(CGFloat)radius borderWidth:(CGFloat)width color:(UIColor *)color
{
    if (view) {
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = radius;
        view.layer.borderWidth = width;
        if (color) {
            view.layer.borderColor = [color CGColor];
        }
        else {
            view.layer.borderColor = [[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1] CGColor];
        }
    }
}

//返回按钮，本来想放在base里，但很多都不继承base，那就放这里吧
+ (void)setNavigationBackButton:(UIViewController *)view
{
    
    static NSString * backImageName             = @"backimage_btn.png";
    static NSString * backImageName_P           = @"";

    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setTitle:@"" forState:UIControlStateNormal];
    [btnBack addTarget:view action:@selector(backView) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageNamed:backImageName] forState:UIControlStateNormal];
    if (backImageName_P.length > 0)
    {
        [btnBack setImage:[UIImage imageNamed:backImageName_P]forState:UIControlStateHighlighted];
    }
    [btnBack setFrame:CGRectMake(0, 0, 40, 40)];
    [btnBack setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    UIView * btnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btnView addSubview:btnBack];
    
    UIBarButtonItem *itemBack = [[UIBarButtonItem alloc] initWithCustomView:btnView];
    view.navigationItem.leftBarButtonItem = itemBack;
}

- (double)rad:(double)d {
    return d * M_PI / 180.0;
}



+ (void)classToDictionaryWithClass:(id)className
{
    NSMutableDictionary *dictionaryFormat = [NSMutableDictionary dictionary];
    
    //  取得当前类类型  className
    
    unsigned int ivarsCnt = 0;
    //　获取类成员变量列表，ivarsCnt为类成员数量
    Ivar *ivars = class_copyIvarList([className class], &ivarsCnt);
    
    //　遍历成员变量列表，其中每个变量都是Ivar类型的结构体
    for (const Ivar *p = ivars; p < ivars + ivarsCnt; ++p)
    {
        Ivar const ivar = *p;
        
        //　获取变量名
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        // 若此变量未在类结构体中声明而只声明为Property，则变量名加前缀 '_'下划线
        // 比如 @property(retain) NSString *abc;则 key == _abc;
        
        //　获取变量值
        id value = [className valueForKey:key];
        
        //　取得变量类型
        // 通过 type[0]可以判断其具体的内置类型
//        const char *type = ivar_getTypeEncoding(ivar);
        
        if (value)
        {
            [dictionaryFormat setObject:value forKey:key];
        }
        NSLog(@"%@--%@",key,value);
    }
}


+ (NSAttributedString *)getAttributedHTMLStr:(NSString *)htmlStr
{
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    return attrStr;
}



+ (NSString *)MD5WithStr:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}



//A_wangchuan 20161025   只有文字的toast
+(void)showToastWithTip:(NSString *)tip
{
    
    if (tip.length <= 0)
    {
        return;
    }
    UIWindow *mainWindow= [[[UIApplication sharedApplication] delegate] window];
        
    for(UIView *view in mainWindow.subviews){
        if ([view isKindOfClass:[UIView class]]&& view.tag == 123456)
        {
            [view removeFromSuperview];
        }
    }
    
    //背景  半透明黑      |   开放注册为透明
    UIView *backView = [[UIView alloc]initWithFrame:mainWindow.frame];

    backView.backgroundColor = [UIColor clearColor];

    backView.tag = 123456;
    [mainWindow addSubview:backView];
    
    
    //字背景  白圆角      |   开放注册为黑圆角
    UIView * toastView = [[UIView alloc]init];
    
    toastView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.66];
    toastView.layer.cornerRadius = 6;

    toastView.layer.masksToBounds = YES;
    [backView addSubview:toastView];
    
    //字
    UILabel *lblText = [[UILabel alloc] init];
    [lblText setFrame:CGRectMake(0, 0 ,225 * screenProportion - 60, 1000)];

    [toastView addSubview:lblText];
    
    lblText.textAlignment = NSTextAlignmentCenter;
    lblText.numberOfLines = 0;
    lblText.lineBreakMode = NSLineBreakByCharWrapping;
    lblText.text = tip;
    
    
    lblText.backgroundColor = [UIColor clearColor];
    [lblText setTextColor:[UIColor whiteColor]];
    [lblText setFont:[UIFont systemFontOfSize:14]];
    [lblText sizeToFit];
    [toastView setFrame:CGRectMake(0, 0, 225 * screenProportion, lblText.frame.size.height + 45)];
    lblText.center = toastView.center;
    toastView.center = backView.center;
    

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            backView.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
            [backView removeFromSuperview];
        }];

    });
    
}

//带图片背景的toast
+(void)showToastWithTip:(NSString *)tip image:(NSString *)imageStr
{
    
    if (tip.length <= 0)
    {
        return;
    }
    UIWindow *mainWindow= [[[UIApplication sharedApplication] delegate] window];
    
    for(UIView *view in mainWindow.subviews){
        if ([view isKindOfClass:[UIView class]]&& view.tag == 123456)
        {
            [view removeFromSuperview];
        }
    }

    UIView *backView = [[UIView alloc]initWithFrame:mainWindow.frame];
    
    backView.backgroundColor = [UIColor clearColor];
    backView.tag = 123456;
    [mainWindow addSubview:backView];
    
    UIView * toastView = [[UIView alloc]init];
    
    toastView.backgroundColor = [UIColor clearColor];
    toastView.layer.cornerRadius = 6;
    
    toastView.layer.masksToBounds = YES;
    [backView addSubview:toastView];
    
    UIImageView * imageV = [[UIImageView alloc] init];
    imageV.image = [UIImage imageNamed:imageStr];
    [toastView addSubview:imageV];
    
    //字
    UILabel *lblText = [[UILabel alloc] init];
    [lblText setFrame:CGRectMake(0, 0 ,225 * screenProportionNew - 60, 1000)];
    
    [toastView addSubview:lblText];
    
    lblText.textAlignment = NSTextAlignmentCenter;
    lblText.numberOfLines = 0;
    lblText.lineBreakMode = NSLineBreakByCharWrapping;
    lblText.text = tip;
    
    
    lblText.backgroundColor = [UIColor clearColor];
    [lblText setTextColor:[self colorWithHexString:@"#333333"]];
    [lblText setFont:[UIFont systemFontOfSize:13]];
    [lblText sizeToFit];
    [toastView setFrame:CGRectMake(0, 0, 225 * screenProportionNew, lblText.frame.size.height + 45)];
    imageV.frame = toastView.frame;
    lblText.center = toastView.center;
    toastView.center = backView.center;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            backView.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
            [backView removeFromSuperview];
        }];
        
    });
    
}

//字典转JSON字符串
+(NSString *)dictionaryToJsonStr:(NSDictionary *)dic
{
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
}


/**
 json字符串转字典

 @param jsonStr json字符串
 @return 字典
 */
+(NSDictionary *)jsonStrToDictionary:(NSString *)jsonStr
{
    
    if ([jsonStr isKindOfClass: [NSDictionary class]]) {
        NSDictionary *jsonDic = (NSDictionary *)jsonStr;
        return jsonDic;
    }
    
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary * dic = [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil]];
    return dic;
}


//字符串压缩
+ (NSData *)dataByGZipCompressing:(NSData *)aData {
    NSData *result = nil;
    @try {
        if ([aData length] == 0) {
            return aData;
        }
        
        z_stream zStream;
        zStream.zalloc = Z_NULL;
        zStream.zfree = Z_NULL;
        zStream.opaque = Z_NULL;
        zStream.next_in = (Bytef *)[aData bytes];
        zStream.avail_in = (uInt)[aData length];
        zStream.total_out = 0;
        
        if (deflateInit2(&zStream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, 15+16, 8, Z_DEFAULT_STRATEGY) != Z_OK) {
            return aData;
        }
        
        NSUInteger compressionChunkSize = 16384; // 16Kb
        NSMutableData *compressedData = [NSMutableData dataWithLength:compressionChunkSize];
        
        do {
            if (zStream.total_out >= [compressedData length]) {
                [compressedData increaseLengthBy:compressionChunkSize];
            }
            
            zStream.next_out = [compressedData mutableBytes] + zStream.total_out;
            zStream.avail_out = (uInt)([compressedData length] - zStream.total_out);
            
            deflate(&zStream, Z_FINISH);
        } while (zStream.avail_out == 0);
        
        deflateEnd(&zStream);
        [compressedData setLength:zStream.total_out];
        
        result = [NSData dataWithData:compressedData];
    }
    @catch (NSException *exception) {
    }
    
    return result;
}

//字符串解压
+ (NSData *)uncompressGZippedData:(NSData *)compressedData {
    NSData *result = nil;
    @try {
        if ([compressedData length] == 0) {
            return compressedData;
        }
        
        NSUInteger full_length = [compressedData length];
        NSUInteger half_length = [compressedData length] / 2;
        NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
        BOOL done = NO;
        int status;
        
        z_stream strm;
        strm.next_in = (Bytef *)[compressedData bytes];
        strm.avail_in = (uInt)[compressedData length];
        strm.total_out = 0;
        strm.zalloc = Z_NULL;
        strm.zfree = Z_NULL;
        if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
        
        while (!done) {
            // Make sure we have enough room and reset the lengths.
            if (strm.total_out >= [decompressed length]) {
                [decompressed increaseLengthBy:half_length];
            }
            strm.next_out = [decompressed mutableBytes] + strm.total_out;
            strm.avail_out = (uInt)([decompressed length] - strm.total_out);
            // Inflate another chunk.
            status = inflate (&strm, Z_SYNC_FLUSH);
            if (status == Z_STREAM_END) {
                done = YES;
            } else if (status != Z_OK) {
                break;
            }
        }
        
        if (inflateEnd (&strm) != Z_OK) return nil;
        // Set real length.
        if (done) {
            [decompressed setLength:strm.total_out];
            result = [NSData dataWithData:decompressed];
        }
    }
    @catch (NSException *exception) {
    }
    
    return result;
}
#pragma mark - 中文转码
//A_ly  增加中文字符转码   在上送中文字符时候转一下再上送  防止乱码
+(NSString *)transString:(NSString *)str  code:(NSStringEncoding)code
{
    NSString * codeStr = [str stringByAddingPercentEscapesUsingEncoding:code];
    return codeStr;
}

//金额格式化
+(NSString *)amountFormatWithAmountStr:(NSString *)amountStr {
    
    NSRange markRange =  [amountStr rangeOfString:@"."];
    
    if (markRange.location == NSNotFound) {
        //金额没有小数位
        amountStr = [amountStr stringByAppendingString:@".00"];
    } else {
        //有小数位
        NSString *doubleStr = [amountStr substringFromIndex:markRange.location];
        
        amountStr = [amountStr stringByAppendingString:[@"00" substringToIndex:3-doubleStr.length]];
    }
    
    return amountStr;
    
}
//格式化 币种比金额字号小，首位必须是币种符号 eg：￥1213.04  或$ 12.9等
//string：要格式化的金额（￥123.04）font：字号  smallFont：币种字号
+(NSMutableAttributedString *)setAttribute:(NSString *)string font:(float)font smallFont:(float)smallFont isBold:(BOOL)isBold
{
    if (string.length == 0) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];

    [attrString addAttribute:NSForegroundColorAttributeName value:[StaticTools colorWithHexString:@"#333333"] range:NSMakeRange(0, attrString.length)];

    if (isBold) {
        [attrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:font] range:NSMakeRange(0, attrString.length)];
        [attrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:smallFont] range:NSMakeRange(0, 1)];
    }
    else{
        [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:font] range:NSMakeRange(0, attrString.length)];
        [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:smallFont] range:NSMakeRange(0, 1)];
    }
    
    return attrString;
}
/**
 格式化 币种比金额字号小
 
 @param wholeStr  展示的字符串-包含币种和金额
 @param code      币种字符串
 @param font      大字号-金额
 @param smallFont 小字号-币种
 @param isBold    是否加粗:YES加粗
 @return 格式化后的Attribute字符串
 */
+(NSMutableAttributedString *)setAttributeShow:(NSString *)wholeStr code:(NSString *)code font:(float)font smallFont:(float)smallFont isBold:(BOOL)isBold color:(NSString *)color
{
    if (wholeStr.length == 0) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:wholeStr];
    [attrString addAttribute:NSForegroundColorAttributeName value:[StaticTools colorWithHexString:color] range:NSMakeRange(0, attrString.length)];
    NSRange range = [wholeStr rangeOfString:code];
    if (isBold) {
        [attrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:font] range:NSMakeRange(0, attrString.length)];
        [attrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:smallFont] range:range];
    }
    else{
        [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:font] range:NSMakeRange(0, attrString.length)];
        [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:smallFont] range:range];
    }
    
    return attrString;
}

/**
 CF转为NS     二维码密码控件RS密钥转换
 
 @param input 输入字符串
 @return 输出字符串
 */
+ (NSString *)encodeToPercentEscapeString:(NSString *)input
{
    //__bridge_transfer ---- ARC接管管理内存
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)input, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}


+ (NSString *)qrcodeMessage:(NSString *)key{
    
    //获取路径
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path1 = [pathArray objectAtIndex:0];
    NSString *myPath = [path1 stringByAppendingPathComponent:@"QRCode.plist"];
    
    //获取沙盒数据
    NSMutableDictionary *usersDic = [[NSMutableDictionary alloc]initWithContentsOfFile:myPath];
    NSDictionary *requestDic =[usersDic objectForKey:key];
    
    NSString * resultStr;
    
    if (requestDic) { //请求的数据不为空
        
        resultStr = [requestDic objectForKeyWithOutNull:@"tisValue"];
        
    } else {  //获取bundle下的本地数据
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"QRCode" ofType:@"plist"];
        NSMutableDictionary *bundleDic = [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
        
        NSDictionary *contentDic =[bundleDic objectForKey:key];
        
        resultStr = [contentDic objectForKeyWithOutNull:@"tisValue"];
    }
    if (resultStr.length <= 0)
    {
        resultStr = @"操作失败";
    }
    return resultStr;
}

/**
 分享出去带下载条的链接
 
 @param shareUrl 需要分享的url
 @param titleString 标题
 @return 带下载条的URL
 */
+ (NSString *) getUrlWithDownloadBar:(NSString * )shareUrl title:(NSString *)titleString
{
    if (shareUrl.length <= 0) {
        return @"";
    }
    
    
    //UTF8编码两遍 后台要求的
    shareUrl = [shareUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    shareUrl = [shareUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //特殊字符编码
    shareUrl = [self characterStringEncode:shareUrl];
    
    if (titleString.length == 0)
    {
        titleString = @"";
    }
    //标题编码 两遍 后台要求的
    titleString = [titleString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    titleString = [titleString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //加上缤纷生活下载条 (分享的H5 顶上加缤纷生活下载条)
    NSString * shareUrlString= [NSString stringWithFormat:@"%@getUrl.do?mlife=1&t=%@&r=%@",MLife_URL,titleString,shareUrl];
    return shareUrlString;
}

/**
 特殊字符编码
 
 @param NSString
 @return NSString
 */
 + (NSString *)characterStringEncode:(NSString *)str
{
    
    return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"?=/:&"].invertedSet];
}

+ (NSString *)getPhoneType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
}

#pragma mark - P904人工客服表情
//传入图片名称和bundle名称  获取图片
+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName
{
    UIImage *image = nil;
    if (name.length == 0 || bundleName.length == 0) {
        return [[UIImage alloc] init];
    }
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    NSBundle * emojiBundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString * imgPath = [emojiBundle pathForResource:name ofType:@"png"];
    NSArray * arr = [name componentsSeparatedByString:@"."];
    if (arr.count > 1) {
        imgPath = [emojiBundle pathForResource:arr[0] ofType:arr[1]];
    }
    image = [UIImage imageWithContentsOfFile:imgPath];
    return image ? image : [[UIImage alloc] init];
}

//根据表情的文字->显示表情     [微笑]->😊
+ (NSMutableAttributedString *)setTextWithEmoji:(NSString *)emojiStr label:(UILabel *)label
{
    NSMutableAttributedString * attr = [[NSMutableAttributedString alloc] initWithString:emojiStr];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"EmotionIcon" ofType:@"plist"];
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray * emojiStrArray = dic.allKeys;
    
    for (NSString * key in emojiStrArray) {
        NSRange range = [emojiStr rangeOfString:key];
        if (range.location != NSNotFound) {
            //取的图片image
            UIImage * image = [self imageNamed:[dic objectForKeyWithOutNull:key] ofBundle:@"Emotion"];
            
            //设定富文本
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.image = image;
            attach.bounds = CGRectMake(0, 0 , label.font.pointSize + 2, label.font.pointSize);
            NSAttributedString *imgStr = [NSAttributedString attributedStringWithAttachment:attach];
            
            //把表情字符串替换成图片
            [attr replaceCharactersInRange:range withAttributedString:imgStr];
            [emojiStr stringByReplacingCharactersInRange:range withString:@""];
        }
    }
    
    return attr;
}
@end
