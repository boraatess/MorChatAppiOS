# MorChat Video & Voice Call Architecture

## 1. Core Technologies Needed
To implement real-time 1-on-1 video and voice calls, we need a WebRTC provider. Popular enterprise solutions include:
- **Agora (Recommended)**: Extremely fast, easy to implement in iOS, robust documentation. Perfect for token/credit-based 1-to-1 video apps.
- **Twilio Video**: Very stable, but they are sunsetting their video product, so it's not a viable long-term choice anymore.
- **ZegoCloud**: Very similar to Agora, often slightly cheaper, good SDKs.
- **WebRTC (Raw)**: Building your own TURN/STUN servers. Only recommend if you have a massive DevOps team constraint.

### Decision: Agora SDK
Since this is a credit-based dating/chat app context, Agora is the industry standard. It supports video streams, audio-only modes, and integrates well with backend logic (calculating tokens per minute).

## 2. Push Notifications & Call Ringing (CallKit)
When the app is closed/in background, we can't just "show an incoming screen".
- **Apple CallKit**: Makes the app ring like a native WhatsApp/FaceTime call.
- **APNs (VoIP Push)** / **PushKit**: Required to wake the app up instantly and trigger CallKit.

## 3. The Backend Connection (Firestore / Cloud Functions)
Since the app uses Firebase, the call flow will look like this:
1. **Call Init**: Caller presses "Call Now" -> App creates a `Calls` document in Firestore (`callerId`, `receiverId`, `status: 'ringing'`).
2. **Push Trigger**: A Cloud Function listens to the new `Calls` doc and sends a VoIP Push Notification to the receiver's device.
3. **App Wakes Up (Receiver)**: CallKit shows incoming call UI. Receiver presses "Accept".
4. **Call Connects (Agora)**: Both devices connect to the same Agora Channel (channel name can be the Firestore `callId`).
5. **Token Calculation**: A secure Cloud Function must deduct tokens every minute. If tokens run out, it forces a disconnect event.

## 4. Required Packages (Swift Package Manager / CocoaPods)
- `AgoraRtcEngine_iOS` (For video/audio handling)
- `PushKit` & `CallKit` (Native iOS frameworks, no install needed, just need to implement)
- Firebase Cloud Messaging (For pushing standard chat notifications, but VoIP push needs specific Apple certs).

## 5. UI Requirements to Build
1. **Ringing Screen (Caller Side)**: Showing "Calling User X..." with an end call button.
2. **CallKit Integration**: The native iOS incoming call screen.
3. **Active Call Screen**:
   - Full-screen video of the Publisher.
   - Picture-in-Picture (PiP) or floating small view for the user's camera.
   - End Call, Mute Mic, Switch Camera, Disable Camera buttons.
   - Overlay showing "Remaining Minutes / Tokens".

## WebSocket Analysis for A/V Calls
WebSocket is excellent for signaling (sending JSON messages like "User A calls User B", "Here is my IP address"), but it is **NOT SUITABLE** for actual video/audio stream transmission. 

Why?
1. **TCP vs UDP**: WebSockets run on TCP. TCP ensures every packet arrives in order. If a video packet drops, TCP pauses everything to resend it, causing massive lag/freezes (buffering). Live video needs UDP (where dropped frames are just skipped to maintain real-time speed).
2. **Server Costs**: Funneling heavy 720p 30fps video through a custom Node.js/Python WebSocket server will bankrupt you in bandwidth and CPU costs. It requires immense infrastructure to transcode and route streams (SFU/MCU patterns).
3. **WebRTC**: The industry standard for real-time video is WebRTC (which uses UDP). WebRTC is peer-to-peer or routed through dedicated media servers. 

**Conclusion**: We *can* use WebSockets (or Firestore realtime listeners) for the "ringing" and "accepting" signaling part, but for the actual connection of camera and microphone, we must use WebRTC (like Agora, Twilio, or LiveKit).

## Firestore + Native WebRTC Implementation
If the user insists on an absolute $0 budget without 3rd party video SDKs, we MUST use native iOS WebRTC and use Firestore as the signaling server.
**Pros:**
- Completely free (only costs Firestore read/writes).
- P2P connection (very low latency if on the same network). 

**Cons:**
- Only works ~70% of the time. If users are behind strict NATs or corporate firewalls (Cellular networks often are), P2P fails.
- We MUST set up a TURN server (Twilio offers cheap ones, or Coturn on DigitalOcean) to relay video when P2P fails. Otherwise, calls will randomly drop or show black screens.
- WebRTC code in native iOS is notoriously complex (handling SDPs, ICE Candidates).
- No built-in moderation (recording, banning on the spot).

## WebRTC Build Issues
The user encountered `fatal error: 'sdk/objc/base/RTCMacros.h' file not found` and `Clang dependency scanner failure` using the stasel/WebRTC SPM package on iOS.
This is a very common issue with the stasel/WebRTC repo because it sometimes fails to link the underlying C++ headers correctly depending on the Xcode version and the target SDK (especially targeting simulators).

We need to fix this by:
1. Using an alternative, more stable pre-compiled WebRTC framework (like Google's official CocoaPods or a better SPM wrapper).
2. Given the complexities and the user's ultimate goal to fallback to Agora if this fails, and given how painful native WebRTC is to setup and maintain without an entire team, it's highly recommended to pivot to Agora right now to save time and guarantee a working product.
