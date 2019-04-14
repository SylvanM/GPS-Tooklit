//
//  Marker.swift
//  GPS Tooklit
//
//  Created by Sylvan Martin on 4/13/19.
//  Copyright © 2019 Sylvan Martin. All rights reserved.
//

import UIKit
import MapKit
import os.log

/// A point on the map
class Marker: NSObject, MKAnnotation, NSSecureCoding {
    
    /// Whether or not the object supports secure encoding
    static var supportsSecureCoding: Bool {
        return true
    }
    
    // MARK: Properties
    
    /// The title of the marker
    var title: String?
    
    /// The subtitle of the marker
    var subtitle: String?
    
    /// Latitude of the marker
    var latitude: CLLocationDegrees
    
    /// Longitude of the marker
    var longitide: CLLocationDegrees
    
    /// Coordinate of marker
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitide)
    }
    
    // MARK: Structures
    
    private struct PropertyKey {
        static let title     = "title"
        static let subtitle  = "subtitle"
        static let latitude  = "latitude"
        static let longitude = "longitude"
    }
    
    // MARK: Initializers
    
    init(title: String, subtitle: String? = nil, at coordinate: CLLocationCoordinate2D) {
        self.title     = title
        self.subtitle  = subtitle
        self.latitude  = coordinate.latitude
        self.longitide = coordinate.longitude
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String else {
            os_log("Unable to decode the name for a Marker object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let subtitle = aDecoder.decodeObject(forKey: PropertyKey.subtitle) as? String
        
        let latitude = aDecoder.decodeDouble(forKey: PropertyKey.latitude) as CLLocationDegrees
        
        let longitude = aDecoder.decodeDouble(forKey: PropertyKey.longitude) as CLLocationDegrees
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Must call designated initializer.
        self.init(title: title, subtitle: subtitle, at: coordinate)
    }
    
    // MARK: Coding
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("Markers")
    
    @objc func encode(with aCoder: NSCoder) {
        aCoder.encode(title,     forKey: PropertyKey.title)
        aCoder.encode(subtitle,  forKey: PropertyKey.subtitle)
        aCoder.encode(latitude,  forKey: PropertyKey.latitude)
        aCoder.encode(longitide, forKey: PropertyKey.longitude)
    }
    
}
