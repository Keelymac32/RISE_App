
//
//  RecoveryViewController.swift
//  A class that controls the first recovery screen as well as does health data calculations
//
//  Created by Keelyn McNamara on 10/6/22.
//
import UIKit
import HealthKit
import SwiftUI
import Foundation

class RecoveryViewController: UIViewController {
    
    let healthStore = HKHealthStore()
   
    var HeartRateGlobal = 0.0

    // Main driver method that set sup screen and calls other methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        checkHealthDataAvailable() // Checking to see Heath Data Available
        calcHeartRate()            // Updating global Heart Rate
        updateScreen()             // Method call to update with health information
        
    }
    //updating screen with label of health data
    func updateScreen(){
        getWorkouts()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            label.center = CGPoint(x: 160, y: 285)
            label.textAlignment = .center
            label.text = ("Heart Rate: \(self.HeartRateGlobal)")
            self.view.addSubview(label)}
    }

    //Checking to see if health data is available on the device (ex. yes to iPhone and no to iPad)
    func checkHealthDataAvailable() {
        print("Checking if Health Data is Available....")
       
        if HKHealthStore.isHealthDataAvailable() {
            print("YES HEALTH DATA IS AVAILABLE")
            self.authorizeHealthKit()} //Requesting to authorize specific types of data being used
        
        else {print("NO HEALTH DATA NOT AVAILABLE")
            //Pop up message to notify user their app isn't supported
            let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Alert") as! AlertViewController
            self.addChild(popUpVC)
            popUpVC.view.frame = self.view.frame
            self.view.addSubview(popUpVC.view)
            popUpVC.didMove(toParent: self)}
            }
    
    
    //function that authorizes use of workouts and heart rate data
    func authorizeHealthKit(){
    print("Authorizing Health Kit.....")
        let read = Set(
            [HKObjectType.quantityType(forIdentifier: .heartRate)!,
             HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
             HKSeriesType.activitySummaryType(),
             HKSeriesType.workoutType()
            ])
        let share: Set<HKSampleType> =
        [HKObjectType.quantityType(forIdentifier: .heartRate)!,
         HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
         HKSeriesType.workoutType()]
        
        self.healthStore.requestAuthorization(toShare: share, read: read) { (success, error) in
            if !success {
                print("ERROR With Authorizing Health Kit")
                return
            }
            else{
                print("Health Kit is Authorized.")}
            }
    }
    
    
//Getting Resting Heartrate from Healthkit using Query
    func calcHeartRate()  {
        print("Getting Heart Rate.....")
    
    //variables for query pass
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {return }
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    
    //query pass that will pull latest HeartRate
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) in
            guard error == nil else{
                return}
    //formatting query results
            let HRdata = result?[0] as! HKQuantitySample
            let unit = HKUnit(from: "count/min")
            let latestHR = HRdata.quantity.doubleValue(for: unit)
            self.getHeartRate(HeartRate: latestHR)
            print("Latest Heart Rate \(latestHR) BPM")}
        healthStore.execute(query)
    }
    
//updates Global Variable for HR with Current Heart Rate
    func getHeartRate(HeartRate: Double){
        HeartRateGlobal = HeartRate
    }
    
    
    
    func getRestingHeartRate(){
        print("Getting Resting Heart Rate....")
        //Resting Heart Rate Query
        guard let sampleResting = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else { return}
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        let predicateResting = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let queryResting = HKSampleQuery(sampleType:sampleResting, predicate: predicateResting, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sampleResting, resultResting, error) in
            guard error == nil else{
                return}
            let RestingData = resultResting?[0] as! HKQuantitySample
            let unit = HKUnit(from: "count/min")
            let latestResting = RestingData.quantity.doubleValue(for: unit)
            print("Latest Resting Heart Rate \(latestResting) BPM")
        }
        healthStore.execute(queryResting)
    }
    
        func getWorkouts() {
        
        print("Getting Workout data....")
        //variables for query pass
        let workoutType = HKObjectType.workoutType()
        let startDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        //query pass that will pull last month of workouts
        let workoutQuery = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) in
            guard error == nil else{
                return}
            
            //loop that goes through list of workouts and prints duration, energy burned and start date
            for result: HKSample in result! {
                let workout: HKWorkout = (result as! HKWorkout)
                let startTime = workout.startDate
                let endTime = workout.endDate
                let seconds = workout.duration
                let minutes = seconds / 60.0
                print("workout Energy Burned is \(String(describing: workout.totalEnergyBurned))")
                print("workout Duration in minutes is \(minutes)")
                self.getHeartRateSeries(start: startTime,end: endTime)
                print("XXXXXXXXXXXXXXXXXXXXX")
                print("")
                // guard let heartrateData = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return}
                //print("Statistics for Workout \(String(describing: workout.statistics(for:heartrateData)))")
                
            }
        }
        healthStore.execute(workoutQuery)
    }
    
    
    func getHeartRateSeries(start: Date, end: Date){
        let startInterval = start
        let endInterval = end
        print("workout Start Date is \(startInterval)")
        print("workout End Date is \(endInterval)")
        
    //query for heart rates over interval
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: startInterval, end: endInterval , options: .strictEndDate)
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        //query pass that will pull latest HeartRate
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) in
            guard error == nil else{
                return}
            for result: HKSample in result! {
                let HRdata = result as! HKQuantitySample
                let unit = HKUnit(from: "count/min")
                let time = HRdata.startDate
                let latestHR = HRdata.quantity.doubleValue(for: unit)
                print( "Heart Rate \(latestHR) BPM and the time was \(time)")
                
            }
            
        }
        healthStore.execute(query)
    }

}
