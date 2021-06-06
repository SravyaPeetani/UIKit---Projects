//
//  CombustibleTypeTableViewCell.swift
//  RentCar
//
//  Created by Jastin on 31/5/21.
//

import UIKit

class MaintenanceTypeTableViewCell: UITableViewCell, BindOutlets {
    
    typealias aType = ModelType
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    
    func bindDataToOulets(vm: ModelType) {
        
        if vm is CombustibleType {
            
            let combustibleType = vm as! CombustibleType
            descriptionLabel.text = combustibleType.description
            stateLabel.text = combustibleType.state.ToString()
            
        } else if vm is VehicleMark {
            
            let vehicleMark = vm as! VehicleMark
            descriptionLabel.text = vehicleMark.description
            stateLabel.text = vehicleMark.state.ToString()
            
        }
    }
}