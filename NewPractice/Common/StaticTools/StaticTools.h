//
//  StaticTools.h
//  MLife
//
//  Created by user on 11-8-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


//picker弹出和弹回所需时间
#define PICKER_TIME .6
#define hasGoneCinema @" 去过的影院"
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "MyNavigationController.h"
//A_wangchuan20160114 pickerView
#import <CommonCrypto/CommonDigest.h>

typedef void(^ShareBlock)(UIImage * img,NSString * shareUrl,NSString * shareContent,NSString * shareName);
typedef void(^failedBlock)(NSString * result);

typedef void(^BannerBlock)(NSArray *listData,NSString * menuName);
typedef void(^BannerfailedBlock)(NSString * result);

static int alertTimerCount;

@interface StaticTools : NSObject {

}

typedef enum
{
    CAlertTypeDefault = 0,  //默认只有一个确定按钮
    CAlertTypeCancel,       //取消/确定
    CAlertTypeUpdate,       //稍后再说/立即更新
    CAlertTypeRelogin,      //取消/重新登录
    CalertTypeRedo,         //关闭/重试
    CalertTypeEXpay,        //取消/购汇还款 A_wangchuan20160328
    CalertTypeRetry,        //取消/重试

} CAlertStyle;
//add by zhangke 数据存储枚举 
typedef enum {
	/** pList */
	DataModePlist,
	/** UserDefault */
	DataModeUserDefault,
	/** DB */
	DataModeDB
} DataMode;


//获取当前语言环境
+(NSString*)deviceLanguages;

//校验字符串是否为空
+(BOOL)isEmptyString:(NSString*)string;

//删除用户的购物车数据
+ (void)cleanShoppinCartCache:(NSString *)plistName;

//检查Documents里是否有此文件
+ (BOOL)fileExistsAtPath:(NSString *)fileName;
+ (NSString *)getFilePath:(NSString *)fileName;
+ (void)cleanCacheImg:(void (^) (BOOL))completion;
//写文件
+ (void)saveFile:(NSMutableArray *)array fileName:(NSString *)fileName;
//取得购物车文件夹
+ (NSString *)getShoppingCartFilePath:(NSString *)fileName;
//判断是否超过规定时间
+ (BOOL)OutofDate:(NSTimeInterval)anotherDate userDefined:(NSTimeInterval)timerInterval;

//网上预约 登录页面 生成随机验证码
+ (NSString *)randomCode:(int)codeLength;

//航空会员号检验
+ (BOOL)checkAirMemberNo:(NSString *)memberNo airCode:(NSString *)airCode;

//判断邮政编码格式是否正确
+ (BOOL)checkZipCode:(NSString *)coder;

//判断输入是否全部都是数字
+ (BOOL)checkAllIsNumber:(NSString *)psw;

/**
 *	@brief	判断一个字符串是否为整型数字
 */
+ (BOOL) isPUreInt:(NSString*)string;

//判断输入是否全部都是字符（不允许有汉字、数字等） 不能为空
+ (BOOL)checkAllIsLetter:(NSString *)psw;

//判断用户名 1：小于30位。2：数字＋字母。3：不能包含其它字符
+ (BOOL)checkUserName:(NSString *)psw;

//判断密码 1：8－16位置。2：数字＋字母。3：不能全是数字或全是字母
+ (BOOL)checkPsw:(NSString *)psw;

//判断输入是否有特殊字符
+ (BOOL)checkIsThereHasSpecialLetter:(NSString *)psw;
    
//从ducument文件夹中的userInfo.plist提取UserName
+ (NSString *)getUserNameFromPlist;

//把2002-09-12变成2002年09月12日
+ (NSString *)stringFormat:(NSString *)sourceString;


//显示picker
+(void)showPicker:(UIToolbar *)toolbar picker:(UIPickerView *)picker;
//去掉picker
+(void)removePicker:(UIToolbar *)toolbar picker:(UIPickerView *)picker;
//显示日期picker
+(void)showDatePicker:(UIToolbar *)toolbar picker:(UIDatePicker *)picker;
//去掉日期picker
+(void)removeDatePicker:(UIToolbar *)toolbar picker:(UIDatePicker *)picker;

//获取当前时间 精确到毫秒
+ (NSString *)getCurrencyTime;

#pragma mark - ---showAlert---
/**
 只有确定按钮，没有点击事件的alert

 @param alertString 提示语，不可为空
 @param controller 控制器，可为空
 */
+ (void)showAlertTitle:(NSString *)titleStr withMessage:(NSString *)alertString withController:(UIViewController *)controller;

+ (void)showImageAlertTitle:(NSString *)titleStr imageName:(NSString *)imageName withMessage:(NSString *)alertString actionTitle:(NSString *)actionTitle withController:(UIViewController *)controller;

/**
 有点击事件的alert

 @param title 缤纷生活alert统一没有title
 @param message 提示语，不可为空
 @param viewC 控制器，可为空
 @param cancelTitle 取消按钮title，没有时传nil或@""
 @param cancelBlock 取消按钮的点击事件，没有时传nil
 @param otherTitle 其他按钮title，不可为空。
 @param otherBlock 其他按钮点击事件
 */
+ (void)showAlertTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewC cancelTitle:(NSString *)cancelTitle cancelMethod:(void(^)(void))cancelBlock otherTitle:(NSString *)otherTitle otherMethod:(void(^)(void))otherBlock __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_8_0);
+ (void)showAttributeAlertTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewC cancelTitle:(NSString *)cancelTitle cancelMethod:(void(^)(void))cancelBlock otherTitle:(NSString *)otherTitle otherMethod:(void(^)(void))otherBlock;
/**
 颜色翻转
 */
+ (void)showAlertTurnTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewC cancelTitle:(NSString *)cancelTitle cancelMethod:(void(^)(void))cancelBlock otherTitle:(NSString *)otherTitle otherMethod:(void(^)(void))otherBlock;

//为了有些不固定个数的ActionSheet，加一个array参数。
+ (void)showActionTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewC buttonTitles:(NSArray *)btnArr seletIndex:(void(^)(int index))selectBlock __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_8_0);

//辅助密码检测定制 不固定个数actionAlert，但去除默认取消按钮
+ (void)showActionTitleOfChecking:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewC buttonTitles:(NSArray *)btnArr seletIndex:(void(^)(int index))selectBlock;
#pragma mark -

//MARK: - DateMethod

//判断两个时间的日期间隔  日期的格式必须是2011－01－01或者2011/01/01
+ (double)checkTimeInterval:(NSString *)beginData endData:(NSString *)endData;

//add by chenqingxian 20130108
//判断两个时间点的间隔  时间的格式必须是21：30
+ (double)checkTimeIntervalbeginTime:(NSString *)beginTime endData:(NSString *)endTime;

//返回各个列表页面的缓存数据
+ (NSMutableArray *)getCacheArray:(NSString *)cacheType;

//保存各个列表页面的缓存数据
+ (void)saveDefaultData:(NSMutableArray *)dateArray cacheType:(NSString *)cacheType showMore:(BOOL)showMore;

//清除默认列表数据
+ (void)cleanCacheArray;



//获取临时文件大小
+(void)getCacheSize:(void (^)(unsigned long long int))sizeBlock;


//取得今天的日期 yyyy-MM-dd
+ (NSString *)getTodayDate;

//取得今天的日期 yyyy-MM-dd 用typeStr (- /分割)
+ (NSString *)getTodayDateWithType:(NSString *)typeStr;
//返回给定时间加减年月日后的日期
+(NSString *)backTheDateAdding:(NSDate *)date year:(int)epYear month:(int)epMonth day:(int)epDay;
//取得startDate后days的日期 yyyy-MM-dd
+ (NSString *)getAfterDate:(NSDate *)startDate days:(int)days;
//取得startDate前days的日期 yyyy-MM-dd
+ (NSString *)getBeforeDate:(NSDate *)startDate days:(int)days;
//取得startDate前days的日期 yyyy-MM-dd (string:输入-，或者/判断不同的格式)
+ (NSString *)getBeforeDate:(NSDate *)startDate days:(int)days for:(NSString *)string;
//把string，以type0分割，并，以type1拼接
+ (NSString *)changeString:(NSString *)string fromType:(NSString *)type0 withType:(NSString *)type1;

//add by wenbin 2013-6-28
//获取指定日期的字符串表达式
+(NSString *)getDateStrWithDate:(NSDate*)someDate withCutStr:(NSString*)cutStr hasTime:(BOOL)hasTime;
//从指定日期字符串的初始化一个NSdate
+ (NSDate*)getDateFromDateStr:(NSString*)dateStr;
//获取指定日期的年份字符串
+ (NSString *)getYearStrOfDate:(NSDate*)someDate;
//获取指定日期的月份字符串
+ (NSString *)getMonthStrOfDate:(NSDate*)someDate;
//获取指定日期的日期字符串
+ (NSString *)getDayStrOfDate:(NSDate*)someDate;
//获取指定格式日期的字符串
+ (NSString *)getHourStrOfDate:(NSDate*)someDate withFormat:(NSString *)format;

//返回对指定日期进行年 月 日加减操作后的日期
+ (NSDate*)getDateFromDate:(NSDate*)someDate withYear:(int)changYear month:(int)changeMonth day:(int)changeDay;
//获取两个指定日期之间相隔的长度
+ (NSDateComponents*)getDateDistanceFromDate:(NSDate*)beginDate toDate:(NSDate*)endDate withType:(int)type;
//金额添加千分符
+ (NSString *)moneyWithComma:(NSString *)moneyStr;

+ (NSString *)intMoneyWithComma:(NSString *)moneyStr;

//根据币种的精度，格式化金额，小数点后保留N位，加入千分符
//precision: 币种精度，传@""或者nil 小数位不变，不做格式化
+ (NSString *)moneyWithComma:(NSString *)moneyStr precision:(NSString *)precision;


//A_liuxiaolong20130716:将yymmdd日期格式转化成yy-mm-dd
+ (NSString *)changeDateString:(NSString *)dateStr;

//imge拼图 返回一个拼好的image  add by wenbin 2013-7-3 从重写项目里拿过来的
+ (UIImage *)getImageFromImage:(UIImage *)imageLeftOrTop centerImage:(UIImage *)imageCenter finalImage:(UIImage *)imageRightOrBottom withSize:(CGSize)resultSize;

//计算两个时间差
+ (int)getLeftTime:(NSString *)dateTimeString messageTime:(NSString *)messageTime;
//endTime - startTimeStr  是否为正
+ (int)getFromTime:(NSString *)startTimeStr toTime:(NSString *)endTimeStr;

//16进制颜色(html颜色值)字符串转为UIColor
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

//格式化电话号码
+(NSString *)formatedString:(NSString *)string;

//返回label的高度
+(float)getLabelHeigth:(NSString *)textString defautWidth:(float)defautWidth defautHeigth:(float)defautHeigth fontSize:(int)fontSize;

//返回label的宽度
+(float)getLabelWidth:(NSString *)textString defautWidth:(float)defautWidth defautHeigth:(float)defautHeigth fontSize:(int)fontSize;



//add by yzf 20121217   保存数据到缓存
+ (void)saveData:(NSMutableArray *)dataArray cacheType:(NSString *)cacheType dataNum:(NSInteger)num;
//add by yzf 20121217  删除缓存数据
+ (void)removeDataForKey:(NSString *)key;
+ (void)showDatePicker:(UIView*)view;
+(void)removeDatePicker2:(UIView *)view;
//add by dongyan 20130115 转换时区
+(NSDate *)convertDateToLocalTime:(NSDate *)forDate;


#pragma mark - A_liuxl:新加 HUD 样式
+ (void)showHUDInView:(UIView *)superView HudType:(MBProgressHUDMode)hudType withText:(NSString *)labelText delegate:(id)delegate delay:(float)delay animated:(BOOL)animated;
//add by chenqingxian 20130226
+(void)showHUDInView:(UIView*)superView HudType:(MBProgressHUDMode)hudType withText:(NSString*)lableText;

/**
 自定义hud样式 可设置自定义背景色,自定义图片,自定义文字
 
 @param superView 图层位置
 @param lableText 展示文字
 @param image 展示图片
 @param hudColor 背景颜色
 */
+(void)showCustomHUDInView:(UIView*)superView withText:(NSString*)lableText withImage:(NSString *)image withHudColor:(UIColor *)hudColor;
/**
 展示文字标签
 
 @param superView 展示图层
 @param lableText 展示文字
 @param bgColor 背景颜色
 @param hudColor hud颜色
 */
+(void)showTextHUDInView:(UIView*)superView withText:(NSString*)lableText withBGColor:(UIColor *)bgColor withHudColor:(UIColor *)hudColor;


//隐藏等待框 add by zhangjilin 20130308
+(void)removeHUDFromView:(UIView*)superView;

+ (BOOL)checkArrayValid:(NSArray *)array;//解析的时候检测数组array是否有效

+ (UIView *)getCommonCellView:(float)cell_h textWidth:(float)text_w withText:(NSString *)cell_text
					 textFont:(UIFont *)text_font textColor:(UIColor *)text_color withBorder:(BOOL)has_border;

// add by wangxin 20130829
+ (NSString *)readTwoCodeData:(NSString *)cacheType;
+ (void)saveTwoCodeData:(NSString *)twoDImageStr cacheType:(NSString *)cacheType;

#pragma mark -
#pragma mark 存储操作
#pragma mark -
#pragma mark 存储到plist、userDefault、db(如果想存入db，则该数据字典每个元素必须是nsstring,若有的字段不需要存储，则该字段在dataDic中传入@“”)
+ (BOOL)saveData:(NSMutableDictionary *)dataDic cacheType:(DataMode)cacheType dataName:(NSString*)name;

#pragma mark - NewAdd
#pragma mark 自增主键存储到db专用
+ (BOOL)saveKeyData:(NSMutableDictionary *)dataDic dataName:(NSString*)name;

#pragma mark -
#pragma mark 读取plist、userDefault、db中的该name下的所有数据
+(NSMutableDictionary*)readData:(DataMode)cacheType dataName:(NSString*)name;

#pragma mark -
#pragma mark 更新plist、userDefault、db中的数据(db 时需要传入条件字典 ，其他可传入nil)
+ (BOOL)updateData:(NSMutableDictionary *)newDataDic cacheType:(DataMode)cacheType name:(NSString*)name DBWhere:(NSMutableDictionary*)dbWhere;

#pragma mark -
#pragma mark 清空plist、userDefault、db中指定的数据
+(BOOL)clearData:(DataMode)cacheType dataName:(NSString*)name;

#pragma mark -
#pragma mark DB操作

#pragma mark -
#pragma mark 创建数据库
+ (void)setupDatabase:(NSString*)dbName;

#pragma mark -
#pragma mark 创建表结构
+(BOOL)createTable:(NSArray*)linesNames tableName:(NSString*)tableName;

#pragma mark -
#pragma mark 创建表结构自增主键
+(BOOL)createKeyTable:(NSArray*)linesNames tableName:(NSString*)tableName;

#pragma mark -
#pragma mark 根据条件删除数据
+(BOOL)deleteWithWhere:(NSMutableDictionary*)whereDict tableName:(NSString*)tableName;

#pragma mark -
#pragma mark 根据条件读取数据
+(NSMutableArray*)readWithWhere:(NSMutableDictionary*)whereDict  tableName:(NSString*)tableName;

#pragma mark -
#pragma mark 根据条件排序数据
+ (NSMutableArray *)sortKey:(NSString *)sortKey tableName:(NSString *)tableName andWhere:(NSMutableDictionary *)whereDic;

#pragma mark -
#pragma mark 返回指定表中所有列名
+(NSMutableArray*)backTheLineNames:(NSString*)tableName;

#pragma mark -
#pragma mark 向指定表中插入一列
+(BOOL)addColumn:(NSString*)tableName lingName:(NSString*)lingName;

#pragma mark -
#pragma mark 查看该数据库中所有表名
+(NSArray*)seeTablesInDB;

#pragma mark -
#pragma mark 删除指定表
+(BOOL)deleteTable:(NSString*)tableName;

#pragma mark -
#pragma mark - ————去掉cell多余的分割线
+ (void)setExtraCellLineHidden: (UITableView *)tableView;

//取银行金额    金额＋长度＋小数点几位＋类型
+(NSString *)formatMoney:(NSString *)money withLength:(int)length withFloat:(int)num withType:(int)type;

/*
 add by ly 201307  设置金额格式,传入金额和币种，如果金额中包含该币种，设置金额数目为小数点后两位的形式，如果未包含该币种，则设置金额数目形式后添加该币种,如果金额中不添加币种，则直接传空。该方法只用于显示金额，调完得查看返回有没有什么问题
 */
+ (NSString *)setFloatMoneyString :(NSString *)moneyStr moneyCode:(NSString *)moneyCodeStr;

/*
 // add by ly 201308 键盘编辑时,控制金额的输入，精确到小数点后两位
 */
+ (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

// add by wangxin 20130911 解密
+ (NSString *)decCardNoMethod:(NSString *)cardNoStr withDesKey:(NSString *)desKeyStr DEPRECATED_MSG_ATTRIBUTE("Use NSString+Formatter .decValue instead");

// add by wangxin 20130911 加密
+(NSString *)desCardNoMethod:(NSString *)cardNoStr withDesKey:(NSString *)desKeyStr DEPRECATED_MSG_ATTRIBUTE("Use NSString+Formatter .desValue instead");
// add by wangxin 20130911 格式化输入的金额 格式化成xxx.xx保留小数点后两位（xxx为任意位）
+ (NSString *)moneyFormatterMethod:(NSString *)textFieldTextStr;

//判断身份证正确性
+(BOOL)isIdentityNum:(NSString*)bankNum;


/**
 安全模式卡号

 @param cardNoStr 卡号
 @return 6666 **** **** 6666
 */
+ (NSString *)setCardNoAsterisk:(NSString *)cardNoStr;


/**
 证件号加*
 
 @param certNo 全显示的证件号
 @return 加*后的证件号
 */
+ (NSString *)setCertNoAsterisk:(NSString *)certNo;

/**
 姓名加*
 
 @param nameStr 姓名
 @return *名
 */
+ (NSString *)setNameAsterisk:(NSString *)nameStr;

/**
 安全模式手机号
 
 @param phoneNoStr 手机号
 @return 133****3345手机号
 */
+ (NSString *)setPhoneNoAsterisk:(NSString *)phoneNoStr;

//@return 133****3345手机号

+ (NSString *)setSafePhoneNum:(NSString *)phoneNoStr;


/**
 把卡号每隔四位分开

 @param cardNo 卡号字符串 62221234567890
 @return 6222 1234 5678 90
 */
+(NSString *)formatterBankCardNum:(NSString *)cardNo;


// 正则判断手机号码地址格式
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

+ (void)setRound:(UIView *)view byCorners:(UIRectCorner)corner radius:(CGFloat)radius;


#pragma mark - ————给view加圆角和边框及颜色
/**
 *  给view加圆角和边框（没有阴影，需要阴影就自己写ShadowOffset）
 *
 *  @param radius 弧度
 *  @param width  边框的宽度
 *  @param color  边框的颜色
 */
+ (void)setRoundView:(UIView *)view radius:(CGFloat)radius borderWidth:(CGFloat)width color:(UIColor *)color;

#pragma mark - ————返回按钮，本来想放在base里，但很多都不继承base，那就放这里吧，0123:只剩两个地方
+ (void)setNavigationBackButton:(UIViewController *)view;

//起点纬度、起点经度、终点纬度、终点经线，返回值单位公里
+ (double)LatitudeX:(double)latX longitudeX:(double)lngX;

+ (void)classToDictionaryWithClass:(Class)className;


+ (NSAttributedString *)getAttributedHTMLStr:(NSString *)htmlStr;

+(void)talkingData_home:(NSString *)talk withLabel:(NSString *)label;

+ (NSString *)MD5WithStr:(NSString *)str;

+ (void)showNotDataView:(UIView *)superView titleStr:(NSString *)titleStr isAddflag:(BOOL)isAdd;

//A_wangchuan 20161025   只有文字
+(void)showToastWithTip:(NSString *)tip;
//带图片背景的toast
+(void)showToastWithTip:(NSString *)tip image:(NSString *)imageStr;
//字典转JSON字符串
+(NSString *)dictionaryToJsonStr:(NSDictionary *)dic;

/**
 json字符串转字典
 
 @param jsonStr json字符串
 @return 字典
 */
+(NSDictionary *)jsonStrToDictionary:(NSString *)jsonStr;

//压缩
+ (NSData *)dataByGZipCompressing:(NSData *)aData;

//解压
+ (NSData *)uncompressGZippedData:(NSData *)compressedData;
//A_ly  增加中文字符转码   在上送中文字符时候转一下再上送  防止乱码
+(NSString *)transString:(NSString *)str  code:(NSStringEncoding)code;

//金额加小数点
+(NSString *)amountFormatWithAmountStr:(NSString *)amountStr;

//格式化 币种比金额字号小，首位必须是币种符号 eg：￥1213.04  或$ 12.9等
//string：要格式化的金额（￥123.04）
//font：字号
//smallFont：币种字号
//isBold: 字体是否要加粗
+(NSMutableAttributedString *)setAttribute:(NSString *)string font:(float)font smallFont:(float)smallFont isBold:(BOOL)isBold;

/**
 格式化 币种比金额字号小,传入两个字符串,一个展示的,一个币种符号($ ¥)
 
 @param wholeStr  展示的字符串-包含币种和金额
 @param code      币种字符串
 @param font      大字号-金额
 @param smallFont 小字号-币种
 @param isBold    是否加粗:YES加粗
 @return 格式化后的Attribute字符串
 */
+(NSMutableAttributedString *)setAttributeShow:(NSString *)wholeStr code:(NSString *)code font:(float)font smallFont:(float)smallFont isBold:(BOOL)isBold color:(NSString *)color;
/**
 CF转为NS     二维码密码控件RS密钥转换
 
 @param input 输入字符串
 @return 输出字符串
 */
+ (NSString *)encodeToPercentEscapeString:(NSString *)input;


+ (NSString *)qrcodeMessage:(NSString *)key;


/**
 分享出去带下载条的链接

 @param shareUrl 需要分享的url
 @param titleString 标题
 @return 带下载条的URL
 */
+ (NSString *)getUrlWithDownloadBar:(NSString * )shareUrl title:(NSString *)titleString;

+ (NSString *)getPhoneType;


//传入图片名称和bundle名称  获取图片
+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName;

//根据表情的文字->显示表情     [微笑]->😊
+ (NSMutableAttributedString *)setTextWithEmoji:(NSString *)emojiStr label:(UILabel *)label;

@end
