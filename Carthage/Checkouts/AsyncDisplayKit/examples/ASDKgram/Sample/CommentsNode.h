//
//  CommentsNode.h
//  ASDKgram
//
//  Created by Hannah Troisi on 3/21/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "CommentFeedModel.h"

@interface CommentsNode : ASTextCellNode

- (void)updateWithCommentFeedModel:(CommentFeedModel *)feed;

@end
