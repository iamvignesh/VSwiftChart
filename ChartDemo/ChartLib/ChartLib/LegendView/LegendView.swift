//
//  LegendView.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 27/01/23.
//

import Foundation
import UIKit
public struct LegendInfo:Hashable
{
    public static func == (lhs: LegendInfo, rhs: LegendInfo) -> Bool {
        return (lhs.title ?? "") == (rhs.title ?? "")
    }
    public init(_color:UIColor,_title:String) {
        self.color = _color
        self.title = _title
    }
    var title:String?
    var color:UIColor?
}
class LegendView:BaseView,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
    typealias LegendSource = UICollectionViewDiffableDataSource<Section, LegendInfo>
    var source:LegendSource?
    var legendData:Array<LegendInfo>?
    {
        didSet
        {
            ApplySnapShot()
        }
    }
    
    var collectionView:UICollectionView?
    override func reloadData(completion: @escaping (() -> Void) = {
        
    }) {
        collectionView?.frame = self.bounds;
    }
    override func InitializeUIElements() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal;
        let verticalInset = 0.1*bounds.height
        layout.sectionInset = UIEdgeInsets(top: verticalInset/2, left: 0, bottom: verticalInset/2, right: 0);
        layout.itemSize = CGSize(width: 60, height: self.frame.height)
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout);
        collectionView?.backgroundColor = UIColor.clear
        let contentInset:CGFloat = 0;
        collectionView?.contentInset = UIEdgeInsets(top: contentInset, left: contentInset, bottom: contentInset, right: contentInset);
        
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.register(LegendCell.self, forCellWithReuseIdentifier: "legend")
        source = UICollectionViewDiffableDataSource<Section, LegendInfo>(collectionView: collectionView!) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: LegendInfo) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "legend", for: indexPath) as! LegendCell
            cell.title = itemIdentifier.title
            cell.color = itemIdentifier.color;
            return cell;
        }
        collectionView?.dataSource  = source!
        collectionView?.delegate = self
        self.addSubview(collectionView!)
        ApplySnapShot()
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = legendData![indexPath.row];
        return CGSize(width: (item.title ?? "").width(withConstrainedHeight: collectionView.frame.height, font: LegendCell.font) + collectionView.frame.height + 18, height: collectionView.frame.height)
    }
    
    func ApplySnapShot()
    {
        var snapshot = NSDiffableDataSourceSnapshot<Section, LegendInfo>()
        snapshot.appendSections([.main])
        snapshot.appendItems(legendData ?? [])
        source?.apply(snapshot)
    }
}
enum Section {
  case main
}


