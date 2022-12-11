//
//  IntensityCalc.swift
//  RISEapp
//
//  Created by Keelyn McNamara on 11/17/22.
//

import Foundation
import HealthKit



public class IntensityCalc{

//health store database object created
    let healthStore = HKHealthStore()
    
//constant variables
    let Zone1Points = 0.0
    let Zone2Points = 1.0
    let Zone3Points = 3.0
    let Zone4Points = 6.0
    let Zone5Points = 8.0
    
//local variables that must be initialized
    var workoutList: [HKSample]
    let RestingHeartRate: Double
    let Zone1: Double
    let Zone2: Double
    let Zone3: Double
    let Zone4: Double
    let MaxHeartRate: Double
    
    
//local variable up set
    var structList: [workoutObject] = []
    let emptyList: [HKSample] = []

    

    
    var globalHRList: [HKSample] = []
    
    init(workoutList: [HKSample], Resting: Double, Max: Double) {
        self.workoutList = workoutList
        self.RestingHeartRate = Resting
        self.MaxHeartRate = Max
        self.Zone1 = Max * 0.45
        self.Zone2 = Max * 0.59
        self.Zone3 = Max * 0.79
        self.Zone4 = Max * 0.9
        
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
            self.getTodaysHeartRates(start: workout.startDate, end: workout.endDate)
            workoutObject.name = String(describing: workout.workoutActivityType)
            workoutObject.startTime = workout.startDate
            workoutObject.endTime = workout.endDate
            workoutObject.heartRateList = self.globalHRList
            self.structList.append(workoutObject)}
        self.showWorkoutStruc()
        self.calculateZones()
        
    }
    
    func showWorkoutStruc(){
        
        print(self.structList)
    }

    var heartRateQuery:HKSampleQuery?



    /*Method to get todays heart rate - this only reads data from health kit. */
     func getTodaysHeartRates(start: Date, end: Date)
        {
            guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {return }
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options:[])

            //descriptor
            let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

            heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) in
                guard error == nil else{
                    return}
                
                let HRdata = result!
                self.printHeartRateInfo(results: HRdata)


            }//eo-query
            healthStore.execute(heartRateQuery!)

       }//eom

    /*used only for testing, prints heart rate info */
    private func printHeartRateInfo(results:[HKSample])
        {
            for currData in results
            {
                globalHRList.append(currData)
            }//eofl
            print("")
            print("<<<<<<<< Heart Rate Data for Workout Span >>>>>>")
            print("")
            print(globalHRList)
        }//eom

    
    func calculateZones(){
        print("Zone 1 = \(RestingHeartRate) to \(Zone1)")
        print("Zone 2 = \(Zone1) to \(Zone2)")
        print("Zone 3 = \(Zone2) to \(Zone3)")
        print("Zone 4 = \(Zone3) to \(Zone4)")
        print("Zone 5 = \(Zone4) to \(MaxHeartRate)")
    }
    
    
    
    
    
    
    
    
    
    
}






/* let startTime = workout.startDate
 let endTime = workout.endDate
 let seconds = workout.duration
 let minutes = seconds / 60.0
 //print("workout Energy Burned is \(String(describing: workout.totalEnergyBurned))")
// print("workout Duration in minutes is \(minutes)")*/
 
