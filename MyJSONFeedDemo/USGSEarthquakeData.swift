//
//  USGSEarthquakeData.swift
//  MyJSONFeedDemo
//
//  Created by Brian Arnold on 6/18/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// This corresponds to a subset of the USGS GeoJSON format described here:
///
/// <https://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php>
///
/// Example of nested Codable structs with single value keys and native types (Int, String, Double)
struct USGSEarthquakeData: Codable {
    
    struct Feature: Codable {
        let id: String
        
        struct Properties: Codable {
            let title: String
            let mag: Double
            let place: String
            let time: Int
            let updated: Int
            let magType: String
            
            // Example of Codable enum with raw value of Int
            enum Tsunami: Int, Codable {
                case none
                case possible
            }
            let tsunami: Tsunami
            
            let detail: String
            
            // Example of Codable enum with raw value of String
            enum Alert: String, Codable {
                case green
                case yellow
                case orange
                case red
            }
            // Example of optional property
            let alert: Alert?
            
            enum Status: String, Codable {
                case automatic
                case reviewed
                case deleted
            }
            let status: Status
        }
        
        let properties: Properties
        
        struct Geometry: Codable {
            let coordinates: [Double]
            
            var longitude: Double { return coordinates[0] }
            var latitude: Double { return coordinates[1] }
            var depth: Double { return coordinates[2] }
        }
        
        let geometry: Geometry
    }
    
    // Example of an Array of a Codable struct
    let features:  [Feature]
    
    let bbox: [Double]
    
    var minimumLongitude: Double { return bbox[0] }
    var minimumLatitude: Double { return bbox[1] }
    var minimumDepth: Double { return bbox[2] }
    var maximumLongitude: Double { return bbox[3] }
    var maximumLatitude: Double { return bbox[4] }
    var maximumDepth: Double { return bbox[5] }
    
}

extension USGSEarthquakeData {
    
    static func fetch(_ completionBlock: @escaping ((USGSEarthquakeData?, Error?)->())) {
        let earthquakesURL = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_month.geojson"
        let url = URL(string: earthquakesURL)!
        DispatchQueue.global().async {
            do {
                let allData = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let geoJSON = try decoder.decode(USGSEarthquakeData.self, from: allData)
                DispatchQueue.main.async {
                    completionBlock(geoJSON, nil)
                }
            }
            catch let error {
                print("Error fetching data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completionBlock(nil, error)
                }
            }
        }
        
    }
}
