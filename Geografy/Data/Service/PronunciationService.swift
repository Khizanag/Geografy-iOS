import AVFoundation
import Foundation

@Observable
@MainActor
final class PronunciationService {
    private(set) var isSpeaking = false
    private(set) var currentText = ""

    private let synthesizer = AVSpeechSynthesizer()
    private var speechDelegate: SpeechDelegate?

    init() {
        let delegate = SpeechDelegate()
        speechDelegate = delegate
        synthesizer.delegate = delegate
        delegate.onDidFinish = { [weak self] in
            Task { @MainActor in
                self?.isSpeaking = false
                self?.currentText = ""
            }
        }
        delegate.onDidCancel = { [weak self] in
            Task { @MainActor in
                self?.isSpeaking = false
                self?.currentText = ""
            }
        }
    }

    func speak(text: String, countryCode: String) {
        guard isEnabled else { return }
        synthesizer.stopSpeaking(at: .immediate)
        let locale = localeTag(for: countryCode)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: locale)
            ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        currentText = text
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        currentText = ""
    }

    func isCurrentlySpeaking(text: String) -> Bool {
        isSpeaking && currentText == text
    }
}

// MARK: - Helpers
private extension PronunciationService {
    var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "pronunciationEnabled") as? Bool ?? true
    }

    func localeTag(for countryCode: String) -> String {
        countryToLocale[countryCode] ?? "en-US"
    }

    // swiftlint:disable:next closure_body_length
    var countryToLocale: [String: String] {
        [
            "AF": "ps-AF",
            "AL": "sq-AL",
            "DZ": "ar-DZ",
            "AD": "ca-AD",
            "AO": "pt-AO",
            "AG": "en-AG",
            "AR": "es-AR",
            "AM": "hy-AM",
            "AU": "en-AU",
            "AT": "de-AT",
            "AZ": "az-AZ",
            "BS": "en-BS",
            "BH": "ar-BH",
            "BD": "bn-BD",
            "BB": "en-BB",
            "BY": "be-BY",
            "BE": "fr-BE",
            "BZ": "en-BZ",
            "BJ": "fr-BJ",
            "BT": "dz-BT",
            "BO": "es-BO",
            "BA": "bs-BA",
            "BW": "en-BW",
            "BR": "pt-BR",
            "BN": "ms-BN",
            "BG": "bg-BG",
            "BF": "fr-BF",
            "BI": "fr-BI",
            "KH": "km-KH",
            "CM": "fr-CM",
            "CA": "en-CA",
            "CV": "pt-CV",
            "CF": "fr-CF",
            "TD": "fr-TD",
            "CL": "es-CL",
            "CN": "zh-CN",
            "CO": "es-CO",
            "KM": "ar-KM",
            "CG": "fr-CG",
            "CD": "fr-CD",
            "CR": "es-CR",
            "HR": "hr-HR",
            "CU": "es-CU",
            "CY": "el-CY",
            "CZ": "cs-CZ",
            "DK": "da-DK",
            "DJ": "fr-DJ",
            "DM": "en-DM",
            "DO": "es-DO",
            "TL": "pt-TL",
            "EC": "es-EC",
            "EG": "ar-EG",
            "SV": "es-SV",
            "GQ": "es-GQ",
            "ER": "ti-ER",
            "EE": "et-EE",
            "SZ": "en-SZ",
            "ET": "am-ET",
            "FJ": "en-FJ",
            "FI": "fi-FI",
            "FR": "fr-FR",
            "GA": "fr-GA",
            "GM": "en-GM",
            "GE": "ka-GE",
            "DE": "de-DE",
            "GH": "en-GH",
            "GR": "el-GR",
            "GD": "en-GD",
            "GT": "es-GT",
            "GN": "fr-GN",
            "GW": "pt-GW",
            "GY": "en-GY",
            "HT": "fr-HT",
            "HN": "es-HN",
            "HU": "hu-HU",
            "IS": "is-IS",
            "IN": "hi-IN",
            "ID": "id-ID",
            "IR": "fa-IR",
            "IQ": "ar-IQ",
            "IE": "en-IE",
            "IL": "he-IL",
            "IT": "it-IT",
            "JM": "en-JM",
            "JP": "ja-JP",
            "JO": "ar-JO",
            "KZ": "kk-KZ",
            "KE": "sw-KE",
            "KI": "en-KI",
            "XK": "sq-XK",
            "KW": "ar-KW",
            "KG": "ky-KG",
            "LA": "lo-LA",
            "LV": "lv-LV",
            "LB": "ar-LB",
            "LS": "en-LS",
            "LR": "en-LR",
            "LY": "ar-LY",
            "LI": "de-LI",
            "LT": "lt-LT",
            "LU": "fr-LU",
            "MG": "mg-MG",
            "MW": "en-MW",
            "MY": "ms-MY",
            "MV": "dv-MV",
            "ML": "fr-ML",
            "MT": "mt-MT",
            "MH": "en-MH",
            "MR": "ar-MR",
            "MU": "fr-MU",
            "MX": "es-MX",
            "FM": "en-FM",
            "MD": "ro-MD",
            "MC": "fr-MC",
            "MN": "mn-MN",
            "ME": "sr-ME",
            "MA": "ar-MA",
            "MZ": "pt-MZ",
            "MM": "my-MM",
            "NA": "en-NA",
            "NR": "en-NR",
            "NP": "ne-NP",
            "NL": "nl-NL",
            "NZ": "en-NZ",
            "NI": "es-NI",
            "NE": "fr-NE",
            "NG": "en-NG",
            "KP": "ko-KP",
            "MK": "mk-MK",
            "NO": "nb-NO",
            "OM": "ar-OM",
            "PK": "ur-PK",
            "PW": "en-PW",
            "PA": "es-PA",
            "PG": "en-PG",
            "PY": "es-PY",
            "PE": "es-PE",
            "PH": "fil-PH",
            "PL": "pl-PL",
            "PT": "pt-PT",
            "QA": "ar-QA",
            "RO": "ro-RO",
            "RU": "ru-RU",
            "RW": "rw-RW",
            "KN": "en-KN",
            "LC": "en-LC",
            "VC": "en-VC",
            "WS": "sm-WS",
            "SM": "it-SM",
            "ST": "pt-ST",
            "SA": "ar-SA",
            "SN": "fr-SN",
            "RS": "sr-RS",
            "SC": "fr-SC",
            "SL": "en-SL",
            "SG": "en-SG",
            "SK": "sk-SK",
            "SI": "sl-SI",
            "SB": "en-SB",
            "SO": "so-SO",
            "ZA": "en-ZA",
            "SS": "en-SS",
            "ES": "es-ES",
            "LK": "si-LK",
            "SD": "ar-SD",
            "SR": "nl-SR",
            "SE": "sv-SE",
            "CH": "de-CH",
            "SY": "ar-SY",
            "TW": "zh-TW",
            "TJ": "tg-TJ",
            "TZ": "sw-TZ",
            "TH": "th-TH",
            "TG": "fr-TG",
            "TO": "en-TO",
            "TT": "en-TT",
            "TN": "ar-TN",
            "TR": "tr-TR",
            "TM": "tk-TM",
            "TV": "en-TV",
            "UG": "en-UG",
            "UA": "uk-UA",
            "AE": "ar-AE",
            "GB": "en-GB",
            "US": "en-US",
            "UY": "es-UY",
            "UZ": "uz-UZ",
            "VU": "fr-VU",
            "VE": "es-VE",
            "VN": "vi-VN",
            "YE": "ar-YE",
            "ZM": "en-ZM",
            "ZW": "en-ZW",
            "VA": "it-IT",
            "HK": "zh-HK",
            "MO": "zh-MO",
            "PR": "es-PR",
            "GL": "kl-GL",
            "FO": "fo-FO",
            "EH": "ar-MA",
            "PS": "ar-PS",
            "KR": "ko-KR",
        ]
    }
}

// MARK: - SpeechDelegate
private final class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    nonisolated(unsafe) var onDidFinish: (() -> Void)?
    nonisolated(unsafe) var onDidCancel: (() -> Void)?

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        onDidFinish?()
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        onDidCancel?()
    }
}
