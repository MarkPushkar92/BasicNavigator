//
//  ViewController.swift
//  BasicMapAndRoutes
//
//  Created by Марк Пушкарь on 03.07.2022.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    
    // MARK: Properties
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Adress", for: .normal)
        button.sizeToFit()
        button.layer.cornerRadius = 8
        button.backgroundColor = .red
        button.layer.borderWidth = 2
        button.addTarget(self, action: #selector(addAdressButtonTaped), for: .touchUpInside)
        return button
    }()
    
    let removeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("remove", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .red
        button.layer.borderWidth = 2
        button.addTarget(self, action: #selector(removePinsButtonTaped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    let makeRouteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Build Route", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .red
        button.layer.borderWidth = 2
        button.addTarget(self, action: #selector(makeRouteButtonTaped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    var annotationsArray = [MKPointAnnotation]()
    
    
    //MARK: button methods
    
    @objc func addAdressButtonTaped() {
        
        print("tapADD")
        alertAddAdress(title: "Укажите адресс", placeHolder: "Введите Адресс") { [self] text in
            setupLandMark(adressPlace: text)
            print(text)
        }
    }

    @objc func removePinsButtonTaped() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        makeRouteButton.isHidden = true
        removeButton.isHidden = true
        print("remove")
    }
    
    @objc func makeRouteButtonTaped() {
        
        for index in 0...annotationsArray.count - 2 {
            
            createDirectionRequest(startCordinate: annotationsArray[index].coordinate, destinationCordinate: annotationsArray[index + 1].coordinate)
        }
        
        mapView.showAnnotations(annotationsArray, animated: true)
        print("route")
    }
    
    //MARK: Private Funcs
    
    private func setupLandMark(adressPlace: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlace) { [self] (placemarks, error) in
            
            if let error = error {
                print(error)
                alertError(title: "Error", message: "Network Error")
                return
            }
            
            guard let placemarks = placemarks else {return}
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace)"
            
            guard let placemarkLocation = placemark?.location else {return}
            annotation.coordinate = placemarkLocation.coordinate
            
            annotationsArray.append(annotation)
            
            if annotationsArray.count > 2 {
                makeRouteButton.isHidden = false
                removeButton.isHidden = false
            }
            
            mapView.showAnnotations(annotationsArray, animated: true)
            
        }
    }
    
    private func createDirectionRequest(startCordinate: CLLocationCoordinate2D, destinationCordinate: CLLocationCoordinate2D) {
        let startLocation = MKPlacemark(coordinate: startCordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.alertError(title: "error", message: "Route error")
                return
            }
            
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
            
        }
        
    }
    
    //MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        mapView.delegate = self
    }

}

//MARK: extensions

extension ViewController {
    
    func setLayout() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        mapView.addSubview(addButton)
        mapView.addSubview(removeButton)
        mapView.addSubview(makeRouteButton)
        
        let constrains = [
            addButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 100),
            addButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -25),
            
            removeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -50),
            removeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 25),
            
            makeRouteButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor,constant: -50),
            makeRouteButton.trailingAnchor.constraint(equalTo: addButton.trailingAnchor),
            makeRouteButton.widthAnchor.constraint(equalTo: addButton.widthAnchor)
        ]
        NSLayoutConstraint.activate(constrains)
        
    }
    
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .red
        return render
    }
    
}

