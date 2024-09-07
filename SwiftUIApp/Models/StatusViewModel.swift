//
//  StatusViewModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/18.
//

import Foundation

class StatusViewModel {
    
    var isLoading: Bool
    var shouldTransition: Bool
    var showErrorMessage: Bool
    var alertErrorMessage: String
    
    init(isLoading: Bool = false,
         shouldTransition: Bool = false,
         showErrorMessage: Bool = false,
         alertErrorMessage: String = "") {
        self.isLoading = isLoading
        self.shouldTransition = shouldTransition
        self.showErrorMessage = showErrorMessage
        self.alertErrorMessage = alertErrorMessage
    }
}

class StatusViewModel2: ObservableObject {
    // MARK: - @Published
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    @Published var isShowError: Bool = false
    @Published var httpErrorMsg: String = ""
}
