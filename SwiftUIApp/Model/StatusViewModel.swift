//
//  StatusViewModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/18.
//

import Foundation

class StatusViewModel {
    
    var isLoading: Bool = false
    var shouldTransition = false
    var showErrorMessage: Bool = false
    var alertErrorMessage: String = ""
    
    init(isLoading: Bool, shouldTransition: Bool, showErrorMessage: Bool, alertErrorMessage: String) {
        self.isLoading = isLoading
        self.shouldTransition = shouldTransition
        self.showErrorMessage = showErrorMessage
        self.alertErrorMessage = alertErrorMessage
    }
}
