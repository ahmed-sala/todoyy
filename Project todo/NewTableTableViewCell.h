//
//  NewTableTableViewCell.h
//  Project todo
//
//  Created by Ahmed Salah on 08/04/2026.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewTableTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *todoImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *priorityText;
@property (nonatomic, weak) IBOutlet UILabel *statusText;


@end

NS_ASSUME_NONNULL_END
