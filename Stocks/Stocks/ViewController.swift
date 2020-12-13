//
//  ViewController.swift
//  Stocks
//
//  Created by Никита Игумнов on 13.12.2020.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private let apiToken: String = "pk_5c3ba75f9317481a8883550c4bed8773"
    private var companies: [String: String] = ["Apple": "AAPL",
                                               "Microsoft": "MSFT",
                                               "Google": "GOOG",
                                               "Amazon": "AMZN",
                                               "Facebook": "FB"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self
        
        self.activityIndicator.hidesWhenStopped = true
        
        self.loadCompanies()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.companies.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(self.companies.keys)[row]
    }
    
    private func requestQuoteUpdate() {
        self.activityIndicator.startAnimating()
        self.companyNameLabel.text = "-"
        self.companySymbolLabel.text = "-"
        self.priceLabel.text = "-"
        self.priceChangeLabel.text = "-"
        self.priceChangeLabel.textColor = UIColor.black
        self.imageView.image = UIImage()
        
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        self.requestQuote(for: selectedSymbol)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.requestQuoteUpdate()
    }
    
    private func loadCompanies() {
        let url = URL(string: "https://cloud.iexapis.com/v1/ref-data/symbols?token=\(apiToken)")!
        
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                print("Network error")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Network error", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            self.parseCompanies(data: data)
        }
        
        dataTask.resume()
    }
    
    private func parseCompanies(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
                let json = jsonObject as? [[String: Any]]
            else {
                print("Invalid JSON format")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Network error", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            for company in json {
                let name = company["name"] as? String ?? "-"
                let symbol = company["symbol"] as? String ?? "-"
                companies[name] = symbol
            }
            DispatchQueue.main.async {
                self.companyPickerView.reloadAllComponents()
                self.requestQuoteUpdate()
            }
        } catch {
            print("JSON parsing error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "Network error", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func requestQuote(for symbol: String) {
        let url = URL(string: "https://cloud.iexapis.com/v1/stock/\(symbol)/quote?token=\(apiToken)")!
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                print("Network error")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Network error", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            self.parseQuote(data: data)
        }
        
        dataTask.resume()
    }
    
    private func parseQuote(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double
            else {
                print("Invalid JSON format")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Error with the site", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName,
                                      symbol: companySymbol,
                                      price: price,
                                      priceChange: priceChange)
            }
        } catch {
            print("JSON parsing error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "Error with the site", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func displayStockInfo(companyName: String, symbol: String, price: Double, priceChange: Double) {
        self.activityIndicator.stopAnimating()
        self.companyNameLabel.text = companyName
        self.companySymbolLabel.text = symbol
        self.priceLabel.text = "\(price)"
        self.priceChangeLabel.text = "\(priceChange)"
        if priceChange > 0 {
            self.priceChangeLabel.textColor = UIColor.green
        } else if priceChange < 0 {
            self.priceChangeLabel.textColor = UIColor.red
        } else {
            self.priceChangeLabel.textColor = UIColor.black
        }
        self.downloadImage(for: symbol)
    }
    
    
    private func downloadImage(for symbol: String) {
        let urlForImage = URL(string: "https://cloud.iexapis.com/v1/stock/\(symbol)/logo?token=\(apiToken)")!
        
        let dataTask = URLSession.shared.dataTask(with: urlForImage) { (data, response, error) in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                print("Network error")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Network error", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            self.parseLogo(data: data)
        }
        
        dataTask.resume()
    }
    
    private func parseLogo(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
                let json = jsonObject as? [String: Any],
                let imageUrl = json["url"] as? String
            else {
                print("Invalid JSON format")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Error with the site", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                 let url = URL(string: imageUrl)
                 let data = try? Data(contentsOf: url!)
                 self.imageView.image = UIImage(data: data!)
            }
        } catch {
            print("JSON parsing error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "Error with the site", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}
