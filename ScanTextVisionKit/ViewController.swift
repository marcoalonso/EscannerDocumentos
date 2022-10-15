//
//  ViewController.swift
//  ScanTextVisionKit
//
//  Created by marco rodriguez on 14/10/22.
//

import UIKit
import Vision
import VisionKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textoBuscar: UITextField!
    @IBOutlet weak var previewTextInDocument: UITextView!
    @IBOutlet weak var previewDocImage: UIImageView!
    
    private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    
    var huboCoincidencias: Bool = false
    var documentoEscaneado: Bool = false
    
    var palabrasEncontradas: [String] = []
    let scanVC = VNDocumentCameraViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanVC.delegate = self
        
        previewDocImage.isUserInteractionEnabled = true
        previewDocImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDoc)))
    }
    
    @objc func selectDoc() {
        performSegue(withIdentifier: "verDocumento", sender: self)
    }
    
    
    
    private func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([self.ocrRequest])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func configureOCR() {
        ocrRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            //Si buscamos de nuevo es necesario limpiar las palabras
            self.palabrasEncontradas.removeAll()
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                
                self.previewTextInDocument.text =  self.previewTextInDocument.text + "\n" + topCandidate.string
                if let textoBuscar = self.textoBuscar.text?.replacingOccurrences(of: " ", with: "") {
                    if topCandidate.string.contains("\(textoBuscar)") {
                        print("DEBUG: Texto Encontrado!")
                        self.huboCoincidencias = true
                        let palabraEncontrada = String(topCandidate.string)
                        self.palabrasEncontradas.append(palabraEncontrada)
                    }
                }
                self.ocrRequest.recognitionLevel = .accurate
                self.ocrRequest.recognitionLanguages = ["es-Es"]
                self.ocrRequest.usesLanguageCorrection = true
            }
        }
        
        
        if huboCoincidencias {
            let alerta = UIAlertController(title: "¡ENCONTRADO!", message: "Se encontraron coincidencias con el texto buscado.", preferredStyle: .alert)
            let accionAceptar = UIAlertAction(title: "Quiero verlas", style: .default) { (_) in
                self.performSegue(withIdentifier: "verTexto", sender: self)
            }
            
            let accionCancelar = UIAlertAction(title: "Buscar de nuevo", style: .destructive) { _ in
                self.previewTextInDocument.text = ""
                self.present(self.scanVC, animated: true)
            }
            alerta.addAction(accionAceptar)
            alerta.addAction(accionCancelar)
            self.present(alerta, animated: true)
        } else {
            let alerta = UIAlertController(title: "¡UPS!", message: "No se ah tomado ninguna foto o NO se encontraron coincidencias.", preferredStyle: .alert)
            let accionAceptar = UIAlertAction(title: "Tomar foto", style: .default) { (_) in
                self.present(self.scanVC, animated: true)
            }
            
            let buscarNuevo = UIAlertAction(title: "Buscar otra(s) palabra(s)", style: .default) { (_) in
                
            }
            
            let accionCancelar = UIAlertAction(title: "Quero Salir", style: .destructive) { _ in
                exit(0)
            }
            alerta.addAction(accionAceptar)
            
            alerta.addAction(buscarNuevo)
            alerta.addAction(accionCancelar)
            self.present(alerta, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verTexto"{
            let detalleTexto = segue.destination as! VerTextoViewController
            detalleTexto.palabrasEncontradas = self.palabrasEncontradas
        }
        
        if segue.identifier == "verDocumento" {
            if documentoEscaneado {
                let detalleDocumento = segue.destination as! VerDocumentoViewController
                detalleDocumento.recibirDocumentoMostrar = previewDocImage.image
                detalleDocumento.fotoTomada = true
            }
            
        }
    }
    
    @IBAction func buscarTextoButton(_ sender: UIButton) {
        processImage(previewDocImage.image ?? UIImage(named: "instrucciones")!)
        configureOCR()
    }
    
    @IBAction func scanButton(_ sender: UIButton) {
        present(scanVC, animated: true)
    }
    
}
// MARK: - Delegate method
extension ViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        //Si hay por lo menos un documento escaneado:
        if scan.pageCount > 0 {
            print("DEBUG: scan.pageCount ",scan.pageCount)
            
            //Indica que # de pagina vamos a analizar
            previewDocImage.image = scan.imageOfPage(at: 0)
            
//            processImage(scan.imageOfPage(at: 0))
//            processImage(previewDocImage.image ?? UIImage(named: "instrucciones")!)
            
            controller.dismiss(animated: true)
            
        }
//        configureOCR()
        documentoEscaneado = true
    }
    
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        //Handle properly error
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
}
