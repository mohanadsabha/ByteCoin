//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Mohanad on 8/17/22.
//

import Foundation

// MARK: - DelegateProtocol

protocol CoinManagerDelegate {
    func didUpdateRate(_ coinManager: CoinManager, currency: String, exchangeRate: String)
    func didFailWithError(error: Error?)
}

// MARK: - CoinManager

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "YOUR_API_KEY_HERE"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinCurrency(for currency: String) {
        
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
       
        let url = URL(string: urlString)!
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, respone, error in
            if error != nil {
                delegate?.didFailWithError(error: error!)
                return
            }
            if let safeData = data {
                if let bitCoinPrice = parseJASON(data: safeData) {
                    let price = String(format: "%.2f", bitCoinPrice)
                    delegate?.didUpdateRate(self, currency: currency, exchangeRate: price)
                }
            }
        }
        task.resume()
    }
    
    func parseJASON(data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            return lastPrice
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
