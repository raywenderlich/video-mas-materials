/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import CoreData
import SwiftUI

struct TaskRowsView: DynamicViewContent {
  
  var data: [Task]
  var onSave: ((String, Double) -> Void)?
  @Environment(\.managedObjectContext) var managedObjectContext
  
  var body: some View {
    ForEach(Array(data.enumerated()), id: \.offset) { index, task in
      NavigationLink(
        destination: CountdownTimerView(
          task: task,
          timer: TimerWrapper(totalTime: task.duration,
                              timeInterval: 1,
                              direction: .down)
        )
      ) {
        Text(task.title)
      }
    }
    .onDelete { indexSet in
      indexSet.forEach { index in
        let fetchRequest = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(TaskEntity.id), data[index].id as CVarArg])
        guard let taskToDelete = try? managedObjectContext.fetch(fetchRequest).first                   else {
          return
        }
        managedObjectContext.delete(taskToDelete)
        try? managedObjectContext.save()
      }
    }
  }
}

struct TaskRowsView_Previews: PreviewProvider {
  static var previews: some View {
    TaskRowsView(data: [
      Task(id: UUID(),
           title: "Task 1",
           timestamp: Date(),
           isFavorite: false
          )
    ])
      .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}