//
//  TaskDetailView.swift
//  Project1ScavengerHunt
//
//  Created by David Perez on 9/14/24.
//

import SwiftUI
import MapKit

import SwiftUI
import PhotosUI
import CoreLocation
import SwiftUI
import PhotosUI
import CoreLocation
import SwiftUI
import PhotosUI
import CoreLocation

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var location: IdentifiableLocation?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider else {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            self?.parent.image = image
                            self?.fetchLocation(from: results.first!)
                        }
                        picker.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                picker.dismiss(animated: true, completion: nil)
            }
        }

        private func fetchLocation(from result: PHPickerResult) {
            let assetID = result.assetIdentifier ?? ""
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "localIdentifier = %@", assetID)
            let assets = PHAsset.fetchAssets(with: fetchOptions)
            guard let asset = assets.firstObject else { return }

            let imageManager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = true

            imageManager.requestImageData(for: asset, options: options) { [weak self] data, _, _, _ in
                guard let data = data, let source = CGImageSourceCreateWithData(data as CFData, nil) else { return }

                if let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
                   let gps = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
                    if let latitude = gps[kCGImagePropertyGPSLatitude as String] as? Double,
                       let longitude = gps[kCGImagePropertyGPSLongitude as String] as? Double {
                        let location = CLLocation(latitude: latitude, longitude: longitude)
                        DispatchQueue.main.async {
                            self?.parent.location = IdentifiableLocation(location: location)
                        }
                    }
                }
            }
        }
    }
}


import Foundation
import CoreLocation

struct IdentifiableLocation: Identifiable, Equatable {
    let id = UUID()
    let location: CLLocation

    var coordinate: CLLocationCoordinate2D {
        location.coordinate
    }

    static func == (lhs: IdentifiableLocation, rhs: IdentifiableLocation) -> Bool {
        return lhs.location.coordinate.latitude == rhs.location.coordinate.latitude &&
               lhs.location.coordinate.longitude == rhs.location.coordinate.longitude
    }
}

import SwiftUI
import MapKit
import CoreLocation
import PhotosUI
import SwiftUI
import MapKit
import CoreLocation

struct TaskDetailView: View {
    @Binding var task: TaskModel
    @State private var showPhotoPicker = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default location
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var photo: UIImage?
    @State private var photoLocation: IdentifiableLocation?

    var body: some View {
        VStack {
            Text("\(task.name)")
                .font(.headline)
            Spacer()
                .frame(height: 20)
            HStack {
                if !(task.completed ?? false) {
                    Image(systemName: "circle")
                } else {
                    Image(systemName: "checkmark.circle")
                }
                Text("\(task.name)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Text("\(task.description ?? "No description")")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Map(coordinateRegion: $mapRegion, annotationItems: photoLocation.map { [ $0 ] } ?? []) { location in
                MapPin(coordinate: location.coordinate, tint: .blue)
            }
            .frame(height: 300)
            
            Button(action: {
                showPhotoPicker = true
            }, label: {
                Rectangle()
                    .overlay(content: {
                        Text("Attach Photo")
                            .foregroundColor(.white)
                    })
                    .foregroundColor(.blue)
            })
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .frame(maxWidth: .infinity, maxHeight: 35)
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPicker(image: $photo, location: $photoLocation)
                    .onChange(of: photoLocation) { newLocation in
                        if let location = newLocation {
                            let coordinate = CLLocationCoordinate2D(
                                latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude
                            )
                            mapRegion.center = coordinate
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
    }
}

#Preview {
    TaskDetailView(task: Binding.constant(TaskModel(name: "Test", completed: false, description: "testing description")))
}
