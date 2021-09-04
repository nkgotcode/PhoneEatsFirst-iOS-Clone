//
//  DiscoverMapView.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/9/21.
//

import MapKit
import Resolver
import SwiftUI
import UIKit

class BusinessAnnotation: NSObject, MKAnnotation {
  @objc dynamic var coordinate: CLLocationCoordinate2D
  var title: String?
  var subtitle: String?

  var business: Business

  init(business: Business) {
    self.business = business
    coordinate = CLLocationCoordinate2D(latitude: business.latitude, longitude: business.longitude)
    title = business.name
    subtitle = business.address
  }
}

class MapViewController: UIViewController {
  @Injected private var repository: DataRepository

  private var mapView = MKMapView()

  override func viewDidLoad() {
    super.viewDidLoad()

    let initialLocation = CLLocation(latitude: 21.0278, longitude: 105.8342)

    let coordinateRegion = MKCoordinateRegion(
      center: initialLocation.coordinate,
      latitudinalMeters: 5000,
      longitudinalMeters: 5000
    )
    mapView.setRegion(coordinateRegion, animated: true)
    mapView.mapType = .standard
    mapView.isZoomEnabled = true
    mapView.isScrollEnabled = true
    mapView.isRotateEnabled = true
    mapView.frame = view.bounds
    mapView.pointOfInterestFilter = .excludingAll
    mapView.translatesAutoresizingMaskIntoConstraints = false
    mapView.delegate = self
    view.addSubview(mapView)

    NSLayoutConstraint.activate([
      mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
    ])

    mapView.register(
      MKMarkerAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: NSStringFromClass(BusinessAnnotation.self)
    )

    addBusinessAnnotations()
  }

  private func addBusinessAnnotations() {
    for business in repository.businesses {
      let annotation = BusinessAnnotation(business: business)
      annotation.coordinate.longitude = business.longitude
      annotation.coordinate.latitude = business.latitude
      annotation.title = business.name
      annotation.subtitle = business.address
      mapView.addAnnotation(annotation)
    }
  }
}

extension MapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard !(annotation is MKUserLocation) else { return nil }

    let identifier = NSStringFromClass(BusinessAnnotation.self)
    let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
    if let businessAnnotationView = view as? MKMarkerAnnotationView {
      businessAnnotationView.canShowCallout = true
      businessAnnotationView.animatesWhenAdded = true
      businessAnnotationView.markerTintColor = UIColor.systemPink
      
      let rightButton = UIButton(type: .detailDisclosure)
      businessAnnotationView.rightCalloutAccessoryView = rightButton
    }

    return view
  }

  func mapView(
    _ mapView: MKMapView,
    annotationView view: MKAnnotationView,
    calloutAccessoryControlTapped control: UIControl
  ) {
    if let annotation = view.annotation as? BusinessAnnotation {
      view.window?.rootViewController?.present(
        UIHostingController(rootView: BusinessView(business: annotation.business)),
        animated: true,
        completion: nil
      )
    }
  }
}

struct MapView: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> MapViewController {
    MapViewController()
  }

  func updateUIViewController(_ uiViewController: MapViewController, context: Context) {}
}

struct DiscoverMapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView()
  }
}
