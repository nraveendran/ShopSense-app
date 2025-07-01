import SwiftUI
import VisionKit

struct VNDocumentCameraViewControllerRepresentableSave: UIViewControllerRepresentable {
    var onScanComplete: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = context.coordinator
        
        return documentCameraViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onScanComplete: onScanComplete)
    }
    
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        
        let onScanComplete: (UIImage?) -> Void
        
         init(onScanComplete: @escaping (UIImage?) -> Void) {
                self.onScanComplete = onScanComplete
        }
        
        /// Tells the delegate that the user successfully saved a scanned document from the document camera.
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            controller.dismiss(animated: true, completion: nil)
                let firstImage = scan.pageCount > 0 ? scan.imageOfPage(at: 0) : nil
                onScanComplete(firstImage)
        }
        
        // Tells the delegate that the user canceled out of the document scanner camera.
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true, completion: nil)
                     onScanComplete(nil)
        }
        
        /// Tells the delegate that document scanning failed while the camera view controller was active.
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            controller.dismiss(animated: true, completion: nil)
                  print("Document scanner error: \(error.localizedDescription)")
                  onScanComplete(nil)
        }
    }
}
