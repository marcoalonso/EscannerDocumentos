//
//  VerDocumentoViewController.swift
//  ScanTextVisionKit
//
//  Created by marco rodriguez on 14/10/22.
//

import UIKit

class VerDocumentoViewController: UIViewController {
    
    var fotoTomada: Bool = false
    var recibirDocumentoMostrar: UIImage?
    
    @IBOutlet weak var documentoVisualizar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentoVisualizar.enableZoom()
        
        if fotoTomada {
            documentoVisualizar.image = recibirDocumentoMostrar ?? UIImage(systemName: "xmark.fill")
        }
        
    }
    

    

}

extension UIImageView {
  func enableZoom() {
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
    isUserInteractionEnabled = true
    addGestureRecognizer(pinchGesture)
  }

  @objc
  private func startZooming(_ sender: UIPinchGestureRecognizer) {
    let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
    guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
    sender.view?.transform = scale
    sender.scale = 1
  }
}
