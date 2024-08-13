//
//  ErrorMessages.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/12.
//

import Foundation

enum ErrorMessages: String {
    
       case missingUsername = "Username is missing"
       case missingEmail = "Email is missing"
       case invalidEmail = "Email is not valid"
       case emailAlreadyUsed = "Email is already used"
       case missingPassword = "Password is missing"
       case invalidPassword = "8-16 chars with letters and numbers"
       case noError = ""
   }
