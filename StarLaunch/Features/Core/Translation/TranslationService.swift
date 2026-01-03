//
//  TranslationService.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 3.01.2026.
//

import Foundation

final class TranslationService {
    static let shared = TranslationService()

    private let baseURL = "https://api.mymemory.translated.net/get"
    private var cache: [String: String] = [:]
    private let cacheQueue = DispatchQueue(label: "translation.cache.queue")

    private init() {}


    func translate(_ text: String, to targetLanguage: String) async -> String {
        guard targetLanguage != "en" else { return text }

        let cacheKey = "\(text.hashValue)_\(targetLanguage)"
        if let cached = getCached(key: cacheKey) {
            return cached
        }

        if text.count < 3
            || (text.split(separator: " ").count == 1 && text.first?.isUppercase == true)
        {
            return text
        }

        if text.count > 200 {
            let sentences = text.components(separatedBy: ". ")
            var translatedSentences: [String] = []

            for sentence in sentences {
                if sentence.isEmpty { continue }
                do {
                    let translated = try await performTranslation(
                        text: sentence, to: targetLanguage)
                    translatedSentences.append(translated)
                } catch {
                    translatedSentences.append(sentence)
                }
            }

            let result = translatedSentences.joined(separator: ". ")
            setCache(key: cacheKey, value: result)
            return result
        }

        do {
            let translated = try await performTranslation(text: text, to: targetLanguage)
            setCache(key: cacheKey, value: translated)
            return translated
        } catch {
            return text
        }
    }

    func translateBatch(_ texts: [String], to targetLanguage: String) async -> [String] {
        await withTaskGroup(of: (Int, String).self) { group in
            for (index, text) in texts.enumerated() {
                group.addTask {
                    let translated = await self.translate(text, to: targetLanguage)
                    return (index, translated)
                }
            }

            var results = Array(repeating: "", count: texts.count)
            for await (index, translated) in group {
                results[index] = translated
            }
            return results
        }
    }

    func clearCache() {
        cacheQueue.sync {
            cache.removeAll()
        }
    }


    private func performTranslation(text: String, to targetLanguage: String) async throws -> String
    {
        let langPair = "en|\(targetLanguage)"

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "q", value: text),
            URLQueryItem(name: "langpair", value: langPair),
        ]

        guard let url = components?.url else {
            throw TranslationError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw TranslationError.networkError
        }

        do {
            let result = try JSONDecoder().decode(MyMemoryResponse.self, from: data)

            guard result.responseStatus == 200,
                let translatedText = result.responseData?.translatedText
            else {
                throw TranslationError.translationFailed
            }

            return translatedText
        } catch {
            throw TranslationError.translationFailed
        }
    }

    private func getCached(key: String) -> String? {
        cacheQueue.sync {
            cache[key]
        }
    }

    private func setCache(key: String, value: String) {
        cacheQueue.sync {
            cache[key] = value
        }
    }
}


private struct MyMemoryResponse: Codable {
    let responseData: ResponseData?
    let responseStatus: Int

    struct ResponseData: Codable {
        let translatedText: String
    }
}


enum TranslationError: Error {
    case invalidURL
    case networkError
    case translationFailed
}
