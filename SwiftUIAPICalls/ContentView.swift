//
//  ContentView.swift
//  SwiftUIAPICalls
//
//  Created by Daniel Spalek on 29/07/2022.
//

import SwiftUI

class ViewModel: ObservableObject{
    
    @Published var courses: [Course] = []
    
    func fetch() {
        guard let url = URL(string: "https://iosacademy.io/api/v1/courses/index.php") else {
            return
        }
        
        // MARK: Make API call
        // use [weak self] to prevent a memory leak
        let task = URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
            guard let data = data, error == nil else{
                //there was an error or we did not get any data.
                return
            }
            
            // convert to JSON
            do{
                // try to use JSONDecoder
                let courses = try JSONDecoder().decode([Course].self, from: data)
                // it's important that we update this published property on the main queue because it triggers a ui update and ui updates should be on the main queue
                DispatchQueue.main.async{
                    self?.courses = courses
                }
            }catch{
                print(error)
            }
        }
        task.resume()
    }
}

struct Course: Hashable, Codable{
    let name: String
    let image: String
}

struct URLImage: View{
    let urlString: String
    @State var data: Data?
    var body: some View{
        if let data = data, let uiimage = UIImage(data: data){
            Image(uiImage: uiimage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 130, height: 70)
                .background(Color.gray)
        }else{
            // if no data available, show a placeholder
            Image("")
                .resizable()
                .frame(width: 130, height: 70)
                .background(Color.gray)
                .onAppear{
                    fetchData()
                }
        }
    }
    private func fetchData () {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url){ data, _, _ in
            self.data = data
        }
        task.resume()
    }
    
}

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    var body: some View {
        NavigationStack{
            List{
                ForEach(viewModel.courses, id: \.self){ course in
                    HStack{
                        URLImage(urlString: course.image, data: nil)
                        Text(course.name)
                            .bold()
                    }
                }
            }
            .navigationTitle("Courses")
            .toolbar(.visible) //hide or show the toolbar
            .statusBarHidden(false)
            .onAppear{
                viewModel.fetch()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
