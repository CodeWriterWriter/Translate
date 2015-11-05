//
//  ViewController.swift
//  Translate
//
//  Created by Robert O'Connor on 16/10/2015.
//  Copyright © 2015 WIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    
    @IBOutlet var background: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var textToTranslate: UITextView!
    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var languageToTranslateTo: UIPickerView!
    @IBOutlet weak var languageToTranslateFrom: UIPickerView!
    var languages: [String] = [String]()
    var languageKeys: [String] = [String]()
    //var data = NSMutableData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textToTranslate.delegate = self
        self.languageToTranslateTo.dataSource = self
        self.languageToTranslateTo.delegate = self
        self.languageToTranslateFrom.dataSource = self
        self.languageToTranslateFrom.delegate = self
        self.textToTranslate.delegate = self;
        languages.append("English"); languageKeys.append("en")
        languages.append("Irish"); languageKeys.append("ga")
        languages.append("Turkish"); languageKeys.append("tr")
        languages.append("French"); languageKeys.append("fr")
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        textToTranslate.text = ""
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1//2
    }
    
    func pickerView(pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func viewTapped(sender : AnyObject) {
        textToTranslate.resignFirstResponder()
    }
    
    
    @IBAction func translate(sender: AnyObject) {
        
        let str = textToTranslate.text
        let escapedStr = str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    
        let destinationLang = languageKeys[languageToTranslateTo.selectedRowInComponent(0)]
        let sourceLang = languageKeys[languageToTranslateFrom.selectedRowInComponent(0)]
        
        if (destinationLang == sourceLang) {return;}
        
        //let session = NSURLSession.sharedSession()
        
        let langStr = (/*sourceLang + "en|"*/ sourceLang + "|" + destinationLang).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let urlStr:String = ("http://api.mymemory.translated.net/get?q="+escapedStr!+"&langpair="+langStr!)
        
        let url = NSURL(string: urlStr)
        
        let request = NSURLRequest(URL: url!)// Creating Http Request
        
        //var data = NSMutableData()var data = NSMutableData()
        
        /*let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()*/
        indicator.startAnimating()
        
        var result = "<Translation Error>"
        
        //NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
        //session.dataTaskWithRequest(request) { (data, response, error) -> Void in
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
       //let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            self.indicator.stopAnimating()
            
            if let httpResponse = response as? NSHTTPURLResponse {
                if(httpResponse.statusCode == 200){
                    
                    let jsonDict: NSDictionary!=(try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                    
                    if(jsonDict.valueForKey("responseStatus") as! NSNumber == 200){
                        let responseData: NSDictionary = jsonDict.objectForKey("responseData") as! NSDictionary
                        
                        result = responseData.objectForKey("translatedText") as! String
                    }
                }
                
                self.translatedText.text = result
                NSLog(result)
            }
        }//);
        //task.resume();
    }
}

