//
//  VerTextoViewController.swift
//  ScanTextVisionKit
//
//  Created by marco rodriguez on 14/10/22.
//

import UIKit

class VerTextoViewController: UIViewController {
    
    var palabrasEncontradas : [String] = []
    @IBOutlet weak var palabrasEncontradasTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        for (indice, palabra) in palabrasEncontradas.enumerated() {
            palabrasEncontradasTextView.text = palabrasEncontradasTextView.text + "\n" + "\(indice).- " + palabra
        }
    }
    
    @IBAction func nuevoEscanner(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    

}
