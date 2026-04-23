package util;

import javax.mail.*;
import javax.mail.internet.*;
import java.sql.*;
import java.util.*;

public class MessageUtil {
    
    private static final String FROM_EMAIL = "gonzagafernando077@gmail.com";
    private static final String FROM_PASSWORD = "njomfunsxxdwmwzo";
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    
    /**
     * REQUIREMENT 1: Get all conversations for a user (ONLY conversations that exist)
     * - Empty sidebar if user has never started a chat
     * - Returns conversations that persist across login sessions
     * - Includes inbound messages from other users
     */
    public static List<Map<String, Object>> getConversations(int userId) {
        List<Map<String, Object>> conversations = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection()) {
            
            System.out.println("DEBUG: Getting conversations for user: " + userId);
            
            // Get conversations where user is participant (including inbound messages)
            String sql = "SELECT c.conversation_id, " +
                        "CASE WHEN c.user1_id = ? THEN c.user2_id ELSE c.user1_id END as other_user_id, " +
                        "u.full_name, u.email, c.last_message_at, " +
                        "(SELECT m.message_text FROM messages m WHERE m.conversation_id = c.conversation_id ORDER BY m.sent_at DESC FETCH FIRST 1 ROWS ONLY) as last_message " +
                        "FROM conversations c " +
                        "JOIN users u ON (c.user1_id = ? AND u.user_id = c.user2_id) OR (c.user2_id = ? AND u.user_id = c.user1_id) " +
                        "WHERE c.user1_id = ? OR c.user2_id = ? " +
                        "ORDER BY c.last_message_at DESC NULLS LAST";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            ps.setInt(4, userId);
            ps.setInt(5, userId);
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> conv = new HashMap<>();
                conv.put("conversationId", rs.getInt("conversation_id"));
                conv.put("otherUserId", rs.getInt("other_user_id"));
                conv.put("fullName", rs.getString("full_name"));
                conv.put("email", rs.getString("email"));
                
                Timestamp lastMsgAt = rs.getTimestamp("last_message_at");
                conv.put("lastMessageAt", lastMsgAt != null ? lastMsgAt.toString() : "");
                
                String lastMessage = rs.getString("last_message");
                conv.put("lastMessage", lastMessage != null ? lastMessage : "");
                
                conversations.add(conv);
                System.out.println("DEBUG: Found conversation with " + rs.getString("full_name") + " (Last msg: " + lastMessage + ")");
            }
            
            System.out.println("DEBUG: Total conversations found: " + conversations.size() + " for user " + userId);
            
        } catch (SQLException e) {
            System.err.println("ERROR fetching conversations: " + e.getMessage());
            e.printStackTrace();
        }
        
        return conversations;
    }
    
    /**
     * REQUIREMENT 2: Get message history between two users (for selected conversation)
     * - Retrieves ALL messages in conversation
     * - Used when user clicks on a conversation in sidebar
     */
    public static List<Map<String, Object>> getMessageHistory(int userId1, int userId2) {
        List<Map<String, Object>> messages = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection()) {
            
            System.out.println("DEBUG: Getting message history between " + userId1 + " and " + userId2);
            
            // Get conversation ID (handles both user orders)
            int conversationId = getConversationId(userId1, userId2);
            if (conversationId == -1) {
                System.out.println("DEBUG: No conversation found between " + userId1 + " and " + userId2);
                return messages;
            }
            
            // Get ALL messages in this conversation (not filtered by sender)
            String sql = "SELECT m.message_id, m.conversation_id, m.sender_id, m.receiver_id, m.message_text, m.sent_at " +
                        "FROM messages m " +
                        "WHERE m.conversation_id = ? " +
                        "ORDER BY m.sent_at ASC";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, conversationId);
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> msg = new HashMap<>();
                msg.put("messageId", rs.getInt("message_id"));
                msg.put("conversationId", rs.getInt("conversation_id"));
                msg.put("senderId", rs.getInt("sender_id"));
                msg.put("receiverId", rs.getInt("receiver_id"));
                msg.put("messageText", rs.getString("message_text"));
                
                Timestamp sentAt = rs.getTimestamp("sent_at");
                msg.put("sentAt", sentAt != null ? sentAt.toString() : "");
                
                messages.add(msg);
            }
            
            System.out.println("DEBUG: Found " + messages.size() + " messages in conversation " + conversationId);
            
        } catch (SQLException e) {
            System.err.println("ERROR fetching message history: " + e.getMessage());
            e.printStackTrace();
        }
        
        return messages;
    }
    
    /**
     * Get conversation ID between two users
     * Handles both user orderings (user1 < user2 or user1 > user2)
     */
    private static int getConversationId(int userId1, int userId2) {
        int u1 = Math.min(userId1, userId2);
        int u2 = Math.max(userId1, userId2);
        
        try (Connection conn = DBConnection.getConnection()) {
            
            String sql = "SELECT conversation_id FROM conversations WHERE user1_id = ? AND user2_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, u1);
            ps.setInt(2, u2);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int conversationId = rs.getInt("conversation_id");
                System.out.println("DEBUG: Found conversation " + conversationId + " between " + u1 + " and " + u2);
                return conversationId;
            }
            
        } catch (SQLException e) {
            System.err.println("ERROR fetching conversation ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }
    
    /**
     * REQUIREMENT 3: Save a message to database
     * - Stores message with sender and receiver IDs
     * - Updates conversation timestamp for persistence
     */
    public static boolean saveMessage(int senderId, int conversationId, String messageText) {
        try (Connection conn = DBConnection.getConnection()) {
            
            System.out.println("DEBUG: Saving message from " + senderId + " in conversation " + conversationId);
            System.out.println("DEBUG: Message text: " + messageText);
            
            // Get receiver ID from conversation
            String convSql = "SELECT user1_id, user2_id FROM conversations WHERE conversation_id = ?";
            PreparedStatement convPs = conn.prepareStatement(convSql);
            convPs.setInt(1, conversationId);
            ResultSet convRs = convPs.executeQuery();
            
            int receiverId = -1;
            int user1 = -1, user2 = -1;
            if (convRs.next()) {
                user1 = convRs.getInt("user1_id");
                user2 = convRs.getInt("user2_id");
                receiverId = (senderId == user1) ? user2 : user1;
            }
            
            if (receiverId == -1) {
                System.err.println("ERROR: Could not determine receiver for conversation " + conversationId);
                return false;
            }
            
            // Insert message
            String insertMsgSql = "INSERT INTO messages (message_id, conversation_id, sender_id, receiver_id, message_text, sent_at) " +
                                 "VALUES (messages_seq.NEXTVAL, ?, ?, ?, ?, SYSDATE)";
            PreparedStatement ps = conn.prepareStatement(insertMsgSql);
            ps.setInt(1, conversationId);
            ps.setInt(2, senderId);
            ps.setInt(3, receiverId);
            ps.setString(4, messageText);
            int rows = ps.executeUpdate();
            
            if (rows > 0) {
                // Update conversation timestamp for PERSISTENCE
                String updateConvSql = "UPDATE conversations SET last_message_at = SYSDATE WHERE conversation_id = ?";
                PreparedStatement updatePs = conn.prepareStatement(updateConvSql);
                updatePs.setInt(1, conversationId);
                updatePs.executeUpdate();
                
                System.out.println("DEBUG: Message inserted and conversation timestamp updated");
                return true;
            }
            
            return false;
            
        } catch (SQLException e) {
            System.err.println("ERROR saving message: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * REQUIREMENT 4: Get user by email with validation
     * - Validates email exists in database
     * - Only returns students (role_id = 1)
     * - Returns null if not found (for error handling)
     */
    public static Map<String, Object> getUserByEmail(String email) {
        try (Connection conn = DBConnection.getConnection()) {
            
            System.out.println("DEBUG: getUserByEmail - Looking for: " + email);
            
            // Case-insensitive search, only students (role_id = 1)
            String sql = "SELECT user_id, full_name, email, role_id FROM users WHERE LOWER(email) = LOWER(?) AND role_id = 1";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email.trim());
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                int userId = rs.getInt("user_id");
                String fullName = rs.getString("full_name");
                String dbEmail = rs.getString("email");
                
                System.out.println("DEBUG: User found - ID: " + userId + ", Name: " + fullName + ", Email: " + dbEmail);
                
                Map<String, Object> user = new HashMap<>();
                user.put("userId", userId);
                user.put("fullName", fullName);
                user.put("email", dbEmail);
                return user;
            }
            
            System.out.println("DEBUG: No student user found with email: " + email);
            
        } catch (SQLException e) {
            System.err.println("ERROR fetching user by email: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * REQUIREMENT 5: Create OR GET existing conversation
     * - Controlled initialization: only via "Start New Chat" button
     * - Returns conversation ID for use in saveMessage
     * - Handles both user orderings consistently
     */
    public static int createOrGetConversation(int userId1, int userId2) {
        int u1 = Math.min(userId1, userId2);
        int u2 = Math.max(userId1, userId2);
        
        try (Connection conn = DBConnection.getConnection()) {
            
            System.out.println("DEBUG: Creating/Getting conversation between " + u1 + " and " + u2);
            
            // Check if conversation exists
            String checkSql = "SELECT conversation_id FROM conversations WHERE user1_id = ? AND user2_id = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, u1);
            checkPs.setInt(2, u2);
            
            ResultSet rs = checkPs.executeQuery();
            if (rs.next()) {
                int conversationId = rs.getInt("conversation_id");
                System.out.println("DEBUG: Conversation already exists with ID: " + conversationId);
                return conversationId;
            }
            
            // Create new conversation only if it doesn't exist
            String insertSql = "INSERT INTO conversations (conversation_id, user1_id, user2_id, last_message_at) " +
                             "VALUES (conversations_seq.NEXTVAL, ?, ?, NULL)";
            PreparedStatement insertPs = conn.prepareStatement(insertSql);
            insertPs.setInt(1, u1);
            insertPs.setInt(2, u2);
            int rows = insertPs.executeUpdate();
            
            if (rows > 0) {
                // Get the newly created conversation ID
                checkPs = conn.prepareStatement(checkSql);
                checkPs.setInt(1, u1);
                checkPs.setInt(2, u2);
                rs = checkPs.executeQuery();
                
                if (rs.next()) {
                    int conversationId = rs.getInt("conversation_id");
                    System.out.println("DEBUG: New conversation created with ID: " + conversationId);
                    return conversationId;
                }
            }
            
        } catch (SQLException e) {
            System.err.println("ERROR creating conversation: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }
    
    /**
     * REQUIREMENT 6: Delete conversation and wipe message history
     * - Deletes ALL messages in conversation
     * - Deletes the conversation itself
     * - Verifies user owns this conversation before deletion
     */
    public static boolean deleteConversation(int conversationId, int userId) {
        try (Connection conn = DBConnection.getConnection()) {
            
            System.out.println("DEBUG: Deleting conversation " + conversationId + " for user " + userId);
            
            // Verify user owns this conversation
            String verifySql = "SELECT user1_id, user2_id FROM conversations WHERE conversation_id = ?";
            PreparedStatement verifyPs = conn.prepareStatement(verifySql);
            verifyPs.setInt(1, conversationId);
            ResultSet verifyRs = verifyPs.executeQuery();
            
            if (!verifyRs.next()) {
                System.err.println("ERROR: Conversation not found");
                return false;
            }
            
            int user1 = verifyRs.getInt("user1_id");
            int user2 = verifyRs.getInt("user2_id");
            
            // Security check: only conversation participants can delete
            if (userId != user1 && userId != user2) {
                System.err.println("ERROR: User " + userId + " does not own this conversation");
                return false;
            }
            
            // Delete messages first (cascade handled by DB constraints)
            String deleteMsgSql = "DELETE FROM messages WHERE conversation_id = ?";
            PreparedStatement deleteMsgPs = conn.prepareStatement(deleteMsgSql);
            deleteMsgPs.setInt(1, conversationId);
            int msgRows = deleteMsgPs.executeUpdate();
            System.out.println("DEBUG: Deleted " + msgRows + " messages");
            
            // Delete conversation
            String deleteConvSql = "DELETE FROM conversations WHERE conversation_id = ?";
            PreparedStatement deleteConvPs = conn.prepareStatement(deleteConvSql);
            deleteConvPs.setInt(1, conversationId);
            int convRows = deleteConvPs.executeUpdate();
            
            System.out.println("DEBUG: Deleted conversation " + conversationId);
            return convRows > 0;
            
        } catch (SQLException e) {
            System.err.println("ERROR deleting conversation: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Delete all messages and conversations for a user (account deletion)
     */
    public static boolean deleteUserMessages(int userId) {
        try (Connection conn = DBConnection.getConnection()) {
            
            System.out.println("DEBUG: Deleting all messages for user: " + userId);
            
            // Delete messages where user is sender or receiver
            String deleteMsgSql = "DELETE FROM messages WHERE sender_id = ? OR receiver_id = ?";
            PreparedStatement deleteMsgPs = conn.prepareStatement(deleteMsgSql);
            deleteMsgPs.setInt(1, userId);
            deleteMsgPs.setInt(2, userId);
            int msgDeleted = deleteMsgPs.executeUpdate();
            
            // Delete conversations where user is participant
            String deleteConvSql = "DELETE FROM conversations WHERE user1_id = ? OR user2_id = ?";
            PreparedStatement deleteConvPs = conn.prepareStatement(deleteConvSql);
            deleteConvPs.setInt(1, userId);
            deleteConvPs.setInt(2, userId);
            int convDeleted = deleteConvPs.executeUpdate();
            
            System.out.println("DEBUG: Deleted " + msgDeleted + " messages and " + convDeleted + " conversations");
            return true;
            
        } catch (SQLException e) {
            System.err.println("ERROR deleting user messages: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Send email notification
     */
    public static boolean sendMessageNotificationEmail(String recipientEmail, String senderName, String messagePreview) {
        try {
            String subject = "New Message from " + senderName + " - SCMS";
            
            String preview = messagePreview.length() > 100 ? 
                           messagePreview.substring(0, 100) + "..." : 
                           messagePreview;
            
            String htmlBody = "<html>" +
                    "<body style='font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;'>" +
                    "<div style='background-color: white; padding: 30px; border-radius: 8px; max-width: 500px; margin: 0 auto;'>" +
                    "<h2 style='color: #333;'>New Message Received</h2>" +
                    "<p style='color: #666;'><strong>From:</strong> " + senderName + "</p>" +
                    "<div style='background-color: #f9f9f9; padding: 15px; border-left: 4px solid #007bff; margin: 20px 0;'>" +
                    "<p style='color: #333; margin: 0;'>" + preview + "</p>" +
                    "</div>" +
                    "<p style='color: #666;'><a href='messages.jsp' style='color: #007bff; text-decoration: none; font-weight: bold;'>View Full Message</a></p>" +
                    "<hr style='border: none; border-top: 1px solid #ddd; margin-top: 30px;'/>" +
                    "<p style='color: #999; font-size: 12px;'>SCMS System</p>" +
                    "</div>" +
                    "</body>" +
                    "</html>";
            
            return sendHtmlEmail(recipientEmail, subject, htmlBody);
            
        } catch (Exception e) {
            System.err.println("ERROR sending message notification: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Helper method to send HTML email
     */
    private static boolean sendHtmlEmail(String toEmail, String subject, String htmlBody) {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.starttls.required", "true");
            props.put("mail.smtp.ssl.protocols", "TLSv1.2");
            
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, FROM_PASSWORD);
                }
            });
            
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setContent(htmlBody, "text/html; charset=utf-8");
            
            Transport.send(message);
            System.out.println("Message notification email sent to: " + toEmail);
            return true;
            
        } catch (MessagingException e) {
            System.err.println("ERROR Failed to send message notification email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}