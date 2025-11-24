//
//  LoadingIndicatorStyle.swift
//
//
//  Created by TAE SU LEE on 2024/11/24.
//

import UIKit

/// Defines the style of loading indicator to display while loading ads.
public enum LoadingIndicatorStyle {
    /// No loading indicator is shown.
    case none

    /// Default system activity indicator (UIActivityIndicatorView with medium style).
    case `default`

    /// System activity indicator with custom color.
    case color(UIColor)

    /// Custom view provided by a closure. The closure is called each time an indicator is needed.
    case custom(() -> UIView)
}
