<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
Integer roleId = (Integer) session.getAttribute("role_id");
Integer userId = (Integer) session.getAttribute("user_id");
String fullName = (String) session.getAttribute("fullName");

if(roleId == null || roleId != 1){
    response.sendRedirect("login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>TIP SC – Messages</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet" />
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --black: #000;
            --white: #fff;
            --topbar: #e5e5e5;
            --active-tab: #555;
            --light-gray: #f5f5f5;
            --border-gray: #ddd;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--white);
            min-width: 1440px;
            display: flex;
            flex-direction: column;
            height: 100vh;
        }

        .topbar {
            background: var(--topbar);
            height: 80px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 21px;
            border-bottom: 1px solid var(--border-gray);
        }
        .topbar-left { display: flex; align-items: center; gap: 0; height: 100%; }
        .logo { display: flex; align-items: center; }
        .logo img { width: 48px; height: 48px; }
        .logo-brand { font-size: 32px; font-weight: 600; color: var(--black); letter-spacing: -0.32px; margin-right: 20px; }
        .nav-tab {
            height: 100%;
            display: flex;
            align-items: center;
            padding: 0 11px;
            font-size: 25px;
            font-weight: 600;
            color: var(--black);
            cursor: pointer;
            letter-spacing: -0.25px;
        }
        .nav-tab.active { background: var(--active-tab); color: var(--white); }
        .nav-tab:hover { background: #ddd; }
        .topbar-account { display: flex; align-items: center; gap: 8px; }
        .topbar-account img { width: 48px; height: 48px; }
        .topbar-account span { font-size: 32px; font-weight: 600; letter-spacing: -0.32px; }

        .messages-container {
            display: flex;
            flex: 1;
            overflow: hidden;
        }

        .sidebar {
            width: 300px;
            border-right: 1px solid var(--border-gray);
            display: flex;
            flex-direction: column;
            background: var(--light-gray);
        }
        .sidebar-header {
            padding: 20px;
            border-bottom: 1px solid var(--border-gray);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .sidebar-title {
            font-size: 20px;
            font-weight: 600;
            letter-spacing: -0.2px;
        }
        .new-msg-btn {
            background: var(--black);
            color: var(--white);
            border: none;
            border-radius: 4px;
            padding: 6px 12px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
        }
        .new-msg-btn:hover { background: #333; }

        .conversations-list {
            flex: 1;
            overflow-y: auto;
            list-style: none;
        }
        .conversation-item {
            padding: 15px;
            border-bottom: 1px solid var(--border-gray);
            cursor: pointer;
            transition: background 0.2s;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .conversation-item:hover { background: #e8e8e8; }
        .conversation-item.active { background: var(--white); border-left: 4px solid var(--black); padding-left: 11px; }
        .conversation-content { flex: 1; }
        .conversation-name {
            font-size: 16px;
            font-weight: 600;
            letter-spacing: -0.16px;
            color: var(--black);
        }
        .conversation-preview {
            font-size: 13px;
            color: #666;
            margin-top: 4px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .conversation-time {
            font-size: 12px;
            color: #999;
            margin-top: 4px;
        }
        .delete-conv-btn {
            background: #d32f2f;
            color: white;
            border: none;
            border-radius: 4px;
            padding: 4px 8px;
            font-size: 12px;
            cursor: pointer;
            margin-left: 10px;
            display: none;
        }
        .conversation-item:hover .delete-conv-btn { display: block; }
        .delete-conv-btn:hover { background: #b71c1c; }

        .empty-state {
            padding: 40px 20px;
            text-align: center;
            color: #999;
        }
        .empty-state-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 10px;
            color: var(--black);
        }
        .empty-state-text {
            font-size: 14px;
            margin-bottom: 15px;
        }

        .chat-area {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: var(--white);
        }

        .chat-header {
            padding: 20px;
            border-bottom: 1px solid var(--border-gray);
            background: var(--light-gray);
        }
        .chat-header-name {
            font-size: 20px;
            font-weight: 600;
            letter-spacing: -0.2px;
        }
        .chat-header-email {
            font-size: 14px;
            color: #666;
            margin-top: 2px;
        }

        .messages-box {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .message {
            display: flex;
            margin-bottom: 10px;
        }
        .message.sent { justify-content: flex-end; }
        .message.received { justify-content: flex-start; }

        .message-bubble {
            max-width: 60%;
            padding: 12px 16px;
            border-radius: 12px;
            word-wrap: break-word;
            word-break: break-word;
        }
        .message.sent .message-bubble {
            background: var(--black);
            color: var(--white);
        }
        .message.received .message-bubble {
            background: var(--light-gray);
            color: var(--black);
        }

        .message-time {
            font-size: 12px;
            color: #999;
            margin-top: 4px;
            text-align: right;
        }
        .message.received .message-time { text-align: left; }

        .chat-input-area {
            padding: 20px;
            border-top: 1px solid var(--border-gray);
            background: var(--white);
            display: flex;
            gap: 10px;
        }
        .chat-input {
            flex: 1;
            border: 1px solid var(--border-gray);
            border-radius: 8px;
            padding: 12px;
            font-family: 'Inter', sans-serif;
            font-size: 16px;
            resize: none;
            height: 45px;
            outline: none;
        }
        .chat-input:focus { outline: 1px solid var(--black); }
        .chat-input:disabled {
            background: #f0f0f0;
            color: #999;
            cursor: not-allowed;
        }
        .send-btn {
            background: var(--black);
            color: var(--white);
            border: none;
            border-radius: 8px;
            padding: 0 20px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
        }
        .send-btn:hover:not(:disabled) { background: #333; }
        .send-btn:disabled { background: #ccc; cursor: not-allowed; }

        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.4);
        }
        .modal.active { display: block; }
        .modal-content {
            background-color: var(--white);
            margin: 10% auto;
            padding: 30px;
            border: 1px solid var(--border-gray);
            border-radius: 8px;
            width: 400px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .modal-title {
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 20px;
            letter-spacing: -0.22px;
        }
        .modal-input {
            width: 100%;
            padding: 12px;
            border: 1px solid var(--border-gray);
            border-radius: 6px;
            font-family: 'Inter', sans-serif;
            font-size: 16px;
            margin-bottom: 20px;
            outline: none;
        }
        .modal-input:focus { outline: 1px solid var(--black); }
        .modal-error {
            color: #d32f2f;
            font-size: 14px;
            margin-bottom: 15px;
            display: none;
        }
        .modal-error.show { display: block; }
        .modal-buttons {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }
        .modal-btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
        }
        .modal-btn-primary {
            background: var(--black);
            color: var(--white);
        }
        .modal-btn-primary:hover { background: #333; }
        .modal-btn-primary:disabled { background: #ccc; cursor: not-allowed; }
        .modal-btn-secondary {
            background: var(--light-gray);
            color: var(--black);
            border: 1px solid var(--border-gray);
        }
        .modal-btn-secondary:hover { background: #e8e8e8; }

        .select-conversation-placeholder {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: #999;
        }
        .select-conversation-placeholder-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 10px;
            color: var(--black);
        }
    </style>
</head>
<body>

<header class="topbar">
    <div class="topbar-left">
        <div class="logo">
            <img src="https://www.figma.com/api/mcp/asset/bb6eba5f-daae-4d2c-b20a-3e7943a0549d" alt="logo" />
            <span class="logo-brand">TIP SC</span>
        </div>
        <div class="nav-tab" onclick="window.location.href='student_dashboard.jsp'">My Complaints</div>
        <div class="nav-tab" onclick="window.location.href='submit_complaint.jsp'">Submit Complaint</div>
        <div class="nav-tab active">Message</div>
    </div>
    <div class="topbar-account">
        <img src="https://www.figma.com/api/mcp/asset/92d22bc0-450b-4022-8844-485488d13931" alt="account" />
        <span><%= fullName %></span>
    </div>
</header>

<div class="messages-container">
    <div class="sidebar">
        <div class="sidebar-header">
            <div class="sidebar-title">Messages</div>
            <button class="new-msg-btn" onclick="openNewMessageModal()">+ New</button>
        </div>
        <ul class="conversations-list" id="conversationsList">
            <div class="empty-state">
                <div class="empty-state-title">No Conversations</div>
                <div class="empty-state-text">Start a new message by clicking the + New button</div>
            </div>
        </ul>
    </div>

    <div class="chat-area">
        <div id="chatContainer" style="display: none; flex: 1; display: flex; flex-direction: column;">
            <div class="chat-header">
                <div class="chat-header-name" id="chatHeaderName">Select a conversation</div>
                <div class="chat-header-email" id="chatHeaderEmail"></div>
            </div>
            <div class="messages-box" id="messagesBox"></div>
            <div class="chat-input-area">
                <textarea class="chat-input" id="messageInput" placeholder="Type a message..." disabled></textarea>
                <button class="send-btn" id="sendBtn" onclick="sendMessage()" disabled>Send</button>
            </div>
        </div>
        <div id="selectConversationPlaceholder" style="flex: 1; display: flex; align-items: center; justify-content: center;">
            <div class="select-conversation-placeholder">
                <div class="select-conversation-placeholder-title">No Conversation Selected</div>
                <p>Select a conversation to start messaging or create a new one</p>
            </div>
        </div>
    </div>
</div>

<div id="newMessageModal" class="modal">
    <div class="modal-content">
        <div class="modal-title">Start New Chat</div>
        <input type="email" class="modal-input" id="recipientEmail" placeholder="Enter recipient's email address" />
        <div class="modal-error" id="modalError"></div>
        <div class="modal-buttons">
            <button class="modal-btn modal-btn-secondary" onclick="closeNewMessageModal()">Cancel</button>
            <button class="modal-btn modal-btn-primary" id="startChatBtn" onclick="startNewChat()">Start Chat</button>
        </div>
    </div>
</div>

<script>
    let currentConversations = [];
    let currentChatUserId = null;
    let currentConversationId = null;
    let autoRefreshInterval = null;

    const currentUserId = <%= userId %>;

    // Load conversations on page load
    window.addEventListener('load', function() {
        console.log('Page loaded for user: ' + currentUserId);
        loadConversations();
        startAutoRefresh();
    });

    /**
     * Load conversations - empty sidebar if no chats started
     */
    function loadConversations() {
        console.log('Loading conversations...');
        fetch('MessagesServlet?action=getConversations')
            .then(response => {
                console.log('Response status:', response.status);
                if (!response.ok) throw new Error('HTTP ' + response.status);
                return response.json();
            })
            .then(data => {
                console.log('Conversations loaded:', data);
                // ✅ FIX: Use data.data (correct response structure)
                currentConversations = data.data || [];
                displayConversations();
            })
            .catch(error => console.error('Error loading conversations:', error));
    }

    /**
     * Display conversations - NO AUTO-POPULATION
     */
    function displayConversations() {
        const list = document.getElementById('conversationsList');
        list.innerHTML = '';

        if (!currentConversations || currentConversations.length === 0) {
            list.innerHTML = '<div class="empty-state"><div class="empty-state-title">No Conversations</div><div class="empty-state-text">Start a new message by clicking the + New button</div></div>';
            console.log('No conversations to display - sidebar empty');
            return;
        }

        currentConversations.forEach((conv) => {
            const item = document.createElement('li');
            item.className = 'conversation-item';
            item.id = 'conv-' + conv.otherUserId;
            
            const lastMessageTime = conv.lastMessageAt ? new Date(conv.lastMessageAt).toLocaleDateString() : '';
            const lastMessage = conv.lastMessage ? (conv.lastMessage.length > 50 ? conv.lastMessage.substring(0, 47) + '...' : conv.lastMessage) : 'No messages yet';
            
            const content = document.createElement('div');
            content.className = 'conversation-content';
            
            const nameDiv = document.createElement('div');
            nameDiv.className = 'conversation-name';
            nameDiv.textContent = conv.fullName;
            
            const previewDiv = document.createElement('div');
            previewDiv.className = 'conversation-preview';
            previewDiv.textContent = lastMessage;
            
            const timeDiv = document.createElement('div');
            timeDiv.className = 'conversation-time';
            timeDiv.textContent = lastMessageTime;
            
            content.appendChild(nameDiv);
            content.appendChild(previewDiv);
            content.appendChild(timeDiv);
            
            // Delete button for each conversation
            const deleteBtn = document.createElement('button');
            deleteBtn.className = 'delete-conv-btn';
            deleteBtn.textContent = 'Delete';
            deleteBtn.onclick = function(e) {
                e.stopPropagation();
                deleteConversation(conv.conversationId);
            };
            
            item.appendChild(content);
            item.appendChild(deleteBtn);
            
            // Click to open conversation
            item.addEventListener('click', function() {
                openConversation(conv.otherUserId, conv.fullName, conv.email, conv.conversationId);
            });
            
            list.appendChild(item);
        });

        console.log('Displayed ' + currentConversations.length + ' conversations');
    }

    /**
     * Delete conversation with confirmation
     */
    function deleteConversation(conversationId) {
    if (!confirm('Are you sure you want to delete this conversation? This will remove all messages.')) {
        return;
    }

    const params = new URLSearchParams();
    params.append('action', 'deleteConversation');
    params.append('conversationId', conversationId);

    fetch('MessagesServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params.toString()
    })
    .then(response => {
        console.log('Delete response status:', response.status);
        if (!response.ok) throw new Error('HTTP ' + response.status);
        return response.json();
    })
    .then(data => {
        console.log('Delete response:', data);
        if (data.status === 'success') {
            if (currentConversationId === conversationId) {
                currentChatUserId = null;
                currentConversationId = null;
                document.getElementById('selectConversationPlaceholder').style.display = 'flex';
                document.getElementById('chatContainer').style.display = 'none';
            }
            loadConversations();
        } else {
            alert('Error: ' + data.message);
        }
    })
    .catch(error => console.error('Error deleting conversation:', error));
} 
    function openConversation(userId, fullName, email, conversationId) {
        currentChatUserId = userId;
        currentConversationId = conversationId;
        
        console.log('Opening conversation with user ' + userId);
        
        // Show chat container
        document.getElementById('selectConversationPlaceholder').style.display = 'none';
        document.getElementById('chatContainer').style.display = 'flex';
        document.getElementById('chatHeaderName').textContent = fullName;
        document.getElementById('chatHeaderEmail').textContent = email;

        // Enable message input ONLY when conversation selected
        const messageInput = document.getElementById('messageInput');
        const sendBtn = document.getElementById('sendBtn');
        messageInput.disabled = false;
        sendBtn.disabled = false;

        loadChatHistory();

        // Mark as active in sidebar
        document.querySelectorAll('.conversation-item').forEach(item => {
            item.classList.remove('active');
        });
        
        const currentItem = document.getElementById('conv-' + userId);
        if (currentItem) {
            currentItem.classList.add('active');
        }
    }

    /**
     * Load chat history for selected conversation
     */
    function loadChatHistory() {
        fetch('MessagesServlet?action=getMessages&conversationId=' + currentConversationId)
            .then(response => {
                console.log('Chat history response status:', response.status);
                if (!response.ok) throw new Error('HTTP ' + response.status);
                return response.json();
            })
            .then(data => {
                console.log('Chat history loaded:', data);
                displayChatMessages(data.messages || []);
            })
            .catch(error => console.error('Error loading chat history:', error));
    }

    /**
     * Display all messages in conversation
     */
    function displayChatMessages(messages) {
        const box = document.getElementById('messagesBox');
        box.innerHTML = '';

        if (!messages || messages.length === 0) {
            box.innerHTML = '<p style="color: #999; text-align: center; margin-top: 20px;">No messages yet. Start the conversation!</p>';
            return;
        }

        messages.forEach(msg => {
            const isSent = msg.isMine;

            const div = document.createElement('div');
            div.className = 'message ' + (isSent ? 'sent' : 'received');

            const bubble = document.createElement('div');
            bubble.className = 'message-bubble';
            bubble.textContent = msg.text;

            const time = document.createElement('div');
            time.className = 'message-time';
            time.textContent = new Date(msg.sentAt).toLocaleTimeString();

            div.appendChild(bubble);
            div.appendChild(time);
            box.appendChild(div);
        });

        box.scrollTop = box.scrollHeight;
    }

    /**
     * Send message - button only works when conversation selected
     */
    function sendMessage() {
    const input = document.getElementById('messageInput');
    const messageText = input.value.trim();
    const sendBtn = document.getElementById('sendBtn');

    if (!messageText || !currentConversationId) {
        alert('Select a conversation first');
        return;
    }

    sendBtn.disabled = true;

    const params = new URLSearchParams();
    params.append('action', 'sendMessage');
    params.append('conversationId', currentConversationId);
    params.append('message', messageText);

    fetch('MessagesServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params.toString()
    })
    .then(response => {
        console.log('Send message response status:', response.status);
        if (!response.ok) throw new Error('HTTP ' + response.status);
        return response.json();
    })
    .then(data => {
        console.log('Send message response:', data);
        if (data.status === 'success') {
            input.value = '';
            loadChatHistory();
            loadConversations();
        } else {
            alert('Error: ' + data.message);
        }
        sendBtn.disabled = false;
    })
    .catch(error => {
        console.error('Error sending message:', error);
        alert('Failed to send message');
        sendBtn.disabled = false;
    });
}
    function openNewMessageModal() {
        document.getElementById('newMessageModal').classList.add('active');
        document.getElementById('modalError').textContent = '';
        document.getElementById('modalError').classList.remove('show');
        document.getElementById('recipientEmail').value = '';
        document.getElementById('recipientEmail').focus();
    }

    function closeNewMessageModal() {
        document.getElementById('newMessageModal').classList.remove('active');
    }

    /**
     * Start new chat with email validation
     */
    function startNewChat() {
    const email = document.getElementById('recipientEmail').value.trim();
    const errorDiv = document.getElementById('modalError');
    const startChatBtn = document.getElementById('startChatBtn');

    if (!email) {
        errorDiv.textContent = 'Please enter an email address';
        errorDiv.classList.add('show');
        return;
    }

    startChatBtn.disabled = true;

    const params = new URLSearchParams();
    params.append('action', 'startChat');
    params.append('email', email);

    console.log('Starting new chat with email:', email);
    console.log('Sending data:', params.toString());

    fetch('MessagesServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params.toString()
    })
    .then(response => {
        console.log('Start chat response status:', response.status);
        if (!response.ok) {
            return response.text().then(text => {
                console.error('Server response:', text);
                throw new Error('HTTP ' + response.status + ': ' + text);
            });
        }
        return response.json();
    })
    .then(data => {
        console.log('Start chat response:', data);
        if (data.status === 'success') {
            closeNewMessageModal();
            loadConversations();

            setTimeout(() => {
                openConversation(
                    data.otherUserId,
                    data.fullName || (data.firstName + " " + data.lastName),
                    email,
                    data.conversationId
                );
            }, 200);
        } else {
            errorDiv.textContent = data.message || 'Failed to start chat';
            errorDiv.classList.add('show');
        }

        startChatBtn.disabled = false;
    })
    .catch(error => {
        console.error('Error starting chat:', error);
        errorDiv.textContent = 'Error: ' + error.message;
        errorDiv.classList.add('show');
        startChatBtn.disabled = false;
    });
}
    function startAutoRefresh() {
        autoRefreshInterval = setInterval(function() {
            if (currentChatUserId) {
                loadChatHistory();
            }
            loadConversations();
        }, 5000);
    }

    window.addEventListener('beforeunload', function() {
        if (autoRefreshInterval) {
            clearInterval(autoRefreshInterval);
        }
    });

    // Allow sending with Enter key
    document.addEventListener('keypress', function(event) {
        if (event.key === 'Enter' && !event.shiftKey && event.target.id === 'messageInput') {
            event.preventDefault();
            sendMessage();
        }
    });

    // Close modal when clicking outside
    window.onclick = function(event) {
        const modal = document.getElementById('newMessageModal');
        if (event.target === modal) {
            closeNewMessageModal();
        }
    };
</script>

</body>
</html>