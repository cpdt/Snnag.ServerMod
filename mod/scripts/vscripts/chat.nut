global function InitChat

array<string> playerVotedIds = []
bool isSkipping = false

void function SkipMapThread() {
    if (isSkipping) {
        return
    }

    isSkipping = true
    Chat_ServerBroadcast("\x1b[92mSkipping this map in 5 seconds...")
    wait 5
    SetServerVar("gameEndTime", 1.0)
    playerVotedIds.clear()
    isSkipping = false
}

void function VoteToSkip(entity player) {
    if (IsLobby()) {
        return
    }

    if (playerVotedIds.find(player.GetUID()) != -1) {
        Chat_ServerPrivateMessage(player, "You have already voted to skip.", true)
        return
    }

    playerVotedIds.append(player.GetUID())
    int requiredVoteCount = ceil(GetPlayerArray().len() / 2.0).tointeger()

    Chat_ServerBroadcast(playerVotedIds.len() + "/" + requiredVoteCount + " players have voted to skip this map. Vote with \x1b[92m/skip\x1b[0m in chat.")

    if (playerVotedIds.len() >= requiredVoteCount) {
        thread SkipMapThread()
    }
}

void function SendRulesToPlayer(entity player, bool whisper) {
    Chat_ServerPrivateMessage(player, "\x1b[93mRules:", whisper)
    Chat_ServerPrivateMessage(player, "\x1b[33m 1. Keep it chill. Competitive talk is fine but aggrevation and slurs will not be tolerated.", whisper)
    Chat_ServerPrivateMessage(player, "\x1b[33m 2. Do not spam the chat. This includes spam mods and macros.", whisper)
    Chat_ServerPrivateMessage(player, "\x1b[33m 3. Cheating or working around the game's controls is banned, including movement macros.", whisper)
    Chat_ServerPrivateMessage(player, "Report rule breakers on the Northstar Discord - \x1b[94mdiscord.gg/northstar", whisper)
}

void function SendHelpToPlayer(entity player, bool whisper) {
    Chat_ServerPrivateMessage(player, "\x1b[93mChat commands:", whisper)
    Chat_ServerPrivateMessage(player, "\x1b[92m /rules\x1b[0m - view the rules again.", whisper)
    Chat_ServerPrivateMessage(player, "\x1b[92m /help\x1b[0m - view the chat commands again.", whisper)
    Chat_ServerPrivateMessage(player, "\x1b[92m /skip\x1b[0m - vote to skip the current map.", whisper)
    Chat_ServerPrivateMessage(player, "\x1b[92m /strikes\x1b[0m - view any strikes you have.", whisper)
}

void function SendStrikesToPlayer(entity player, bool whisper) {
    if (player.GetUID() in ChatWarnList) {
        int warnCount = ChatWarnList[player.GetUID()].len()
        string warnCountStr = ""
        
        if (warnCount == 1) {
            warnCountStr = "1 strike"
        } else {
            warnCountStr = warnCount + " strikes"
        }

        Chat_ServerPrivateMessage(player, "\x1b[93mYou have " + warnCountStr + ". \x1b[91mYou will be banned if you reach 3 strikes. \x1b[93mPlease carefully read the rules again.", whisper)
    } else {
        Chat_ServerPrivateMessage(player, "You don't have any strikes. Thanks for keeping your local Bunnings a friendly place!", whisper)
    }
}

void function HandleClientConnected(entity player) {
    Chat_ServerPrivateMessage(player, "\x1b[97mWelcome to \x1b[95mYour Local Bunnings\x1b[97m, where lowest prices are just the beginning.", false)
    SendRulesToPlayer(player, false)
    Chat_ServerPrivateMessage(player, "View available chat commands with \x1b[92m/help\x1b[0m. Questions? Contact \x1b[94mcpdt#5830\x1b[0m on Discord.", false)

    if (player.GetUID() in ChatWarnList) {
        Chat_ServerPrivateMessage(player, "", false)
        SendStrikesToPlayer(player, false)
    }
}

ClServer_MessageStruct function HandleReceivedChat(ClServer_MessageStruct message) {
    if (message.message == "/rules") {
        SendRulesToPlayer(message.player, false)

        message.shouldBlock = true
        return message
    }
    if (message.message == "/help") {
        SendHelpToPlayer(message.player, false)

        message.shouldBlock = true
        return message
    }
    if (message.message == "/skip") {
        VoteToSkip(message.player)

        message.shouldBlock = true
        return message
    }
    if (message.message == "/strikes") {
        SendStrikesToPlayer(message.player, false)

        message.shouldBlock = true
        return message
    }

    if (ChatShadowBanList.find(message.player.GetUID()) != -1) {
        print("ShadowBanned ChatMessage: " + message.player.GetPlayerName() + "(" + message.player.GetUID() + ") " + message.message)
        Chat_Impersonate(message.player, message.message, message.isTeam)

        message.message = ""
        message.shouldBlock = true
        return message
    }

    if (ChatBanList.find(message.player.GetUID()) != -1) {
        print("Banned ChatMessage: " + message.player.GetPlayerName() + "(" + message.player.GetUID() + ") " + message.message)

        Chat_ServerPrivateMessage(message.player, "\x1b[91mYou have been banned from chat.", false)

        message.message = ""
        message.shouldBlock = true
        return message
    }

    print("ChatMessage: " + message.player.GetPlayerName() + "(" + message.player.GetUID() + ") " + message.message)

    return message
}

void function InitChat() {
    AddCallback_OnClientConnected(HandleClientConnected)
    AddCallback_OnReceivedSayTextMessage(HandleReceivedChat)
}
