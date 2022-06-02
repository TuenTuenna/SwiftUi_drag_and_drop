//
//  ContentView.swift
//  drag_and_drop_list_tutorial
//
//  Created by Jeff Jeong on 2021/10/05.
//

import SwiftUI

struct DataItem : Hashable, Identifiable {
    var id : UUID
    var title: String
    var color: Color
    
    init(title: String, color: Color) {
        self.id = UUID()
        self.title = title
        self.color = color
    }
}

struct ContentView: View {
    
    @State var dataList = [
        DataItem(title: "1번", color: .yellow),
        DataItem(title: "2번", color: .green),
        DataItem(title: "3번", color: .orange)
    ]
    
    @State var draggedItem: DataItem?
    
    @State var isEditModeOn: Bool = false
    
    var body: some View {
        Toggle("수정모드:", isOn: $isEditModeOn)
        LazyVStack{
            ForEach(dataList, id:\.self) { dataItem in
                Text(dataItem.title)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(dataItem.color)
                    .onDrag{
                        self.draggedItem = dataItem
                        return NSItemProvider(item: nil, typeIdentifier: dataItem.title)
                    }
                    .onDrop(of: [dataItem.title],
                            delegate: MyDropDelegate(currentItem: dataItem,
                                                     dataList: $dataList,
                                                     draggedItem: $draggedItem,
                                                     isEditModeOn: $isEditModeOn))
            }
        }
        .onChange(of: isEditModeOn, perform: { changedEditMode in
            print("변경된 수정모드: \(changedEditMode)")
        })
        
    }
}

struct MyDropDelegate : DropDelegate {
    
    let currentItem: DataItem
    @Binding var dataList: [DataItem]
    @Binding var draggedItem: DataItem?
    
    @Binding var isEditModeOn: Bool
    
    
    // 드랍에서 벗어났을때
    func dropExited(info: DropInfo) {
        print("MyDropDelegate - dropExited() called")
    }
    
    // 드랍 처리
    func performDrop(info: DropInfo) -> Bool {
        print("MyDropDelegate - performDrop() called")
        return true
    }
    
    // 드랍변경
    func dropUpdated(info: DropInfo) -> DropProposal? {
//        print("MyDropDelegate - dropUpdated() called")
//        return nil
        // 같은 아이템에 드래그 했을때 +표시 없애기
        return DropProposal(operation: .move)
    }
    
    // 드랍 유효 여부
    func validateDrop(info: DropInfo) -> Bool {
        print("MyDropDelegate - validateDrop() called")
        return true
    }
    
    // 드랍 시작
    func dropEntered(info: DropInfo) {
        print("MyDropDelegate - dropEntered() called")
        
        if !isEditModeOn { return }
        
        guard let draggedItem = self.draggedItem else { return }
        
        // 드래깅된 아이템이랑 현재 내 아이템이랑 다르면
        if draggedItem != currentItem {
            let from = dataList.firstIndex(of: draggedItem)!
            let to = dataList.firstIndex(of: currentItem)!
            withAnimation{
                self.dataList.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
        
        
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
