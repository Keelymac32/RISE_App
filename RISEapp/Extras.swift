


/*
 //query pass that will pull latest HeartRate
 let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) -> [HKSample] in
     guard error == nil else{
         return}
     var tempList: [HKSample] = []
     for result: HKSample in result! {
         let HRdata = result as! HKQuantitySample
         let unit = HKUnit(from: "count/min")
         let time = HRdata.startDate
         let latestHR = HRdata.quantity.doubleValue(for: unit)
         tempList.append(HRdata)
     }
 print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
 print("START OF TEMP LIST")
    print(tempList)
     return tempList
 }
 healthStore.execute(query)
 return HRList*/



/*//query pass that will pull latest HeartRate
let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) -> Void in
    guard error == nil else{
        return}
    var tempList: [HKSample] = []
    for result: HKSample in result! {
        let HRdata = result as! HKQuantitySample
        let unit = HKUnit(from: "count/min")
        let time = HRdata.startDate
        let latestHR = HRdata.quantity.doubleValue(for: unit)
        tempList.append(HRdata)
    }
    for elements in tempList{
        HRList.append(elements)
    }
    print(tempList)
}
healthStore.execute(query)

return HRList
}
*/

/*  let startInterval = start
let endInterval = end
var HRList: [HKSample] = []
//var ptr = point
//query for heart rates over interval
guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return []}
let predicate = HKQuery.predicateForSamples(withStart: startInterval, end: endInterval , options: .strictEndDate)
let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
//query pass that will pull latest HeartRate
let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) -> Void in
    guard error == nil else{
        return}
    for result: HKSample in result! {
        let HRdata = result as! HKQuantitySample
        HRList.append(HRdata)
    }
}
self.healthStore.execute(query)
//return HRExport.getHeartrateSeries()
return HRList
}*/



/*
 //
 //  IntensityCalc.swift
 //  RISEapp
 //
 //  Created by Keelyn McNamara on 11/17/22.
 //

 import Foundation
 import HealthKit



 public class IntensityCalc{
     
     let healthStore = HKHealthStore()
     
     var workoutList: [HKSample]
     var structList: [workoutObject] = []
     let emptyList: [HKSample] = []
     
     init(workoutList: [HKSample]) {
         self.workoutList = workoutList
     }
     
     struct workoutObject{
         var name = ""
         var startTime = Date()
         var endTime = Date()
         var duration = 0.0
         var heartRateList: [HKSample] = []
     }
     
     func calculate() {
         for workoutList: HKSample in workoutList {
             let workout: HKWorkout = (workoutList as! HKWorkout)
             var workoutObject = workoutObject()
             //var point = UnsafeMutablePointer<HKSample>.allocate(capacity: 1000)
             //let HRExport = HearRateSeries(tList: emptyList)
             //HRExport.updateList(tList:self.getHeartRateSeries(start: workout.startDate, end:workout.endDate,HRExport: HRExport))
             workoutObject.name = String(describing: workout.workoutActivityType)
             workoutObject.startTime = workout.startDate
             workoutObject.endTime = workout.endDate
             workoutObject.heartRateList = getHeartRateSeries(start: workout.startDate , end: workout.endDate)
             for Hearts in  workoutObject.heartRateList{
                 print(Hearts)
             }
             //workoutObject.heartRateList = HRExport.getHeartrateSeries()
             self.structList.append(workoutObject)}
         //DispatchQueue.main.asyncAfter(deadline: .now() + 10){
         self.showWorkoutStruc()
         //}
     }
     
     func showWorkoutStruc(){
         print(structList)
     }
     
     
     func getHeartRateSeries(start: Date, end: Date){
     }
     
     
     let heartRateUnit:HKUnit = HKUnit(from: "count/min")
     let heartRateType:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
     var heartRateQuery:HKSampleQuery?



     /*Method to get todays heart rate - this only reads data from health kit. */
      func getTodaysHeartRates(start: Date, end: Date)
         {
             let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options:[])

             //descriptor
             let sortDescriptors = [
                                     NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                                   ]

             heartRateQuery = HKSampleQuery(sampleType: heartRateType,
                                             predicate: predicate,
                                             limit: 25,
                                             sortDescriptors: sortDescriptors)
             { (query:HKSampleQuery, results: [HKSample]?, Error: (any Error)?) -> Void in

                 guard Error.self == nil else { print("error"); return }

                     //self.printHeartRateInfo(results)


             }//eo-query
             healthStore.execute(heartRateQuery!)

        }//eom

     /*used only for testing, prints heart rate info */
     private func printHeartRateInfo(results:[HKSample])
         {
             for currData in results
             {
                 print("Heart Rate: \(currData.)")
                 print("quantityType: \(currData.quantityType)")
                 print("Start Date: \(currData.startDate)")
                 print("End Date: \(currData.endDate)")
                 print("Metadata: \(String(describing: currData.metadata))")
                 print("UUID: \(currData.uuid)")
                 print("Source: \(currData.sourceRevision)")
                 print("Device: \(String(describing: currData.device))")
                 print("---------------------------------\n")
             }//eofl
         }//eom

     
     
     
     
     
     
     
     
     
     
     
     
     
 }






 /* let startTime = workout.startDate
  let endTime = workout.endDate
  let seconds = workout.duration
  let minutes = seconds / 60.0
  //print("workout Energy Burned is \(String(describing: workout.totalEnergyBurned))")
 // print("workout Duration in minutes is \(minutes)")*/
  

 */
