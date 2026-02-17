//
//  AppConstants.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import UIKit

enum AppConstants {

    enum Gallery {
        static let columnsCount: CGFloat = 3
        static let inset: CGFloat = 12
        static let loadMoreThresholdFromEnd = 6
    }

    enum Repository {
        static let photosPerPage = 30
    }

    enum ImageCache {
        static let countLimit = 100
        static let totalCostLimitBytes = 50 * 1024 * 1024
    }

    enum Layout {
        static let favoriteButtonSize: CGFloat = 44
        static let favoriteButtonMargin: CGFloat = 4
        static let detailVerticalSpacing: CGFloat = 16
        static let detailHorizontalMargin: CGFloat = 16
        static let detailAuthorTopSpacing: CGFloat = 8
    }
}
