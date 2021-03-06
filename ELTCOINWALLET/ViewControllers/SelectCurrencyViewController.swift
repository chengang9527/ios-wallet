//
//  SelectCurrencyViewController.swift
//  ELTCOINWALLET
//
//  Created by Oliver Mahoney on 25/10/2017.
//  Copyright © 2017 ELTCOIN. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import NVActivityIndicatorView

protocol SelectCurrenyProtocol {
    func currencySelected(_ token: ETHToken)
}

class SelectCurrencyViewController: UIViewController {
    
    let loadingView = UIView()

    var delegate: SelectCurrenyProtocol?
    var tokens = [ETHToken]()
    let reuseIdentifier = "CURRENCY_CELL_IDENTIFIER"
    
    var walletBalance: ETHTokenBalance?

    // Empty Transaction List Label
    var emptyListLabel = UILabel()
    
    // TOP BAR
    var topBarBackgroundView = UIView()
    var topBarTitleLabel = UILabel()
    var topBarBackgroundLineView = UIView()
    var topBarCancelButton = UIButton()
    var topBarETHButton = UIButton()

    // Form Elements
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.CustomColor.White.offwhite
        
        setupViews()
        setupTableData()
    }
    
    func setupTableData(){

        let walletManager = WalletTransactionsManager()
        
        self.toggleLoadingState(true)
        walletManager.getBalance(balanceImportCompleted: { (walletBalance) in
            self.tokens = walletBalance.tokens ?? [ETHToken]()
            self.walletBalance = walletBalance
            self.emptyListLabel.isHidden = !(self.tokens.count == 0)
            self.toggleLoadingState(false)
            self.tableView.reloadData()
        })
    }
    
    func setupViews(){
        
        view.addSubview(loadingView)
        loadingView.isHidden = true
        
        // TOP VIEWS
        
        let  topOffset = UIDevice.current.iPhoneX ? 20 : 0
        
        self.view.addSubview(topBarBackgroundView)
        topBarBackgroundView.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.top.equalTo(view).offset(topOffset)
            make.centerX.width.equalTo(view)
        }
        
        topBarBackgroundView.addSubview(topBarTitleLabel)
        topBarTitleLabel.textAlignment = .center
        topBarTitleLabel.numberOfLines = 0
        topBarTitleLabel.textColor = UIColor.CustomColor.Black.DeepCharcoal
        topBarTitleLabel.text = "Select Currency"
        topBarTitleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 18.0)
        topBarTitleLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(topBarBackgroundView)
            make.top.equalTo(topBarBackgroundView.snp.top).offset(30)
            make.width.equalTo(topBarBackgroundView)
        }
        
        topBarBackgroundView.addSubview(topBarBackgroundLineView)
        topBarBackgroundLineView.backgroundColor = UIColor.CustomColor.Grey.lightGrey
        topBarBackgroundLineView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.width.equalTo(view)
            make.top.equalTo(topBarBackgroundView.snp.bottom)
            make.height.equalTo(1)
        }
        
        topBarBackgroundView.addSubview(topBarCancelButton)
        topBarCancelButton.contentHorizontalAlignment = .left
        topBarCancelButton.setTitleColor(UIColor.black, for: .normal)
        topBarCancelButton.setTitle("Cancel", for: .normal)
        topBarCancelButton.addTarget(self, action: #selector(SelectCurrencyViewController.cancelButtonPressed), for: .touchUpInside)
        topBarCancelButton.snp.makeConstraints { (make) in
            make.width.equalTo(120)
            make.height.equalTo(28)
            make.top.equalTo(topBarBackgroundView).offset(25)
            make.left.equalTo(topBarBackgroundView.snp.left).offset(10)
        }
        
        topBarBackgroundView.addSubview(topBarETHButton)
        topBarETHButton.contentHorizontalAlignment = .right
        topBarETHButton.setTitleColor(UIColor.black, for: .normal)
        topBarETHButton.setTitle("ETH", for: .normal)
        topBarETHButton.addTarget(self, action: #selector(SelectCurrencyViewController.ETHButtonPressed), for: .touchUpInside)
        topBarETHButton.snp.makeConstraints { (make) in
            make.width.equalTo(120)
            make.height.equalTo(28)
            make.top.equalTo(topBarBackgroundView).offset(25)
            make.right.equalTo(topBarBackgroundView.snp.right).offset(-10)
        }
        
        // Table View
        
        view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CurrencyTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(topBarBackgroundView.snp.bottom)
        }
        
        view.addSubview(emptyListLabel)
        emptyListLabel.text = "No tokens with balances to show\n😥"
        emptyListLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)
        emptyListLabel.numberOfLines = 0
        emptyListLabel.isHidden = true
        emptyListLabel.textAlignment = .center
        emptyListLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(tableView)
        }
    }
    
    @objc func cancelButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func ETHButtonPressed(){
        let token = ETHToken()
        token.tokenInfo = ETHTokenInfo()
        token.tokenInfo?.symbol = "ETH"
        token.tokenInfo?.name = "Ethereum"
        token.tokenInfo?.decimals = 0.0
        token.balance = walletBalance?.ETH?.balance ?? 0.0
        
        if delegate != nil {
            delegate?.currencySelected(token)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func toggleLoadingState(_ isLoading: Bool) {
        
        loadingView.isHidden = true
        
        if(isLoading){
            loadingView.isHidden = false
            loadingView.backgroundColor = UIColor.CustomColor.White.offwhite
            loadingView.snp.makeConstraints({ (make) in
                make.center.height.width.equalTo(self.view)
            })
            
            let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            let loadingIndicator = NVActivityIndicatorView(frame: frame, type: .ballBeat, color: UIColor.CustomColor.Black.DeepCharcoal, padding: 1)
            
            loadingView.addSubview(loadingIndicator)
            loadingIndicator.snp.makeConstraints({ (make) in
                make.height.width.equalTo(50)
                make.center.equalTo(loadingView)
            })
            loadingIndicator.startAnimating()
        }
    }
}

extension SelectCurrencyViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CurrencyTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CurrencyTableViewCell
        
        let token = self.tokens[indexPath.row]
        
        cell.setupCell(token: token)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let token = self.tokens[indexPath.row]
        
        if delegate != nil {
            delegate?.currencySelected(token)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count;
    }
}

