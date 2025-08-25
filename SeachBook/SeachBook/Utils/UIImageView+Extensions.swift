//
//  UIImageView+Extensions.swift
//  SeachBook
//
//  Created by 이아연 on 8/25/25.
//

import UIKit
import Combine

extension UIImageView {

    @discardableResult
    func setImage(url: String, size: CGSize? = nil, placeholder: UIImage? = nil) -> AnyCancellable? {

        self.image = placeholder
        guard let imageUrl: URL = URL(string: url) else { return nil }

        return ImageLoader.shared.load(url: imageUrl as NSURL, targetSize: size)
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveValue: { [weak self] resizedImage in
                    guard let self else { return }
                    UIView.transition(
                        with: self,
                        duration: 0.2,
                        options: .transitionCrossDissolve,
                        animations: { self.image = resizedImage ?? placeholder },
                        completion: nil
                    )
                }
            )
    }
}
