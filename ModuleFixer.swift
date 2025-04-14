import Foundation

#if canImport(SwiftyJSON)
print("✅ SwiftyJSON can be imported")
#else
print("❌ SwiftyJSON cannot be imported")
#endif

#if canImport(CaminoModels)
print("✅ CaminoModels can be imported")
#else
print("❌ CaminoModels cannot be imported")
#endif 