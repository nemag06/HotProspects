//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Magomet Bekov on 07.12.2022.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    @EnvironmentObject var prospects: Prospects
    
    @State private var isShowingScanner = false
    @State private var isShowingSheet = false
    
    let filter: FilterType
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortsProspects) { prospect in
                    HStack {
                        isContactedImage(isContacted: prospect.isContacted)
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                    }
                    .swipeActions {
                        if prospect.isContacted {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Uncontacted", systemImage: "person.crop.xmark")
                            }
                            .tint(.blue)
                        } else {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)
                            
                            Button {
                                addNotification(for: prospect)
                            } label: {
                                Label("Remind Me", systemImage: "bell")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
                .navigationTitle(title)
                .navigationBarItems(leading: Button(action: {
                    self.isShowingSheet = true
                }, label: {
                    Text("Sorting")
                })
                .toolbar {
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], simulatedData: "magafif57@gmail.com", completion: handleScan )
                }
                .actionSheet(isPresented: $isShowingSheet) { () -> ActionSheet in
                    ActionSheet(title: Text("Sort by: "), message: nil, buttons: [.default(Text("Name\(checkBox(forType: .name))"), action: {
                        self.sortType = .name
                    }), .default(Text("Date Added\(checkBox(forType: .dateAdded))"), action: { self.sortType = .dateAdded
                        
                    }), .cancel()])
                }
        )}
    }
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    
    enum SortedType {
        case name, dateAdded
    }
    
    @State private var sortType = SortedType.name
    
    var sortsProspects: [Prospect] {
        switch sortType {
        case .name:
            return filteredProspects.sorted { (firstProspect, secondProspect ) -> Bool in
                return firstProspect.name < secondProspect.name
            }
        case .dateAdded:
            return filteredProspects.sorted { (firstProspect, secondProspect) -> Bool in
                return firstProspect.dateAdded < secondProspect.dateAdded
            }
        }
    }
    
    enum CheckBoxType {
        case name, dateAdded
    }
    
    func checkBox(forType: CheckBoxType) -> String {
        switch forType {
        case .name:
            return sortType == .name ? "✔️" : ""
        case .dateAdded:
            return sortType == .dateAdded ? "✔️" : ""
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            let person = Prospect()
            
            person.name = details[0]
            person.emailAddress = details[1]
            person.dateAdded = Date()
            prospects.add(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh!")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
