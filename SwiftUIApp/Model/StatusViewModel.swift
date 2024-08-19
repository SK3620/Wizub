//
//  StatusViewModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/18.
//

import Foundation

class StatusViewModel {
    
    var isLoading: Bool = false
    var showErrorMessage: Bool = false
    var alertErrorMessage: String = ""
    var shouldShowNextScreen = false
    
    init(isLoading: Bool, showErrorMessage: Bool, alertErrorMessage: String, shouldShowNextScreen: Bool) {
        self.isLoading = isLoading
        self.showErrorMessage = showErrorMessage
        self.alertErrorMessage = alertErrorMessage
        self.shouldShowNextScreen = shouldShowNextScreen
    }
}
