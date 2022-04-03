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
    Chat_ServerPrivateMessage(player, "\x1b[37m 1.\x1b[0m Keep it chill. Competitive talk is fine but aggrevation and racism will not be tolerated.", whisper)
    Chat_ServerPrivateMessage(player, "\x1b[37m 2.\x1b[0m Do not spam the chat. This includes spam mods and macros.", whisper)
    Chat_ServerPrivateMessage(player, "\x1b[37m 3.\x1b[0m Cheating or working around the game's controls is banned, including movement macros.", whisper)
    Chat_ServerPrivateMessage(player, "Report rule breakers on the Northstar Discord - \x1b[94mdiscord.gg/northstar", whisper)
}

void function SendHelpToPlayer(entity player, bool whisper) {
    Chat_ServerPrivateMessage(player, "\x1b[93mChat commands:", whisper)
    Chat_ServerPrivateMessage(player, "\x1b[92m /rules\x1b[0m - view the rules again.", whisper)
    Chat_ServerPrivateMessage(player, "\x1b[92m /help\x1b[0m - view the chat commands again.", whisper)
    Chat_ServerPrivateMessage(player, "\x1b[92m /skip\x1b[0m - vote to skip the current map.", whisper)
}

void function HandleClientConnected(entity player) {
    Chat_ServerPrivateMessage(player, "\x1b[97mWelcome to \x1b[91mYour Local Bunnings\x1b[97m, where lowest prices are just the beginning.", false)
    Chat_ServerPrivateMessage(player, "", false)
    SendRulesToPlayer(player, false)
    SendHelpToPlayer(player, false)
    Chat_ServerPrivateMessage(player, "", false)
    Chat_ServerPrivateMessage(player, "Questions? Contact \x1b[94mcpdt#5830\x1b[0m on Discord.", false)
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

    print("ChatMessage: " + message.player.GetPlayerName() + "(" + message.player.GetUID() + ") " + message.message)

    return message
}

void function InitChat() {
    AddCallback_OnClientConnected(HandleClientConnected)
    AddCallback_OnReceivedSayTextMessage(HandleReceivedChat)
}
