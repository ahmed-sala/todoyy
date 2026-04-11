#import "TodoTableViewCell.h"

@interface TodoTableViewCell ()

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIImageView *todoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *priorityBadge;
@property (nonatomic, strong) UILabel *statusBadge;
@property (nonatomic, strong) UIStackView *badgeStackView;

@end

@implementation TodoTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}


- (void)setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;

    _cardView = [UIView new];
    _cardView.translatesAutoresizingMaskIntoConstraints = NO;

    _cardView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    _cardView.layer.cornerRadius = 16;
    _cardView.layer.shadowColor = UIColor.blackColor.CGColor;
    _cardView.layer.shadowOpacity = 0.08;
    _cardView.layer.shadowOffset = CGSizeMake(0, 2);
    _cardView.layer.shadowRadius = 8;
    [self.contentView addSubview:_cardView];

    _todoImageView = [[UIImageView alloc] init];
    _todoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _todoImageView.contentMode = UIViewContentModeScaleAspectFit;
    _todoImageView.layer.cornerRadius = 14;
    _todoImageView.clipsToBounds = YES;
    [_cardView addSubview:_todoImageView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    _titleLabel.textColor = [UIColor labelColor];
    [_cardView addSubview:_titleLabel];

    _descriptionLabel = [[UILabel alloc] init];
    _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _descriptionLabel.textColor = [UIColor secondaryLabelColor];
    _descriptionLabel.numberOfLines = 2;
    [_cardView addSubview:_descriptionLabel];

    _dateLabel = [[UILabel alloc] init];
    _dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    _dateLabel.textColor = [UIColor tertiaryLabelColor];
    [_cardView addSubview:_dateLabel];

    _priorityBadge = [self createBadgeLabel];
    _statusBadge = [self createBadgeLabel];

    _badgeStackView = [[UIStackView alloc] initWithArrangedSubviews:@[_priorityBadge, _statusBadge]];
    _badgeStackView.translatesAutoresizingMaskIntoConstraints = NO;
    _badgeStackView.axis = UILayoutConstraintAxisHorizontal;
    _badgeStackView.spacing = 8;
    _badgeStackView.alignment = UIStackViewAlignmentCenter;
    [_cardView addSubview:_badgeStackView];

    [NSLayoutConstraint activateConstraints:@[
        [_cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
        [_cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [_cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [_cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],

        [_todoImageView.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
        [_todoImageView.topAnchor constraintEqualToAnchor:_cardView.topAnchor constant:16],
        [_todoImageView.widthAnchor constraintEqualToConstant:56],
        [_todoImageView.heightAnchor constraintEqualToConstant:56],

        [_titleLabel.topAnchor constraintEqualToAnchor:_todoImageView.topAnchor],
        [_titleLabel.leadingAnchor constraintEqualToAnchor:_todoImageView.trailingAnchor constant:14],
        [_titleLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],

        [_descriptionLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:4],
        [_descriptionLabel.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor],
        [_descriptionLabel.trailingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor],

        [_dateLabel.topAnchor constraintEqualToAnchor:_descriptionLabel.bottomAnchor constant:12],
        [_dateLabel.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
        [_dateLabel.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-16],

        [_badgeStackView.centerYAnchor constraintEqualToAnchor:_dateLabel.centerYAnchor],
        [_badgeStackView.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
        [_badgeStackView.heightAnchor constraintEqualToConstant:24],
        
        [_dateLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_badgeStackView.leadingAnchor constant:-8]
    ]];
}

- (UILabel *)createBadgeLabel {
    UILabel *badge = [[UILabel alloc] init];
    badge.translatesAutoresizingMaskIntoConstraints = NO;
    badge.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    badge.textAlignment = NSTextAlignmentCenter;
    badge.layer.cornerRadius = 6;
    badge.clipsToBounds = YES;
    return badge;
}


- (void)configureWithTodoItem:(TodoItem *)item {
    self.titleLabel.text = item.title;
    self.descriptionLabel.text = item.todoDescription;

    static NSDateFormatter *fmt = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"MMM dd, yyyy • h:mm a";
    });
    self.dateLabel.text = [fmt stringFromDate:item.date];

    [self styleBadge:self.priorityBadge forPriority:item.priority];

    [self styleBadge:self.statusBadge forStatus:item.status];

    [self styleImageViewForPriority:item.priority];

    if (item.status == TodoStatusDone) {
        
        self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:item.title];
    } else {
        self.titleLabel.attributedText = nil;
        self.titleLabel.text = item.title;
    }
}


- (void)styleBadge:(UILabel *)badge forPriority:(NSInteger)priority {
    UIColor *baseColor;
    if (priority == 3) {
        badge.text = @"  HIGH  ";
        baseColor = [UIColor systemRedColor];
    } else if (priority == 2) {
        badge.text = @"  MEDIUM  ";
        baseColor = [UIColor systemOrangeColor];
    } else {
        badge.text = @"  LOW  ";
        baseColor = [UIColor systemGreenColor];
    }
    
    badge.textColor = baseColor;
    badge.backgroundColor = [baseColor colorWithAlphaComponent:0.15];
}

- (void)styleBadge:(UILabel *)badge forStatus:(TodoStatus)status {
    UIColor *baseColor;
    if (status == TodoStatusDone) {
        badge.text = @"  DONE  ";
        baseColor = [UIColor systemGreenColor];
    } else if (status == TodoStatusInProgress) {
        badge.text = @"  IN PROGRESS  ";
        baseColor = [UIColor systemBlueColor];
    } else {
        badge.text = @"  TODO  ";
        baseColor = [UIColor systemGrayColor];
    }
    
    badge.textColor = baseColor;
    badge.backgroundColor = [baseColor colorWithAlphaComponent:0.15];
}

- (void)styleImageViewForPriority:(NSInteger)priority {
    UIColor *baseColor;
    NSString *imageName;
    
    if (priority == 3) {
        imageName = @"high";
        baseColor = [UIColor systemRedColor];
    } else if (priority == 2) {
        imageName = @"medium";
        baseColor = [UIColor systemOrangeColor];
    } else {
        imageName = @"low";
        baseColor = [UIColor systemGreenColor];
    }
    
    self.todoImageView.image = [UIImage imageNamed:imageName];
    self.todoImageView.backgroundColor = [baseColor colorWithAlphaComponent:0.10];
}

@end
