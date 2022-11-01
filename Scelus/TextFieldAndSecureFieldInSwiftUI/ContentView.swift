//Statistics from: Johnson, Mike. “United States Crime Rates by County.” Kaggle, 2016, https://www.kaggle.com/datasets/mikejohnsonjr/united-states-crime-rates-by-county. Accessed 1 Nov. 2022. 
import SwiftUI
import CoreLocation
import MapKit
import TabularData
class GlobalModel: ObservableObject {
    @Published var stringStats = ""
    @Published var latitude = 0.0
    @Published var longitude = 0.0
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    @Published var userInput = ""
    @Published var globalSaved = []
    
}

struct ContentView: View {
    @StateObject private var statNavManager = StatsNavigationManager()
    @StateObject private var vm = ViewModel()
    @State private var saved: [String] = ViewModel().savedArray

    var body: some View {
        TabView {
                    
            StatsView(saved: $saved)
            .tabItem {
                Label("Home", systemImage: "house")
            }

            FavView(saved: $saved)
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
            }
        }
        .environmentObject(statNavManager)
    }
}

/*struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}*/

private extension StatsView {
    
    var inputTxtVw: some View {
        TextField("Zip Code",
                  text: $input.zip,
                  prompt: Text("Zip Code"))
            .focused($inputFocused)
            .keyboardType(.decimalPad)
            .frame(width: UIScreen.main.bounds.size.width -
                80, height: 41, alignment: .center)
            .textFieldStyle(.plain)
            .background(Color.init(red: 211.0/255.0, green:
                211.0/255.0, blue: 211.0/255.0))
            .textContentType(.emailAddress)
            .cornerRadius(10)
            .multilineTextAlignment(.center)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .foregroundColor(.blue)
    }
    

    
    var submitBtn: some View {
        Button(action: submit) {
            HStack {
                Image(systemName: "chart.pie")
                    .font(.title)
                    .foregroundColor(.white)
                Text("Stats")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            
        }
        .frame(width: UIScreen.main.bounds.size.width - 80, height: 50, alignment: .center)
        .background(Color.blue)
        .cornerRadius(20, antialiased: true)
        .background(
            
        
            NavigationLink(destination: CityView(string: globalModel.stringStats, display: false, input: globalModel.userInput, saved: $saved),
                           tag: .statsPage,
                           selection: $statNavManager.screen) { EmptyView() }
        )
    }
    var locBtn: some View {
        Button(action: loc) {
            HStack {
                Image(systemName: "pin")
                    .font(.title)
                    .foregroundColor(.white)
                Text("Map")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .frame(width: UIScreen.main.bounds.size.width - 80, height: 50, alignment: .center)
            .background(Color.blue)
            .cornerRadius(20, antialiased: true)
        }
        
        .background(
            
        
            NavigationLink(destination: TestView(latitude: globalModel.latitude, longitude: globalModel.longitude, mapHolder: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: globalModel.latitude, longitude: globalModel.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))),
                           tag: .mapsPage,
                           selection: $statNavManager.screen) { EmptyView() }
        )
    }
}

private extension StatsView {
    
    func submit() {//what happens when you submit
        print("The city/county/zip inputted: \(input)")
        print("help:", input.zip)
        //.onAppear {
        let temp = test.getStats(input: input.zip)
        let county: String = (temp["county_name", String.self].first ?? "There was an error") ?? "There was an error"
        let crimeRate: Double = (temp["crime_rate_per_100000", Double.self].first ?? 0) ?? 0

        let MURDER: Int = (temp["MURDER", Int.self].first ?? 0) ?? 0
        let RAPE: Int = (temp["RAPE", Int.self].first ?? 0) ?? 0
        let ROBBERY: Int = (temp["ROBBERY", Int.self].first ?? 0) ?? 0
        let AGASSLT: Int = (temp["AGASSLT", Int.self].first ?? 0) ?? 0
        let BURGLRY: Int = (temp["BURGLRY", Int.self].first ?? 0) ?? 0
        let LARCENY: Int = (temp["LARCENY", Int.self].first ?? 0) ?? 0
        let THEFT: Int = (temp["MVTHEFT", Int.self].first ?? 0) ?? 0
        let ARSON: Int = (temp["ARSON", Int.self].first ?? 0) ?? 0
        let population: Int = (temp["population", Int.self].first ?? 0) ?? 0
        let combinedTheft = THEFT + LARCENY
 
        globalModel.stringStats = """
        County: \(county)
        Population: \(population)
        Crime Rate Per 100,000 people: \(crimeRate)
        Murder: \(MURDER)
        Rape: \(THEFT)
        Theft/Larceny: \(combinedTheft)
        Aggravated Assault: \(AGASSLT)
        Robbery(violent theft): \(ROBBERY)
        Burglary(breaking in theft): \(BURGLRY)
        Arson: \(ARSON)
        """
        
        globalModel.userInput = input.zip
        print(temp)
        print(globalModel.stringStats)
        statNavManager.push(to: .statsPage)
        resignKeyboard()
        
    }
    func loc() {//what happens when you submit
        let temp = test.getLocation(input: input.zip)
        globalModel.latitude = temp.coordinate.latitude
        globalModel.longitude = temp.coordinate.longitude
        print("Hi", temp)
        print("lat",globalModel.latitude)
        //let closest = test.callClosest()
        //print(closest)//print closets cities
        //globalModel.dataframe = closest

        statNavManager.push(to: .mapsPage)
        resignKeyboard()
        
    }
    
    func resignKeyboard() {
        if #available(iOS 15, *) {
            inputFocused = false
        } else {
            dismissKeyboard()
        }
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
class NumbersOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}
enum Screens {
    case statsPage
    case mapsPage
}

extension Screens: Hashable {}

final class StatsNavigationManager: ObservableObject {
    
    @Published var screen: Screens? {
        didSet {
            print("📱 \(String(describing: screen))")
        }
    }
    
    func push(to screen: Screens) {
        self.screen = screen
    }
    
    func popToRoot() {
        self.screen = nil
    }
}

extension UIColor {
    static let systemBlue = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    // etc
}

struct AnimatedBackground: View {
    @State var startp = UnitPoint(x: 0, y: -4)
    @State var endp = UnitPoint(x: 4, y: 0)
    
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    let colorslist = [Color.blue, Color.red, Color.purple, Color.orange]
    
    var body: some View {
        
        LinearGradient(gradient: Gradient(colors: colorslist), startPoint: startp, endPoint: endp)
            .animation(Animation.easeInOut(duration: 12).repeatForever())
            .onReceive(timer, perform: { _ in
                
                self.startp = UnitPoint(x: 4, y: 0)
                self.endp = UnitPoint(x: 0, y: 4)
            })
    }
}
struct StatsView: View {
    @Binding var saved: [String]
    let test = cityClass()
    @StateObject var globalModel = GlobalModel()
 
    //@ObservedObject var input = NumbersOnly()
    struct Input{
        var zip: String = ""
    }
    
    @State var input: Input = .init()
    @FocusState private var inputFocused: Bool
    
 
    @EnvironmentObject var statNavManager: StatsNavigationManager
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient (gradient: Gradient (colors: [.white, .blue, ]),
                startPoint: .bottom, endPoint: .top)
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image("scelus")
                    .frame(width: UIScreen.main.bounds.size.width - 40, height: 225, alignment: .top)
                    ZStack(alignment: .top) {
                        Color.white
                        VStack(alignment: .leading) {
                            //Color.blue
                            inputTxtVw
                            submitBtn
                            locBtn
                        }
                    }
                    .frame(width: UIScreen.main.bounds.size.width - 40, height: 205, alignment: .center)
                    .cornerRadius(20)
                }
                .padding()
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
 
   
                    }
                }
                .onSubmit(of: .text, submit)
                
               
 
            }
        }
    }
}
struct CityView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    @EnvironmentObject var statNavManager: StatsNavigationManager
    @StateObject private var vm = ViewModel()
    var string: String
    var display: Bool
    var input: String
    @Binding var saved: [String]
    var body: some View {
        var x = print(ViewModel().db.returnItem(input: input))
        GeometryReader { geometry in
            ZStack {

                Ellipse()
                    .foregroundColor(Color.blue)
                    .frame(width: geometry.size.width * 1.4, height: geometry.size.height * 0.33)
                    .position(x: geometry.size.width / 2.35, y: geometry.size.height * 0.1)
                    .shadow(radius: 3)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack(spacing: 15){
                        Text("\(vm.db.returnItem(input: input).title) Statistics Estimate")
                            .font(.custom("AmericanTypewriter", size: 20, relativeTo: .body))
                            .fontWeight(.bold)
                            .padding(10)
                            .background(Color(.sRGB, red: 0, green: 0, blue: 255, opacity: 1.0))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            //.position(x: UIScreen.main.bounds.size.width, y: UIScreen.main.bounds.size.height/7)
                        Image(systemName: vm.contains(vm.db.returnItem(input: input)) ? "bookmark.fill" : "bookmark")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                vm.toggleFav(item: vm.db.returnItem(input: input))
                                saved = vm.savedArray
                                var hi = print("this is saved", saved)
                            }
                        
                        
                        
                        
                        
                    }
                    Text(string)
                        .font(.custom(
                            "AmericanTypewriter", size: 18).weight(.semibold))
                        .lineSpacing(20)
                        .padding(EdgeInsets(top: 10, leading: 5, bottom: 5, trailing: 5))

                    Button(action: {
                        if #available(iOS 15, *) {
                            dismiss()
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                        }, label: {
                            Text("Go Back")
                                .padding()
                                .foregroundColor(.white)
                        })
                    .background(Color.blue)
                    .cornerRadius(20, antialiased: true)
                    .frame(width: UIScreen.main.bounds.size.width - 160, height: 50, alignment: .center)
                    
                }
                
            }
        }//zstack end
    }
    
}


struct TestView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    @EnvironmentObject var statNavManager: StatsNavigationManager
    //@EnvironmentObject var global: GlobalModel
    var latitude: Double
    var longitude: Double

    @State var mapHolder: MKCoordinateRegion

 
    var body: some View {


        Map(coordinateRegion: $mapHolder)
            .edgesIgnoringSafeArea(.all)
        //var x = print($mapHolder.center) // 1
        ZStack {
            VStack {

                /*
                Button("Go back") {
                    if #available(iOS 15, *) {
                        dismiss()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }*/
            }
        }
    }

}
final class ViewModel: ObservableObject {
        @Published var items = [Item]()
        @Published var showingFavs = true
        @Published var savedItems: Set<String> = []
        @Published var savedArray: [String]
        // Filter saved items
        var filteredItems: [String]  {
            //return self.items
            return savedArray
        }

        var db = Database()
        
        init() {
            self.savedItems = db.load()
            self.items = db.returnList()//the items
            self.savedArray = Array(db.load())
            
            print("savedarray", savedArray)
            print("important!", self.savedItems, self.items)
        }
        
        func contains(_ item: Item) -> Bool {
                savedArray.contains(item.id)
            }
        
        // Toggle saved items
        func toggleFav(item: Item) {
            print("Toggled!", item)
            if contains(item) {
                savedItems.remove(item.id)
                if let index = savedArray.firstIndex(of: item.id) {
                    savedArray.remove(at: index)
                }
            } else {
                savedItems.insert(item.id)
                savedArray.append(item.id)
            }
            db.save(items: Set(savedArray))
        }
    }

struct FavView: View {
    @StateObject private var vm = ViewModel()
    //@State private var saved = ViewModel().savedArray
    @Binding var saved: [String]
  
    var body: some View {
        ZStack{
            //AnimatedBackground().edgesIgnoringSafeArea(.all)
                                        //.blur(radius: 100)
            LinearGradient (gradient: Gradient (colors: [.white, .blue, ]),
            startPoint: .bottom, endPoint: .top)
            .edgesIgnoringSafeArea(.all)
            VStack {
                
                List {
                    var x = print("HELP me so much",vm.savedArray)
                    
                    var y = print("HELP fsadkf so much",saved)
                    
                    ForEach(saved, id: \.self) { string in
                        let item = vm.db.returnItem(input: string)
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.headline)
                                
                                Text(item.description)
                                    .font(.subheadline)
                            }
                            Spacer()
                            Image(systemName: vm.contains(item) ? "bookmark.fill" : "bookmark.fill")
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    vm.toggleFav(item: item)
                                    saved = vm.savedArray
                                    var y = ("wtfff", saved)
                                }
                        }
                    }
                }
                .cornerRadius(10)
            }
        }
        
    }
}
