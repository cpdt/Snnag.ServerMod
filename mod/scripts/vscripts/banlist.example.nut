global array<string> ChatBanList = []
global array<string> ChatShadowBanList = []

global table< string, array< table< string, string > > > ChatWarnList = {
    ["example uid"] = [
        { date = "2022/04/23", reason = "Reason 1" },
        { date = "2022/04/24", reason = "Reason 2" }
    ]
}
