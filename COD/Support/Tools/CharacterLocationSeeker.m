//
// CharacterLocationSeeker.m
// Version 0.0.2 Created on 16/1/05
//
// Copyright (c) 2015 FasaMo ( http://github.com/FasaMo ; http://weibo.com/FasaMo )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CharacterLocationSeeker.h"

@interface CharacterLocationSeeker ()
@property (strong, nonatomic) NSTextStorage *textStorage;
@property (strong, nonatomic) NSLayoutManager *layoutManager;
@property (strong, nonatomic) NSTextContainer *textContainer;
@end

@implementation CharacterLocationSeeker

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupBasic];
    }
    return self;
}

- (void)setupBasic
{
    self.textStorage = [NSTextStorage new];
    self.layoutManager = [NSLayoutManager new];
    self.textContainer = [NSTextContainer new];
    [self.textStorage addLayoutManager:self.layoutManager];
    [self.layoutManager addTextContainer:self.textContainer];
}

- (void)configWithLabel:(UILabel *)label
{
    self.textContainer.size = label.bounds.size;
    self.textContainer.lineFragmentPadding = 0;
    self.textContainer.maximumNumberOfLines = label.numberOfLines;
    self.textContainer.lineBreakMode = label.lineBreakMode;
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:label.attributedText];
    NSRange textRange = NSMakeRange(0, attributedText.length);
    [attributedText addAttribute:NSFontAttributeName value:label.font range:textRange];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = label.textAlignment;
    [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:textRange];
    [self.textStorage setAttributedString:attributedText];
}

- (CGRect)characterRectAtIndex:(NSUInteger)charIndex
{
    if (charIndex >= self.textStorage.length) {
        NSLog(@"Plz enter a correct number");
        return CGRectZero;
    }
    NSRange characterRange = NSMakeRange(charIndex, 1);
    NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:characterRange actualCharacterRange:nil];
    return [self.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:self.textContainer];
}

- (CGRect)lastCharacterRectForAttributedString:(NSAttributedString *)attributedString drawingRect:(CGRect)drawingRect
{
    // Start by creating a CTFrameRef using the attributed string and rect.
    CTFrameRef textFrame = NULL;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(attributedString));
    CGPathRef drawingPath = CGPathCreateWithRect(drawingRect, NULL);
    textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributedString length]), drawingPath, NULL);
    CFRelease(framesetter);
    CFRelease(drawingPath);
    
    // Line origins can be obtained from the CTFrameRef. Get the final one.
    CGPoint finalLineOrigin;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (CFArrayGetCount(lines) == 0) { // Safety check
        CFRelease(textFrame);
        return CGRectNull;
    }
    const CFIndex finalLineIdx = CFArrayGetCount(lines) - 1;
    CTFrameGetLineOrigins(textFrame, CFRangeMake(finalLineIdx, 1), &finalLineOrigin);
    
    // Get the glyph runs from the final line. Get the last glyph position from the final run.
    CGPoint glyphPosition;
    CFArrayRef runs = CTLineGetGlyphRuns(CFArrayGetValueAtIndex(lines, finalLineIdx));
    if (CFArrayGetCount(runs) == 0) { // Safety check
        CFRelease(textFrame);
        return CGRectNull;
    }
    CTRunRef finalRun = CFArrayGetValueAtIndex(runs, CFArrayGetCount(runs) - 1);
    if (CTRunGetGlyphCount(finalRun) == 0) { // Safety check
        CFRelease(textFrame);
        return CGRectNull;
    }
    const CFIndex lastGlyphIdx = CTRunGetGlyphCount(finalRun) - 1;
    CTRunGetPositions(finalRun, CFRangeMake(lastGlyphIdx, 1), &glyphPosition);
    
    // The bounding box of the glyph itself is extracted from the font.
    CGRect glyphBounds;
    CFDictionaryRef runAttributes = CTRunGetAttributes(finalRun);
    CTFontRef font = CFDictionaryGetValue(runAttributes, NSFontAttributeName);
    CGGlyph glyph;
    CTRunGetGlyphs(finalRun, CFRangeMake(lastGlyphIdx, 1), &glyph);
    CTFontGetBoundingRectsForGlyphs(font, kCTFontOrientationDefault, &glyph, &glyphBounds, 1);
    
    // Option 1 - The rect you've drawn in your question isn't tight to the final character; it looks approximately the height of the line. If that's what you're after:
    /*
    CGRect lineBounds = CTLineGetBoundsWithOptions(CFArrayGetValueAtIndex(lines, finalLineIdx), 0);
    CGRect desiredRect = CGRectMake(
                                    CGRectGetMinX(drawingRect) + finalLineOrigin.x + glyphPosition.x + CGRectGetMinX(glyphBounds),
                                    CGRectGetMinY(drawingRect) + (CGRectGetHeight(drawingRect) - (finalLineOrigin.y + CGRectGetMaxY(lineBounds))),
                                    CGRectGetWidth(glyphBounds),
                                    CGRectGetHeight(lineBounds)
                                    );*/
    // Option 2 - If you want a rect that closely bounds the final character, use this:
    
     CGRect desiredRect = CGRectMake(
     CGRectGetMinX(drawingRect) + finalLineOrigin.x + glyphPosition.x + CGRectGetMinX(glyphBounds),
     CGRectGetMinY(drawingRect) + (CGRectGetHeight(drawingRect) - (finalLineOrigin.y + glyphPosition.y + CGRectGetMaxY(glyphBounds))),
     CGRectGetWidth(glyphBounds),
     CGRectGetHeight(glyphBounds)
     );
     
     
    
    CFRelease(textFrame);
    
    return desiredRect;
}

@end
