import UIKit
import Foundation
import TabularData
import CoreLocation

let formattingOptions = FormattingOptions(
    maximumLineWidth: 250,
    maximumCellWidth: 20,
    maximumRowCount: 5
)
print("Enter your zipcode or state:")
let name = readLine()//00501 is a test input
//input does not work inside playground mode bc xcode is not the exact same as swift


let columns = ["zip", "primary_city", "state", "county", "latitude", "longitude"]
let statsColumns = ["county_name","crime_rate_per_100000","CPOPARST","CPOPCRIM", "MURDER","RAPE","ROBBERY","AGASSLT","BURGLRY","LARCENY","MVTHEFT","ARSON","population"
]

var convert = try DataFrame(contentsOfCSVFile: URL(string: "https://raw.githubusercontent.com/shadowdragon2805/CrimeData/main/docs/csv/zip_code_database.csv")!, columns: columns, types: ["zip": .string, "primary_city": .string, "state": .string, "county": .string, "latitude": .double, "longitude": .double])

var stats = try DataFrame(contentsOfCSVFile: URL(string: "https://raw.githubusercontent.com/shadowdragon2805/CrimeData/main/docs/csv/crime_data_w_population_and_crime_rate.csv")!, columns: statsColumns)
print(stats.shape)

convert.combineColumns("latitude", "longitude", into: "location") { (latitude: Double?, longitude: Double?) -> CLLocation? in guard let latitude = latitude, let longitude = longitude else{
        return nil
    }
    return CLLocation(latitude: latitude, longitude: longitude)
}
let new = convert.filter(on: "zip", String.self){$0 == "00501"}//00501 is test input bc readline does not work in playground
print(type(of: new))
print(new.description(options: formattingOptions))

func closestCities(to location: CLLocation, in convert: DataFrame, limit: Int) -> DataFrame.Slice{
    var closestCities = convert
    closestCities.transformColumn("location") { (meterLocation: CLLocation) in meterLocation.distance(from: location)
        
    }
    closestCities.renameColumn("location", to: "distance")
    return closestCities.sorted(on: "distance", order: .ascending)[..<limit]
}
let state: String = new["state", String.self][0] ?? "There was an error"
let loc: CLLocation = new["location", CLLocation.self][0]!
//format: new[column name, column type][row number] ??=optional
print(state)

let county = new.rows[0][3, String.self]
print(county ?? "There was an error")

let test = closestCities(to: loc, in: convert, limit: 10)
print(test)

let countyStats = stats.filter(on: "county_name", String.self){$0 == (county ?? "error") + ", " + state}
print(countyStats.description(options: formattingOptions))
