import Foundation
import WebRTC

struct SessionDescription: Codable {
    let sdp: String
    let type: String
    
    init(from rtcSessionDescription: RTCSessionDescription) {
        self.sdp = rtcSessionDescription.sdp
        switch rtcSessionDescription.type {
        case .offer:    self.type = "offer"
        case .answer:   self.type = "answer"
        case .prAnswer: self.type = "prAnswer"
        case .rollback: self.type = "rollback"
        @unknown default: self.type = "unknown"
        }
    }
    
    var rtcSessionDescription: RTCSessionDescription? {
        let rtcType: RTCSdpType
        switch self.type {
        case "offer":    rtcType = .offer
        case "answer":   rtcType = .answer
        case "prAnswer": rtcType = .prAnswer
        case "rollback": rtcType = .rollback
        default: return nil
        }
        return RTCSessionDescription(type: rtcType, sdp: self.sdp)
    }
}

struct IceCandidate: Codable {
    let sdp: String
    let sdpMLineIndex: Int32
    let sdpMid: String?
    
    init(from iceCandidate: RTCIceCandidate) {
        self.sdp = iceCandidate.sdp
        self.sdpMLineIndex = iceCandidate.sdpMLineIndex
        self.sdpMid = iceCandidate.sdpMid
    }
    
    var rtcIceCandidate: RTCIceCandidate {
        return RTCIceCandidate(sdp: self.sdp, sdpMLineIndex: self.sdpMLineIndex, sdpMid: self.sdpMid)
    }
}
