//
//  AuthViewModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/11.
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {
        
    private let cancellableBag = Set<AnyCancellable>()
    
    // 初期値はログイン画面
    @Published var segmentType: SegmentType = .loginSegment
    
}
