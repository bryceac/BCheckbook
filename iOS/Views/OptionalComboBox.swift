//
//  OptionalComboBox.swift
//  BCheckbook (iOS)
//
//  Created by Bryce Campbell on 12/20/21.
//

import SwiftUI
import ComboBox

struct OptionalComboBox: View {
    @Binding var selection: String?
    @Binding var choices: [String]
    
    var selectionBinding: Binding<String> {
        Binding(get: {
            guard let selection = selection else {
                return ""
            }
            
            return selection
        }, set: { newValue in
            selection = newValue
        })
    }
    
    var body: some View {
        if let _ = selection {
            ComboBox(choices: $choices, value: selectionBinding)
        }
    }
}

struct OptionalComboBox_Previews: PreviewProvider {
    static var previews: some View {
        OptionalComboBox(selection: .constant(nil), choices: .constant(["Hello", "World", "7"]))
    }
}
