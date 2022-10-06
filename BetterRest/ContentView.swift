//
//  ContentView.swift
//  BetterRest
//
//  Created by Alessandre Livramento on 04/10/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWalkeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    let rangeCoffee = 1...20
    
    static var defaultWalkeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var bestBedTime: String {
        calculateBedtime()
    }

    var body: some View {
        
        NavigationView {
            
            Form {
                Section {
                    DatePicker("Por favor, insira um horário", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                    
                } header: {
                    Text("Quando você quer acordar")
                }
                
                
                Section {
                    Stepper(value: $sleepAmount, in: 4...12) {
                        Text("\(sleepAmount.formatted()) horas")
                    }
                } header: {
                    Text("Quantidade de sono desejada")
                }
                
                
                Section {
                    Stepper(value: $coffeeAmount, in: rangeCoffee) {
                        Text(coffeeAmount == 1 ? "1 xícara" : "\(coffeeAmount) xícaras")
                    }
                } header: {
                    Text("Ingestão diária de café")
                }
                
                
                Section  {
                    Text(bestBedTime)
                        .font(.system(size: 50, weight: .heavy, design: .rounded))
                        .foregroundColor(Color("sleepTime"))
                        .frame(maxWidth: .infinity)
                } header: {
                    Text("Melhor horário para dormir")
                }
            }
            .navigationTitle("Que horas devo dormir")
        }
    }
    
    func calculateBedtime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
           
            return sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
          return "Ocorreu um problema ao calcular sua hora de dormir."
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
