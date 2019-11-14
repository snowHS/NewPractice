//
//  EmojiKBViewController.m
//  NewPractice
//
//  Created by SL123 on 2019/9/9.
//  Copyright © 2019 SL123. All rights reserved.
//

#import "EmojiKBViewController.h"
#import "PPUtil.h"
#import "PPStickerKeyboard.h"

@interface EmojiKBViewController ()<UITextFieldDelegate,PPStickerKeyboardDelegate>

@property (nonatomic,strong) UITextField * tf;
@property (nonatomic,strong) UIButton * btn;
@property (nonatomic,strong) UILabel * label;
@property (nonatomic, strong) PPStickerKeyboard *stickerKeyboard;


@end

@implementation EmojiKBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"表情键盘";
    [self.view addSubview:self.stickerKeyboard];
    self.stickerKeyboard.hidden = YES;
    [self.stickerKeyboard mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self.view).offset(0);
            
        }
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.height.mas_equalTo(0);
        make.width.mas_equalTo(ScreenWidth);
    }];
    
    self.tf = [[UITextField alloc] init];
    [self.tf setBorderStyle:UITextBorderStyleRoundedRect];
    self.tf.delegate = self;
    [self.view addSubview:self.tf];
    [self.tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.stickerKeyboard.mas_top).offset(0);
        make.leading.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
   
    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn setTitle:@"表情" forState:UIControlStateNormal];
    [self.btn setImage:[UIImage imageNamed:@"toggle_emoji"] forState:UIControlStateNormal];
    [self.btn setBackgroundColor:[UIColor lightGrayColor]];
    [self.btn addTarget:self action:@selector(changeKeBoard:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.btn];
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tf.mas_top).offset(0);
        make.leading.equalTo(self.tf.mas_trailing).offset(10);
        make.trailing.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(70);

    }];
  
    self.label = [[UILabel alloc] init];
    self.label.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view);
            
        }
        make.bottom.equalTo(self.tf.mas_top);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);

    }];
}
-(void)changeKeBoard:(UIButton *)btn
{
    self.btn.selected = !self.btn.selected;
    self.stickerKeyboard.hidden = !self.btn.selected;
    if (self.btn.selected) {
        [self.btn setTitle:@"文字" forState:UIControlStateNormal];
        
    }
    else {
        [self.btn setTitle:@"表情" forState:UIControlStateNormal];
    }
    [self.stickerKeyboard mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self.view);
            
        }
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.height.mas_equalTo(self.btn.selected ? 237 : 0);
        make.width.mas_equalTo(ScreenWidth);
        
    }];
    [self.tf becomeFirstResponder];
    
}
- (PPStickerKeyboard *)stickerKeyboard
{
    if (!_stickerKeyboard) {
        _stickerKeyboard = [[PPStickerKeyboard alloc] init];
        _stickerKeyboard.delegate = self;
        
    }
    return _stickerKeyboard;
}
#pragma mark - PPStickerKeyboardDelegate

- (void)stickerKeyboard:(PPStickerKeyboard *)stickerKeyboard didClickEmoji:(PPEmoji *)emoji
{
    if (!emoji) {
        return;
    }
    
    UIImage *emojiImage = [UIImage imageNamed:[@"Sticker.bundle" stringByAppendingPathComponent:emoji.imageName]];
    if (!emojiImage) {
        return;
    }
    
    NSRange selectedRange = [self selectedRange:self.tf];
    NSString *emojiString = [NSString stringWithFormat:@"[%@]", emoji.emojiDescription];
    NSMutableAttributedString *emojiAttributedString = [[NSMutableAttributedString alloc] initWithString:emojiString];
    [emojiAttributedString pp_setTextBackedString:[PPTextBackedString stringWithString:emojiString] range:emojiAttributedString.pp_rangeOfAll];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.tf.attributedText];
    [attributedText replaceCharactersInRange:selectedRange withAttributedString:emojiAttributedString];
    self.tf.attributedText = attributedText;

}

- (void)stickerKeyboardDidClickDeleteButton:(PPStickerKeyboard *)stickerKeyboard
{
    NSRange selectedRange = [self selectedRange:self.tf];
    if (selectedRange.location == 0 && selectedRange.length == 0) {
        return;
    }
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.tf.attributedText];
    if (selectedRange.length > 0) {
        [attributedText deleteCharactersInRange:selectedRange];
        self.tf.attributedText = attributedText;
//        self.tf.selectedRange = NSMakeRange(selectedRange.location, 0);
    } else {
        NSUInteger deleteCharactersCount = 1;
        
        // 下面这段正则匹配是用来匹配文本中的所有系统自带的 emoji 表情，以确认删除按钮将要删除的是否是 emoji。这个正则匹配可以匹配绝大部分的 emoji，得到该 emoji 的正确的 length 值；不过会将某些 combined emoji（如 👨‍👩‍👧‍👦 👨‍👩‍👧‍👦 👨‍👨‍👧‍👧），这种几个 emoji 拼在一起的 combined emoji 则会被匹配成几个个体，删除时会把 combine emoji 拆成个体。瑕不掩瑜，大部分情况下表现正确，至少也不会出现删除 emoji 时崩溃的问题了。
        NSString *emojiPattern1 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900-\\U0001F9FF]";
        NSString *emojiPattern2 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900–\\U0001F9FF]\\uFE0F";
        NSString *emojiPattern3 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900–\\U0001F9FF][\\U0001F3FB-\\U0001F3FF]";
        NSString *emojiPattern4 = @"[\\rU0001F1E6-\\U0001F1FF][\\U0001F1E6-\\U0001F1FF]";
        NSString *pattern = [[NSString alloc] initWithFormat:@"%@|%@|%@|%@", emojiPattern4, emojiPattern3, emojiPattern2, emojiPattern1];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:NULL];
        NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:attributedText.string options:kNilOptions range:NSMakeRange(0, attributedText.string.length)];
        for (NSTextCheckingResult *match in matches) {
            if (match.range.location + match.range.length == selectedRange.location) {
                deleteCharactersCount = match.range.length;
                break;
            }
        }
        
        [attributedText deleteCharactersInRange:NSMakeRange(selectedRange.location - deleteCharactersCount, deleteCharactersCount)];
        self.tf.attributedText = attributedText;
//        self.tf.selectedRange = NSMakeRange(selectedRange.location - deleteCharactersCount, 0);
    }
    
    [self textField:self.tf shouldChangeCharactersInRange:selectedRange replacementString:[NSString stringWithFormat:@"%@",attributedText]];
}

- (void)stickerKeyboardDidClickSendButton:(PPStickerKeyboard *)stickerKeyboard
{
    self.label.text = self.tf.text;
    self.tf.text = @"";
}
- (NSRange)selectedRange:(UITextField *)textField
{
    UITextPosition* beginning = textField.beginningOfDocument;
    UITextRange* selectedRange = textField.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    const NSInteger location = [textField offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [textField offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}
#pragma mark - textFieled
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
