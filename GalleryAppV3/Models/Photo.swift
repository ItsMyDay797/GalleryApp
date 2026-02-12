//
//  Photo.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import Foundation

struct Photo: Identifiable, Hashable {
    let id: String
    let width: Int
    let height: Int
    let colorHex: String?
    let description: String?
    let thumbURL: URL
    let smallURL: URL
    let regularURL: URL
    let userName: String
}

// MARK: - DTOs

struct PhotoDTO: Decodable {
    struct UrlsDTO: Decodable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }

    struct UserDTO: Decodable {
        let id: String
        let username: String
        let name: String?
    }

    let id: String
    let width: Int
    let height: Int
    let color: String?
    let description: String?
    let urls: UrlsDTO
    let user: UserDTO
}

extension PhotoDTO {
    func toDomain() throws -> Photo {
        guard
            let thumb = URL(string: urls.thumb),
            let small = URL(string: urls.small),
            let regular = URL(string: urls.regular)
        else {
            throw NSError(domain: "PhotoDTO", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image URLs"])
        }

        return Photo(
            id: id,
            width: width,
            height: height,
            colorHex: color,
            description: description,
            thumbURL: thumb,
            smallURL: small,
            regularURL: regular,
            userName: user.name ?? user.username
        )
    }
}

