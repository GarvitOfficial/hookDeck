# Privacy Policy for HookDeck: Webhook Sender

**Last updated:** October 12, 2026  
**Effective date:** October 12, 2026  
**Application Name:** HookDeck: Webhook Sender  
**Package Name:** `com.ownerofgmt.hookdeck`  
**Developer:** OwnerOfGMT / GarvitOfficial  
**Contact:** [garvit@users.noreply.github.com](mailto:garvit@users.noreply.github.com)

---

## 1. Overview & Commitment to Privacy

HookDeck: Webhook Sender ("HookDeck", "we", "our", or "the app") is committed to protecting your privacy. HookDeck is designed with a **privacy-first, client-only architecture**. We believe your data, identities, credentials, and webhook endpoints belong strictly to you.

HookDeck does **not** operate any intermediary servers, cloud tracking databases, telemetry aggregators, or third-party advertisement networks. All your profile data, webhook destinations, and dispatch records are stored **locally on your device**.

---

## 2. Information We Process

### A. Information Stored Locally on Your Device
When you use HookDeck, the following information is stored directly on your device using local storage (`SharedPreferences`):
- **Sender Profiles:** Identity names, custom avatar image URLs, monogram initial letters, and tonal preferences (e.g., Professional, Playful, Direct).
- **Webhook Destinations:** Custom webhook names, target URLs (such as Discord Webhook URLs, Slack Incoming Webhooks, or custom HTTP endpoints), and destination tags.
- **Audit Logs & Telemetry:** Records of dispatched payloads, delivery status codes (e.g., `200 OK`, `204 No Content`, `400 Bad Request`), round-trip latency metrics, and dispatch timestamps.

> **Important:** This data is stored solely in your device's isolated application sandbox. It is never uploaded to any servers operated by HookDeck.

### B. Voluntary File Attachments
When you choose to attach an image or file to a dispatch:
- The app requests access via the native Android System File Picker / Photo Picker.
- HookDeck only reads the specific file you select.
- The attachment is streamed directly from your device to the webhook endpoint you designated over secure HTTPS.
- HookDeck does not retain persistent copies of your attachments beyond the immediate transmission lifecycle.

---

## 3. How Your Information Is Transmitted

HookDeck functions as a direct client HTTP/HTTPS dispatcher:
- **Direct Transmission:** When you tap "Dispatch Payload", the app creates a secure HTTPS request directly from your mobile device to the destination endpoint URL you entered (e.g., `https://discord.com/api/webhooks/...` or `https://hooks.slack.com/services/...`).
- **No Intermediary Relays:** HookDeck does not route your messages, payloads, or attachments through any intermediary proxy or proxy servers. The transmission is strictly peer-to-endpoint.
- **Encryption in Transit:** All network requests initiated by HookDeck use standard Transport Layer Security (TLS/HTTPS) to encrypt data in transit between your device and the destination server.

---

## 4. Device Permissions Used

HookDeck requests minimal permissions necessary for its core functionality:

| Permission | Purpose |
| :--- | :--- |
| `android.permission.INTERNET` | Required to send HTTP/HTTPS POST payloads to user-configured webhook destinations. |
| `android.permission.ACCESS_NETWORK_STATE` | Used to detect connectivity before attempting a webhook dispatch. |
| System Photo Picker / Storage Picker | Opened strictly on-demand when you tap the attachment button to select an image or document. |

HookDeck does **not** require or request access to your location, contacts, microphone, camera, SMS, or telephony identifiers.

---

## 5. Third-Party Services & Integrations

HookDeck interacts with third-party webhook services that **you** configure:
- **Discord** ([Discord Privacy Policy](https://discord.com/privacy))
- **Slack** ([Slack Privacy Policy](https://slack.com/privacy))
- **Custom HTTP Endpoints** (Governed by your respective server/service privacy terms)

When you transmit payloads to these services, their respective privacy policies and terms of service govern how they receive and store the data. HookDeck is an independent tool and is not affiliated with, endorsed by, or sponsored by Discord, Inc. or Slack Technologies, LLC.

---

## 6. Tracking, Analytics & Advertising

- **Zero Analytics:** HookDeck contains no analytics SDKs (no Google Analytics, Firebase Analytics, Mixpanel, etc.).
- **Zero Advertising:** HookDeck contains no advertising SDKs, ad banners, or third-party tracking cookies.
- **Zero User Profiling:** HookDeck does not track user behavior or create behavioral profiles.

---

## 7. Data Retention & User Controls

You retain total control over your data at all times:
- **Edit & Delete:** You can edit or delete any profile, webhook destination, or history log at any time directly within the application interface.
- **Complete Erasure:** Clearing application data in Android Settings (`Settings > Apps > HookDeck > Clear Storage`) or uninstalling the app permanently purges all stored profiles, destinations, and logs from your device immediately.

---

## 8. Children’s Privacy

HookDeck is a developer and productivity utility not directed toward children under the age of 13 (or under 16 in the European Union). Because we do not collect any personal data, we do not knowingly collect or solicit information from children.

---

## 9. Changes to This Privacy Policy

We may update this Privacy Policy periodically to reflect new features, operational practices, or legal requirements. Any modifications will be posted to our repository or application distribution pages with an updated "Last Updated" date.

---

## 10. Contact Us

If you have any questions, concerns, or inquiries regarding this Privacy Policy or data privacy in HookDeck, please contact:

* **Developer:** Garvit (OwnerOfGMT)
* **GitHub:** [https://github.com/GarvitOfficial](https://github.com/GarvitOfficial)
* **Email:** [garvit@users.noreply.github.com](mailto:garvit@users.noreply.github.com)
