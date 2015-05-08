//
//  SplitLabel.m
//

#import "SplitLabel.h"
#import <CoreText/CoreText.h>

@interface SplitLabel() <NSLayoutManagerDelegate>

@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, strong) NSLayoutManager *layoutManager;

@property (nonatomic, strong) NSMutableArray *glyphTextLayers;

@end

@implementation SplitLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTextKitStack];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupTextKitStack];
    
}

- (void)setBounds:(CGRect)bounds
{
    self.textContainer.size = bounds.size;
    super.bounds = bounds;
}

- (void)setFrame:(CGRect)frame
{
    self.textContainer.size = frame.size;
    super.frame = frame;
}

- (NSArray *)glyphLayers
{
    return self.glyphTextLayers;
}

#pragma mark - Text Kit stack

- (void)setupTextKitStack
{
    self.glyphTextLayers = [[NSMutableArray alloc] init];
    
    self.textStorage = [[NSTextStorage alloc] init];
    self.layoutManager = [[NSLayoutManager alloc] init];
    self.textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
    
    [self.textStorage addLayoutManager:self.layoutManager];
    [self.layoutManager addTextContainer:self.textContainer];
    self.layoutManager.delegate = self;
    
    [self setAttributedText:self.attributedText];
    
    // Hide the UILabel content
    [super setAttributedText:[[NSAttributedString alloc] initWithString:@""]];
    
}

#pragma mark - UILabel

- (void)setText:(NSString *)text
{
    // Apply the text attributes that are set on the UILabel
    NSRange wordRange = NSMakeRange(0, text.length);
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)self.textColor.CGColor range:wordRange];
    [attributedText addAttribute:(NSString *)kCTFontAttributeName value:self.font range:wordRange];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:self.textAlignment];
    [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:wordRange];
    [self setAttributedText:attributedText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if ([self.textStorage.string isEqualToString:attributedText.string]) {
        return;
    }
    
    // Triggers the text layout
    [self.textStorage setAttributedString:attributedText];
}

#pragma mark - UIView (Auto Layout)

- (CGSize)intrinsicContentSize
{
    // If Auto Layout is used to display the label, the intrinsicContentSize has to be slightly larger than the attributed text bounding rectangle
    // Otherwise the last two glyphs are merged together by the NSLayoutManager in a single rectangle
    CGRect labelRect = CGRectInset([self.textStorage boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin context:nil], -self.font.pointSize / 6, 0.0f);
    return labelRect.size;
}

#pragma mark - NSLayoutManagerDelegate

- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag
{
    // Reset the glyph layers each time the text is laid out
    [self.glyphTextLayers enumerateObjectsUsingBlock:^(CATextLayer *glyphTextLayer, NSUInteger idx, BOOL *stop) {
        [glyphTextLayer removeFromSuperlayer];
    }];
    [self.glyphTextLayers removeAllObjects];
    
    // Break the text in individual glyph layers
    NSRange wordRange = NSMakeRange(0, self.textStorage.string.length);
    
    for (NSUInteger glyphIndex = wordRange.location; glyphIndex < wordRange.length + wordRange.location; glyphIndex += 0) {
        
        NSRange glyphRange = NSMakeRange(glyphIndex, 1);
        
        CGRect glyphRect = [self.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:self.textContainer];
        
        CATextLayer *glyphTextLayer = [CATextLayer layer];
        glyphTextLayer.contentsScale = [[UIScreen mainScreen] scale];
        glyphTextLayer.frame = glyphRect;
        
        NSRange characterRange = [self.layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
        glyphTextLayer.string = [self.textStorage attributedSubstringFromRange:characterRange];
        
        [self.layer addSublayer:glyphTextLayer];
        [self.glyphTextLayers addObject:glyphTextLayer];
        
        glyphIndex += characterRange.length;
    }
}

@end
