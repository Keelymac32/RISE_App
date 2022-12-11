
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
    var MaxHeartRateGlobal = 0.0
    var RestingHeartRateGlobal = 0.0
    var workoutlist: [HKWorkout] = []
    
    // Main driver method that set sup screen and calls other methods
    override func viewDidLoad(){
        super.viewDidLoad()
        calcMaxHeartRate()
        checkHealthDataAvailable() // Checking to see Heath Data Available
        calcRestingHeartRate()
        calcHeartRate() // Updating global Heart Rate
        updateScreen()             // Method call to update with health information
        
    }
    //updating screen with label of health data
    func updateScreen(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 8){
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
            label.center = CGPoint(x: 230, y: 240)
            label.textAlignment = .center
            label.text = (self.HeartRateGlobal.description)
            
            
            
            let label2 = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
            label2.center = CGPoint(x: 230, y: 210)
            label2.textAlignment = .center
            label2.text = (self.MaxHeartRateGlobal.description)
            
            let label3 = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
            label3.center = CGPoint(x: 230, y: 172)
            label3.textAlignment = .center
            label3.text = (self.RestingHeartRateGlobal.description)
            
            self.view.addSubview(label)
            self.view.addSubview(label2)
            self.view.addSubview(label3)
            self.getWorkouts()
        }
    
    }
    func getSleepQuality(){
        let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Alert") as! AlertViewController
        self.addChild(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParent: self)
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
    
    func calcMaxHeartRate()  {
        print("Getting Max Heart Rate.....")
        //variables for query pass
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {return }
        let startDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        //query pass that will pull latest HeartRate
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) in
            guard error == nil else{
                return}
            //formatting query results
            var tempMAX = 0.0
            for HR in result!{
                let HRQuantitySample = HR as! HKQuantitySample
                let unit = HKUnit(from: "count/min")
                let doubleHR = HRQuantitySample.quantity.doubleValue(for: unit)
                if (doubleHR > tempMAX){
                    tempMAX = doubleHR
                    self.getMAXHeartRate(HeartRate: tempMAX)
                }
            }
            print("Max Heart Rate: \(tempMAX)")
            
        }
        healthStore.execute(query)
    }
    
    
    func calcRestingHeartRate(){
        print("Getting Resting Heart Rate....")
        //Resting Heart Rate Query
        guard let sampleResting = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else { return}
        let startDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())
        let predicateResting = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let queryResting = HKSampleQuery(sampleType:sampleResting, predicate: predicateResting, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sampleResting, resultResting, error) in
            guard error == nil else{
                return}
            var tempREST = 100.0
            for HR in resultResting!{
                let HRQuantitySample = HR as! HKQuantitySample
                let unit = HKUnit(from: "count/min")
                let doubleHR = HRQuantitySample.quantity.doubleValue(for: unit)
                if (doubleHR < tempREST){
                    tempREST = doubleHR
                    self.RestingHeartRateGlobal = tempREST
                }
            }
            print("Resting Heart Rate \(tempREST) BPM")
        }
        healthStore.execute(queryResting)
    }
    
    func getWorkouts(){
        print("Getting Workout data....")
        //variables for query pass
        let workoutType = HKObjectType.workoutType()
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        //query pass that will pull last month of workouts
        
        let workoutQuery = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) in
            guard error == nil else{
                return}
            //Passes list of workouts in last 24 hours to class that will calculate Workout Intensity
            let WICalc = IntensityCalc(workoutList: result!, Resting: self.RestingHeartRateGlobal, Max: self.MaxHeartRateGlobal)
            WICalc.calculate()
        }
        healthStore.execute(workoutQuery)
    }
    
    //updates Global Variable for HR with Current Heart Rate
        func getHeartRate(HeartRate: Double){
            HeartRateGlobal = HeartRate
        }
        func getMAXHeartRate(HeartRate: Double){
            MaxHeartRateGlobal = HeartRate
        }
        func getRestingHeartRate(HeartRate: Double){
        RestingHeartRateGlobal = HeartRate
        }
    
    
}

