//
//  StaticTableViewController.swift
//  BFWControls
//
//  Created by Tom Brodhurst-Hill on 29/05/2016.
//  Copyright © 2016 BareFeetWare.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

class StaticTableViewController: UITableViewController {
    
    // MARK: - Variables

    @IBInspectable var filledUsingLastCell: Bool = false
    @IBInspectable var intrinsicHeightCells: Bool = false
    
    /// Override in subclass, usually by connecting to an IBOutlet collection.
    var excludedCells: [UITableViewCell]? {
        return nil
    }
    
    // TODO: Move to UITableView?
    var lastCell: UITableViewCell? {
        let lastSection = numberOfSectionsInTableView(tableView) - 1
        let lastRow = self.tableView(tableView, numberOfRowsInSection: lastSection) - 1
        let indexPath = NSIndexPath(forRow: lastRow, inSection: lastSection)
        let lastCell = tableView.cellForRowAtIndexPath(indexPath)
        return lastCell
    }
    
    // MARK: - Functions
    
    func indexPathsToInsertCells(cells: [UITableViewCell]) -> [NSIndexPath] {
        var indexPaths = [NSIndexPath]()
        for section in 0 ..< super.numberOfSectionsInTableView(tableView) {
            var numberOfExcludedRows = 0
            for row in 0 ..< super.tableView(tableView, numberOfRowsInSection: section) {
                let superIndexPath = NSIndexPath(forRow: row, inSection: section)
                let superCell = super.tableView(tableView, cellForRowAtIndexPath: superIndexPath)
                if cells.contains(superCell) && tableView.indexPathForCell(superCell) == nil {
                    let indexPath = NSIndexPath(forRow: row - numberOfExcludedRows, inSection: section)
                    indexPaths += [indexPath]
                } else if excludedCells?.contains(superCell) ?? false {
                    numberOfExcludedRows += 1
                }
            }
        }
        return indexPaths
    }
    
    // MARK: - Private functions
    
    private func numberOfExcludedRowsBeforeIndexPath(indexPath: NSIndexPath) -> Int {
        var numberOfExcludedRows = 0
        if let excludedCells = excludedCells {
            let superSection = indexPath.section
            for superRow in 0 ..< super.tableView(tableView, numberOfRowsInSection: superSection) {
                let superIndexPath = NSIndexPath(forRow: superRow, inSection: superSection)
                let cell = super.tableView(tableView, cellForRowAtIndexPath: superIndexPath)
                if excludedCells.contains(cell) {
                    numberOfExcludedRows += 1
                } else if superRow - numberOfExcludedRows == indexPath.row {
                    break
                }
            }
        }
        return numberOfExcludedRows
    }
    
    private func superIndexPathForIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        return NSIndexPath(forRow: indexPath.row + numberOfExcludedRowsBeforeIndexPath(indexPath),
                           inSection: indexPath.section)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if intrinsicHeightCells {
            tableView.estimatedRowHeight = 44.0
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if filledUsingLastCell {
            if let lastCell = lastCell {
                let adjustment = tableView.frame.height + tableView.contentInset.top - CGRectGetMaxY(lastCell.frame)
                if adjustment > 0 {
                    lastCell.frame.size.height += adjustment
                    lastCell.setNeedsLayout()
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = super.tableView(tableView, numberOfRowsInSection: section)
        let indexPath = NSIndexPath(forRow: numberOfRowsInSection - 1, inSection: section)
        let numberOfExcludedCellsInThisSection = numberOfExcludedRowsBeforeIndexPath(indexPath)
        return super.tableView(tableView, numberOfRowsInSection: section) - numberOfExcludedCellsInThisSection
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: superIndexPathForIndexPath(indexPath))
        cell.layoutIfNeeded()
        return cell
    }
    
    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = intrinsicHeightCells
            ? UITableViewAutomaticDimension
            : super.tableView(tableView, heightForRowAtIndexPath: superIndexPathForIndexPath(indexPath))
        return height
    }
    
}
