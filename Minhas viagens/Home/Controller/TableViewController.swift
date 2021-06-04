//
//  ViewController.swift
//  Minhas viagens
//
//  Created by Renilson Santana on 26/05/21.
//

import UIKit
import MapKit

class TableViewController: UITableViewController {
    
    // MARK: - Atributos
    
    var listaDeViagens: [[String:String]] = []
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        atualizaViagens()
    }
    
    func atualizaViagens(){
        listaDeViagens = ArmazenamentoViagens().listarViagens()
        tableView.reloadData()
    }
    
    func removeViagens(indexPath: IndexPath){
        listaDeViagens.remove(at: indexPath.row)
        ArmazenamentoViagens().removeViagem(indexPath: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaDeViagens.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "viagem", for: indexPath)
        celula.textLabel?.text = self.listaDeViagens[indexPath.row]["local"] as? String
        
        return celula
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            removeViagens(indexPath: indexPath)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let viagemSelecionada = self.listaDeViagens[indexPath.row]
//        guard let latitude =  viagemSelecionada["latitude"] as? CLLocationDegrees else{return}
//        guard let longitude = viagemSelecionada["longitude"] as? CLLocationDegrees else{return}
//        guard let titulo = viagemSelecionada["local"] as? String else{return}
//        print(titulo)
//        let mapaViewController = MapaViewController()
//        mapaViewController.exibeViagem(latitude: latitude, longitude: longitude, titulo: titulo)
//        //present(mapaViewController, animated: true, completion: nil)
        
        performSegue(withIdentifier: "verLocal", sender: indexPath.row)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verLocal"{
            let viewControllerDestino = segue.destination as! MapaViewController
            if let indiceRecuperado = sender {
                guard let indice = indiceRecuperado as? Int else{return}
                viewControllerDestino.viagem = listaDeViagens[indice]
            }
        }
    }

}

