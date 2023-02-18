//
//  isContactedView.swift
//  HotProspects
//
//  Created by Magomet Bekov on 07.12.2022.
//
//
import SwiftUI

struct isContactedImage: View {
    
    var isContacted: Bool
    
    var body: some View {
        Image(systemName: isContacted ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.minus")
            .font(.system(size: 29))
            .foregroundColor(isContacted ? .green : .red)
    }
}

//struct isContacted_Previews: PreviewProvider {
//    static var previews: some View {
//        isContacted()
//    }
//}
