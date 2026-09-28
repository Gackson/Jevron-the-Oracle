import SwiftUI

/// Interface copy follows the in-app language preference, independent of device language.
struct InterfaceCopy {
    let language: String
    var isChinese: Bool { language == "zh-Hans" }
    subscript(_ english: String) -> String {
        isChinese ? Self.chinese[english, default: english] : english
    }
    func selectedCharacter(_ name: String) -> String {
        String(format: self["Choose character. %@ selected"], name)
    }
    func echoes(_ count: Int) -> String {
        if !isChinese && count == 1 { return "1 echo" }
        return String(format: self["%d echoes"], count)
    }
    private static let chinese: [String: String] = [
        "Temet Nosce": "认识你自己。",
        "Bring a question.\nFour oracles. Four ways to see.": "带着疑问而来。\n四位先知，四种看见。",
        "Come.": "进来吧。",
        "Skip": "跳过",
        "ARTWORK PREVIEW": "画面预览",
        "You've already made your choice.": "你早已做出了选择。",
        "Leave a question in the quiet.": "问问石头吧。",
        "What are you so certain of?": "你真的确定吗？",
        "What shall we make wonderfully strange?": "你是一个大土豆！",
        "Now, discover why.": "现在，试着理解为什么。",
        "A thought, held in silence.": "岁月会给你答案。",
        "An unexpected turn.": "想想，再想想。",
        "A little sense. A little nonsense.": "还是勺子？牙刷？烤面包机？",
        "About ": "关于 ",
        "Choose character. %@ selected": "选择先知，当前为 %@",
        "Settings": "设置",
        "PREVIEW · SAMPLE REPLIES": "预览 · 示例回答",
        "Listening for an echo…": "静候回响…",
        "Sample reply": "示例回答",
        "Earlier reply": "上一条回答",
        "Later reply": "下一条回答",
        "Back to latest": "回到最新",
        "%d echoes": "%d 道回响",
        "Stop listening": "停止聆听",
        "Speak your question": "说出你的问题",
        "Ask": "提问",
        "Your question": "你的问题",
        "Tap to type. Touch and hold to speak, then release to send.": "轻点输入文字，长按说话，松开发送。",
        "Send question": "发送问题",
        "Reply language": "回答语言",
        "Language": "语言",
        "Experience": "体验",
        "Depth & dream effects": "景深与梦幻效果",
        "Spatial preview": "空间效果预览",
        "Connection": "连接",
        "Sample replies": "示例回答",
        "API key saved on this device": "密钥已保存在此设备上",
        "Add your API key to begin": "添加 API 密钥以开始",
        "Replace API key": "更换 API 密钥",
        "API key": "API 密钥",
        "Replace key": "更换密钥",
        "Save key": "保存密钥",
        "Delete key": "删除密钥",
        "Clear this conversation": "清除此对话",
        "Questions and replies stay in memory for this session. Your API key is stored in this device’s Keychain; character and display preferences are saved locally.": "问题与回答仅保留在本次会话中。API 密钥存放在此设备的钥匙串中；先知选择与显示偏好保存在本地。",
        "Artwork": "画面素材",
        "Character artwork is installed. Entry dissolves into The Oracle when the curtain video is unavailable.": "先知画面已就绪。门帘视频不可用时，将以叠化过渡进入 The Oracle。",
        "Character images and the curtain video are loaded from the app’s media folder. Missing images show a development scene.": "先知画面与门帘视频来自应用内的素材。图片缺失时，将显示占位场景。",
        "Couldn’t update API key": "无法更新 API 密钥",
        "OK": "好",
        "Done": "完成",
        "Cancel": "取消",
        "Clear this character’s conversation?": "清除这位先知的对话？",
        "Clear conversation": "清除对话",
        "Character": "先知",
        "Hide controls": "隐藏控制项",
        "Show controls": "显示控制项",
        "Horizontal tilt": "水平倾斜",
        "Vertical tilt": "垂直倾斜",
        "Center": "回正",
        "Move the sliders to inspect the same depth effect used when tilting your phone.": "拖动滑块，预览倾斜手机时的景深效果。",
        "Preparing scene depth…": "正在准备场景景深…",
        "Continuous scene depth": "连续场景景深",
        "Still image": "静态画面",
        "Artwork missing": "缺少画面素材",
        "Dedicated artwork is not installed. Development preview only.": "尚未安装专属画面，当前为占位预览。",
        "No matching depth data. The complete image stays still.": "没有匹配的深度数据，画面保持静止。",
        "One connected scene • original contact edges and shadows": "完整连续的场景 · 保留原有接触边缘与阴影",
        "Speech permission is off.": "尚未开启语音权限。",
        "Speech is unavailable.": "语音识别暂不可用。",
        "Microphone unavailable.": "麦克风暂不可用。",
        "The reply could not be read. Please try again.": "无法读取回答，请重试。",
        "The echo was interrupted. Your question is still here.": "回响中断了，你的问题仍在这里。",
        "We couldn’t receive an answer. Check your connection and try again.": "未能收到回答，请检查网络后重试。",
        "Add a valid HTTPS service address in Settings.": "请在设置中添加有效的 HTTPS 服务地址。",
        "Enter a valid API key without spaces.": "请输入有效的 API 密钥，不要包含空格。",
        "The key could not be accessed securely. Please try again.": "无法安全访问密钥，请重试。",
    ]
}

/// System Latin serif plus an explicit Chinese serif; custom fonts retain Dynamic Type scaling.
enum OracleTypography {
    static let chineseSerifName = "NotoSerifCJKsc-Regular"
    static func serif(_ style: Font.TextStyle, text: String) -> Font {
        guard ReplyText.containsChinese(text) else { return .system(style, design: .serif) }
        let size: CGFloat
        switch style {
        case .largeTitle: size = 34
        case .title: size = 28
        case .title2: size = 22
        case .title3: size = 20
        case .headline, .body: size = 17
        case .subheadline: size = 15
        case .callout: size = 16
        case .footnote: size = 13
        case .caption: size = 12
        case .caption2: size = 11
        @unknown default: size = 17
        }
        return .custom(chineseSerifName, size: size, relativeTo: style)
    }
}
