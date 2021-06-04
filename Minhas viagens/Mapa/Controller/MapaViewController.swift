//
//  MapaViewController.swift
//  Minhas viagens
//
//  Created by Renilson Santana on 26/05/21.
//

import UIKit
import MapKit

class MapaViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapa: MKMapView!
    
    // MARK: - Atributos
    
    var gerenciadorLocalizacao = CLLocationManager()
    var tableView: UITableViewController?
    var viagem: [String:String] = [:]

    // MARK: - live cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapa.delegate = self
        configuraGerenciadorLocalizacao()
        configuraLongPress()
        verificaPorOndeEntrou()
    }
    
    // MARK: - Metodos
    
    func configuraGerenciadorLocalizacao(){
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
    }
    
    func configuraLongPress(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(marca(gesture:)))
        longPress.minimumPressDuration = 2
        
        mapa.addGestureRecognizer(longPress)
    }
    
    @objc func marca(gesture: UIGestureRecognizer){
        if gesture.state == .began{

            //Recuperando as coordenadas do ponto selecionado
            let pontoSelecionado = gesture.location(in: self.mapa)
            let coordenadas = mapa.convert(pontoSelecionado, toCoordinateFrom: self.mapa)
            converteCoordenadasEmEndereco(coordenadas)
        }
    }
    
    func criaViagem(_ local: String,_ latitude: CLLocationDegrees,_ longitude: CLLocationDegrees){
        let viagem = [
            "local":"\(local)",
            "latitude":"\(latitude)",
            "longitude":"\(longitude)"
        ]
        ArmazenamentoViagens().salvarViagem(viagem: viagem)
    }
    
    func converteCoordenadasEmEndereco(_ coordenadas: CLLocationCoordinate2D){
        
        let local = CLLocation(latitude: coordenadas.latitude, longitude: coordenadas.longitude)
        CLGeocoder().reverseGeocodeLocation(local) { detalhesLocal, erro in
            if erro == nil{
                var endereco = "Endereco não encontrado!!"
                guard let dadosLocal = detalhesLocal?.first else {return}
                if dadosLocal.name != nil{
                    endereco = dadosLocal.name!
                }else{
                    if dadosLocal.thoroughfare != nil{
                        endereco = dadosLocal.thoroughfare!
                    }
                    if dadosLocal.subThoroughfare != nil{
                        endereco += ", " + dadosLocal.subThoroughfare!
                    }
                }
                self.configuraPino(coordenadas, titulo: endereco)
                self.criaViagem(endereco, coordenadas.latitude, coordenadas.longitude)
            }
            else{
                print(erro!.localizedDescription)
            }
        }
    }
    
    func configuraPino(_ coordenadas: CLLocationCoordinate2D, titulo: String){
        let anotacao = MKPointAnnotation()
        anotacao.coordinate.latitude = coordenadas.latitude
        anotacao.coordinate.longitude = coordenadas.longitude
        anotacao.title = titulo
        self.mapa.addAnnotation(anotacao)
    }
    
    func exibeViagem(latitude: CLLocationDegrees, longitude: CLLocationDegrees, titulo: String){
        let coordenada = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        configuraPino(coordenada, titulo: titulo)
    }
    
    func verificaPorOndeEntrou(){
        //Via viagem selecionada
        if viagem != [:]{
            guard let latitude = CLLocationDegrees(viagem["latitude"]!) else{return}
            guard let longitude = CLLocationDegrees(viagem["longitude"]!) else{return}
            guard let titulo = viagem["local"] else{return}
            exibeViagem(latitude: latitude, longitude: longitude, titulo: titulo)
            
            let coordenada = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            exibirLocal(coordenada)
        }
    }
    
    func exibirLocal(_ coordenada: CLLocationCoordinate2D){
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let regiao = MKCoordinateRegion(center: coordenada, span: span)
        self.mapa.setRegion(regiao, animated: true)
    }
    
    // MARK: - LocationManeger
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .authorizedWhenInUse{
            let alert = UIAlertController(title: "Acesso a localizacão", message: "Este aplicativo precisa do acesso a sua localizacão para funcionar", preferredStyle: .alert)
            
            let acaoConfigurar = UIAlertAction(title: "Abrir configuracões", style: .default) { acaoConfigurar in
                if let url = URL(string: UIApplication.openSettingsURLString){
                    UIApplication.shared.open(url)
                }
            }
            alert.addAction(acaoConfigurar)
            
            let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            alert.addAction(cancelar)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if viagem == [:]{
            guard let coordenada = locations.first?.coordinate else{return}
            exibirLocal(coordenada)
        }
    }

}
