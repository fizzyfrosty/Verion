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
    
    
    
    override func awakeFromNib() {
        
        // Main Controller
        let subverseStoryboard = SwinjectStoryboard.create(name: self.SUBVERSE_STORYBOARD_NAME, bundle: nil)
        let subverseNavController = subverseStoryboard.instantiateViewController(withIdentifier: self.SUBVERSE_NAVIGATION_CONTROLLER_ID) as! UINavigationController
        self.mainViewController = subverseNavController
        
        // Bind Menu button to open menu
        let subverseController = subverseNavController.viewControllers[0] as? SubverseViewController
        _ = subverseController?.menuButton.bnd_tap.observe {_ in
            self.openLeft()
        }
        
        
        // Menu controller
        let sliderMenuStoryboard = SwinjectStoryboard.create(name: self.SLIDER_MENU_STORYBOARD_NAME, bundle: nil)
        let leftController = sliderMenuStoryboard.instantiateViewController(withIdentifier: self.SLIDER_MENU_CONTROLLER_ID)
        self.leftViewController = leftController
        
        
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
