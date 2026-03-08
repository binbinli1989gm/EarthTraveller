//
//  MapView.swift
//  EarthTravaller
//
//  Created by Robert Arvin Lee on 9/3/26.
//


import SwiftUI
import MapKit
import GEOSwift

struct MapView: UIViewRepresentable {

    let geometries: [Geometry]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {

        // Remove old overlays and annotations
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)

        for geom in geometries {

            // Add overlays for lines and polygons
            if let overlay = overlayFromGeometry(geom) {
                uiView.addOverlay(overlay)
            }

            // Add annotations for points
            if let annotation = annotationFromGeometry(geom) {
                uiView.addAnnotation(annotation)
            }
        }

        // Optional: zoom to first geometry
        if let first = geometries.first as? Point {
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: first.y, longitude: first.x),
                span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 80)
            )
            uiView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject, MKMapViewDelegate {

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 1
                return renderer
            }

            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor.green.withAlphaComponent(0.3)
                renderer.strokeColor = .green
                renderer.lineWidth = 1
                return renderer
            }

            if let multi = overlay as? MKMultiPolygon {
                let renderer = MKMultiPolygonRenderer(multiPolygon: multi)
                renderer.fillColor = UIColor.orange.withAlphaComponent(0.3)
                renderer.strokeColor = .orange
                renderer.lineWidth = 1
                return renderer
            }

            return MKOverlayRenderer()
        }
    }
}

// MARK: - Geometry to Overlay / Annotation

func overlayFromGeometry(_ geometry: Geometry) -> MKOverlay? {
    switch geometry {
    case let line as LineString:
        let coords = line.points.map { CLLocationCoordinate2D(latitude: $0.y, longitude: $0.x) }
        return MKPolyline(coordinates: coords, count: coords.count)
    case let polygon as Polygon:
        let coords = polygon.exterior.points.map { CLLocationCoordinate2D(latitude: $0.y, longitude: $0.x) }
        return MKPolygon(coordinates: coords, count: coords.count)
    case let multi as MultiPolygon:
        let polygons = multi.polygons.map { poly -> MKPolygon in
            let coords = poly.exterior.points.map { CLLocationCoordinate2D(latitude: $0.y, longitude: $0.x) }
            return MKPolygon(coordinates: coords, count: coords.count)
        }
        return MKMultiPolygon(polygons)
    default:
        return nil
    }
}

func annotationFromGeometry(_ geometry: Geometry) -> MKPointAnnotation? {
    if let point = geometry as? Point {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: point.y, longitude: point.x)
        return annotation
    }
    return nil
}
