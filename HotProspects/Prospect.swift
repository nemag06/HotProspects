//
//  Prospect.swift
//  HotProspects
//
//  Created by Magomet Bekov on 07.12.2022.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = ""
    var emailAddress = ""
    fileprivate(set) var isContacted = false
    var dateAdded = Date()
    
}

@MainActor class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    let saveKey = "SavedData"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                people = decoded
                return
            }
        }
        
        let fileName = Self.getDocumentsDirectory().appendingPathComponent(self.saveKey)
      
        do {
            let data = try Data(contentsOf: fileName)
            let people = try JSONDecoder().decode([Prospect].self, from: data)
            self.people = people
        } catch {
            print("Unable loading data")
            self.people = []
        }
        people = []
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        saveToFile()
    }
    
    private func saveToFile() {
        let fileName = Self.getDocumentsDirectory().appendingPathComponent(self.saveKey)
        do {
            let data = try JSONEncoder().encode(people)
            try data.write(to: fileName, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable saving")
        }
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        saveToFile()
    }
}
