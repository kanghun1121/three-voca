import XCTest

import DomainInterface
import NetworkingInterface

import Dependencies

@testable import Data

final class ChunkAudioEndpointTests: XCTestCase {
    func test_chunkAudioRequest가_인증_없이_텍스트를_POST로_보낸다() throws {
        let request = try ChunkAudioRequest(text: "the teacher").makeURLRequest()
        let body = try XCTUnwrap(request.httpBody)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: String])

        XCTAssertEqual(request.url?.absoluteString, "https://ebvfeuopuzlpddzvcini.supabase.co/functions/v1/chunk-audio")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(json, ["text": "the teacher"])
        XCTAssertFalse(ChunkAudioRequest(text: "the teacher").requiresAuthentication)
    }

    func test_repository가_응답의_audio_url을_반환한다() async throws {
        let expectedURL = URL(string: "https://example.com/chunks/the-teacher.mp3")!
        let result = try await withDependencies {
            $0.httpClient = ChunkAudioStubHTTPClient()
            $0.audioRemoteDataSource = .liveValue
        } operation: {
            try await AudioRepository.liveValue.chunkAudioURL("the teacher")
        }

        XCTAssertEqual(result, expectedURL)
    }
}

private struct ChunkAudioStubHTTPClient: HTTPClienting {
    func request<T: Decodable>(_ requestable: any Requestable) async throws -> T {
        let request = try requestable.makeURLRequest()
        let body = try XCTUnwrap(request.httpBody)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: String])
        XCTAssertEqual(json["text"], "the teacher")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: Data(#"{"audio_url":"https://example.com/chunks/the-teacher.mp3"}"#.utf8))
    }

    func request(_ requestable: any Requestable) async throws {
        throw NetworkError.invalidRequest
    }

    func data(from url: URL) async throws -> Data {
        throw NetworkError.invalidRequest
    }
}
