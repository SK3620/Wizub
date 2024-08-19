//
//  CustomSearchBar.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/19.
//

import SwiftUI
import UIKit

struct SearchBarUIView: UIViewRepresentable {
    @Binding var text: String
    let placeHolder: String?
    init(text: Binding<String>, placeHolder: String? = nil) {
        self._text = text
        self.placeHolder = placeHolder
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.backgroundColor = .gray.withAlphaComponent(0.2)

        searchBar.delegate = context.coordinator
        if let placeHolder = self.placeHolder {
            searchBar.placeholder = placeHolder
        }
        return searchBar
    }
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        
    }
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        public init(text: Binding<String>) {
            self._text = text
        }
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.text = searchText
        }
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
        }
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = true
        }
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
            searchBar.searchTextField.endEditing(true)
            self.text = ""
            searchBar.searchTextField.text = ""
        }
    }
}

struct SearchBarView: View {
    @Binding var text: String
    public let placeHodler: String?
    var body: some View {
        SearchBarUIView(text: $text, placeHolder: placeHodler)
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(text: .constant(""), placeHodler: nil)
    }
}

