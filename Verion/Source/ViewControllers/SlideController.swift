//
//  SlideController.swift
//  Verion
//
//  Created by Simon Chen on 12/23/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import SwinjectStoryboard
import SlideMenuControllerSwift
import Bond

class SlideController: SlideMenuController {

    let SUBVERSE_STORYBOARD_NAME = "Subverse"
    let SUBVERSE_NAVIGATION_CONTROLLER_ID = "SubverseNavController"
    
    let SLIDER_MENU_STORYBOARD_NAME = "LeftMenu"
    let SLIDER_MENU_CONTROLLER_ID = "LeftMenuController"
    
    var subverseController: SubverseViewController?
    var leftController: LeftMenuController?
    
    
    override func awakeFromNib() {
        
        // Main Controller
        let subverseStoryboard = SwinjectStoryboard.create(name: self.SUBVERSE_STORYBOARD_NAME, bundle: nil)
        let subverseNavController = subverseStoryboard.instantiateViewController(withIdentifier: self.SUBVERSE_NAVIGATION_CONTROLLER_ID) as! UINavigationController
        self.mainViewController = subverseNavController
        
        // Bind Menu button to open menu
        let subverseController = subverseNavController.viewControllers[0] as! SubverseViewController
        _ = subverseController.menuButton.bnd_tap.observe {_ in
            self.openLeft()
        }
        subverseController.delegate = self
        self.subverseController = subverseController
        
        
        // Menu controller
        let sliderMenuStoryboard = SwinjectStoryboard.create(name: self.SLIDER_MENU_STORYBOARD_NAME, bundle: nil)
        let leftController = sliderMenuStoryboard.instantiateViewController(withIdentifier: self.SLIDER_MENU_CONTROLLER_ID) as! LeftMenuController
        self.leftViewController = leftController
        leftController.delegate = self
        
        self.leftController = leftController
        
        
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SlideController: SubverseViewControllerDelegate {
    func subverseViewController(controller: SubverseViewController, willLoadSubverse subverse: String) {
        // Add to the Left Menu's History
        self.leftController?.addToHistory(subverseName: subverse)
    }
}

extension SlideController: LeftMenuControllerDelegate {
    func leftMenuDidSelectSubverse(leftMenu: LeftMenuController, subverseName: String) {
        // Load the subverse
        self.subverseController?.loadTableCells(forSubverse: subverseName)
        
        // Close the left menu
        self.closeLeft()
    }
    
    func leftMenuDidClearHistory(leftMenu: LeftMenuController) {
        self.closeLeft()
    }
}
