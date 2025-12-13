//
//  LaunchListViewController+TableView+Extension.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import UIKit

extension LaunchListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.launchItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LaunchCell.reuseID, for: indexPath) as? LaunchCell else {
            return UITableViewCell()
        }
        let launch = viewModel.launchItems[indexPath.row]
        cell.configure(with: launch)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let selectedLaunch = viewModel.launchItems[indexPath.row]
            let detailViewModel = LaunchDetailViewModel(launchID: selectedLaunch.id)
            let detailVC = LaunchDetailViewController(viewModel: detailViewModel)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: 0, y: cell.contentView.frame.height / 2)
        cell.alpha = 0
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row % 10),
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                cell.transform = .identity
                cell.alpha = 1
            }
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let tableViewContentHeight = tableView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

        if position > (tableViewContentHeight - scrollViewHeight - 200) {
            viewModel.fetchLaunches()
        }
    }
}
