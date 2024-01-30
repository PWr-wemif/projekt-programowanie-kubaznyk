import SwiftUI
import PDFKit

struct AgreementsView: View {
    @State private var isDocumentPickerPresented: Bool = false
    @State private var selectedPDF: PDFDocument?

    var body: some View {
        VStack {
            if let pdfDocument = selectedPDF {
                PDFKitView(pdfDocument: pdfDocument)
                    .navigationBarTitle("Umowa PDF", displayMode: .inline)
            } else {
                Button("Wybierz plik PDF") {
                    isDocumentPickerPresented.toggle()
                }
                .padding()
                .sheet(isPresented: $isDocumentPickerPresented) {
                    DocumentPicker { pdfDocument, url in
                        if let pdfDocument = pdfDocument {
                            selectedPDF = pdfDocument
                        }
                    }
                }
            }
        }
    }
}

struct DocumentPickerView: View {
    var onDocumentSelected: (PDFDocument?, URL) -> Void

    var body: some View {
        DocumentPicker { pdfDocument, url in
            onDocumentSelected(pdfDocument, url)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = pdfDocument
    }
}

struct AgreementsView_Previews: PreviewProvider {
    static var previews: some View {
        AgreementsView()
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    var onDocumentSelected: (PDFDocument?, URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let pdfURL = urls.first {
                if let pdfDocument = PDFDocument(url: pdfURL) {
                    parent.onDocumentSelected(pdfDocument, pdfURL)
                } else {
                    parent.onDocumentSelected(nil, pdfURL)
                }
            }
        }
    }
}
