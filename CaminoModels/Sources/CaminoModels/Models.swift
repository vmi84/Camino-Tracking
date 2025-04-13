import Foundation
import CoreLocation

// Export Foundation types for public use
@_exported import struct Foundation.Date
@_exported import class CoreLocation.CLLocation

// Note: All types in the Types/ and Managers/ directories are automatically available
// within this module and to importers of this module since they are marked as public