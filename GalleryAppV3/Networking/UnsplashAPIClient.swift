//
//  UnsplashAPIClient.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import Foundation
import UIKit

enum UnsplashAPIError: LocalizedError {
    case missingAccessKey
    case invalidURL
    case decodingFailed
    case network(Error)
    case serverError(statusCode: Int, message: String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .missingAccessKey:
            return "Не задан UNSPLASH_ACCESS_KEY (Config/Secrets.plist или Info.plist)."
        case .invalidURL:
            return "Неверный URL запроса."
        case .decodingFailed:
            return "Не удалось обработать ответ сервера."
        case .network(let error):
            return error.localizedDescription
        case .serverError(_, let message):
            return message
        case .unknown:
            return "Неизвестная ошибка."
        }
    }
}

protocol UnsplashAPIClientProtocol {
    func fetchPhotos(page: Int, perPage: Int, completion: @escaping (Result<[Photo], Error>) -> Void)
    func fetchPhoto(id: String, completion: @escaping (Result<Photo, Error>) -> Void)
}

final class UnsplashAPIClient: UnsplashAPIClientProtocol {

    // MARK: - Properties

    private let session: URLSession
    private let baseURL = URL(string: "https://api.unsplash.com")!
    private let accessKey: String

    // MARK: - Init

    init(session: URLSession = .shared) throws {
        self.session = session

        guard let key = ConfigLoader.unsplashAccessKey() else {
            throw UnsplashAPIError.missingAccessKey
        }
        self.accessKey = key
    }

    // MARK: - Public

    func fetchPhotos(page: Int, perPage: Int, completion: @escaping (Result<[Photo], Error>) -> Void) {
        var components = URLComponents(url: baseURL.appendingPathComponent("/photos"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "order_by", value: "latest")
        ]

        guard let url = components?.url else {
            completion(.failure(UnsplashAPIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(UnsplashAPIError.network(error)))
                }
                return
            }

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let message = (http.statusCode == 401)
                    ? "Неверный API-ключ Unsplash. Проверьте UNSPLASH_ACCESS_KEY в Info.plist."
                    : "Ответ сервера: \(http.statusCode)"
                DispatchQueue.main.async {
                    completion(.failure(UnsplashAPIError.serverError(statusCode: http.statusCode, message: message)))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(UnsplashAPIError.unknown))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let dtos = try decoder.decode([PhotoDTO].self, from: data)
                let photos = try dtos.map { try $0.toDomain() }
                DispatchQueue.main.async {
                    completion(.success(photos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(UnsplashAPIError.decodingFailed))
                }
            }
        }

        task.resume()
    }

    func fetchPhoto(id: String, completion: @escaping (Result<Photo, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/photos/\(id)")
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(UnsplashAPIError.network(error))) }
                return
            }
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let message = (http.statusCode == 401)
                    ? "Неверный API-ключ Unsplash."
                    : "Ответ сервера: \(http.statusCode)"
                DispatchQueue.main.async {
                    completion(.failure(UnsplashAPIError.serverError(statusCode: http.statusCode, message: message)))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(UnsplashAPIError.unknown)) }
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let dto = try decoder.decode(PhotoDTO.self, from: data)
                let photo = try dto.toDomain()
                DispatchQueue.main.async { completion(.success(photo)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(UnsplashAPIError.decodingFailed)) }
            }
        }
        task.resume()
    }
}

