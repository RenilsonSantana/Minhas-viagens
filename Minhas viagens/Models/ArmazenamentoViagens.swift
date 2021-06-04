//
//  ArmazenamentoViagens.swift
//  Minhas viagens
//
//  Created by Renilson Santana on 27/05/21.
//

import Foundation

class ArmazenamentoViagens{
    
    // MARK: - Atributos
    
    let chaveArmazenamento = "locaisViagem"
    var viagens: [[String: Any]] = [["local": "",
                                        "latitude": "",
                                        "longitude": ""]]
                
    // MARK: - Metodos
    
    func salvarViagem(viagem: [String: String]){
        viagens = listarViagens()
        
        viagens.append(viagem)
        
        UserDefaults.standard.set(viagens, forKey: self.chaveArmazenamento)
        UserDefaults.standard.synchronize()
    }
    
    func listarViagens() -> [[String:String]]{
        if let dados = UserDefaults.standard.object(forKey: chaveArmazenamento){
            guard let viagensSalvas = dados as? [[String:String]] else {return []}
            return viagensSalvas
        }
        return []
    }
    
    func removeViagem(indexPath: Int){
        viagens = listarViagens()

        viagens.remove(at: indexPath)
        UserDefaults.standard.setValue(viagens, forKey: chaveArmazenamento)
        UserDefaults.standard.synchronize()
    }
}
