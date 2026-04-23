package controller;

import java.sql.*;
import java.util.*;

public class MessageDAO {

    public List<Map<String, Object>> getConversations(int userId) {
        List<Map<String, Object>> conversations = new ArrayList<>();

        try (Connection conn = util.DBConnection.getConnection()) {

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
                conv.put("lastMessageAt", lastMsgAt); // ✅ keep as Timestamp
                conv.put("lastMessage", rs.getString("last_message"));

                conversations.add(conv);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return conversations;
    }

    public List<Message> getChatHistory(int userId1, int userId2) {
    List<Message> messages = new ArrayList<>();

    try (Connection conn = util.DBConnection.getConnection()) {

        int conversationId = getConversationId(userId1, userId2);
        if (conversationId == -1) {
            return messages;
        }

        String sql = "SELECT message_id, conversation_id, sender_id, message_text, sent_at " +
                     "FROM messages WHERE conversation_id = ? ORDER BY sent_at ASC";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, conversationId);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Message msg = new Message();
            msg.setMessageId(rs.getInt("message_id"));
            msg.setConversationId(rs.getInt("conversation_id"));
            msg.setSenderId(rs.getInt("sender_id"));
            msg.setMessageText(rs.getString("message_text"));

            // ✅ FIXED (core issue)
            Timestamp ts = rs.getTimestamp("sent_at");
            msg.setSentAt(ts != null ? ts.toLocalDateTime() : null);

            messages.add(msg);
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return messages;
}

    private int getConversationId(int userId1, int userId2) {
        int u1 = Math.min(userId1, userId2);
        int u2 = Math.max(userId1, userId2);

        try (Connection conn = util.DBConnection.getConnection()) {

            String sql = "SELECT conversation_id FROM conversations WHERE user1_id = ? AND user2_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, u1);
            ps.setInt(2, u2);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("conversation_id");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return -1;
    }

    public boolean saveMessage(int senderId, int conversationId, String messageText) {
        try (Connection conn = util.DBConnection.getConnection()) {

            String sql = "INSERT INTO messages (message_id, conversation_id, sender_id, message_text, sent_at) " +
                    "VALUES (messages_seq.NEXTVAL, ?, ?, ?, SYSDATE)";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, conversationId);
            ps.setInt(2, senderId);
            ps.setString(3, messageText);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                updateConversationTimestamp(conversationId);
            }

            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void updateConversationTimestamp(int conversationId) {
        try (Connection conn = util.DBConnection.getConnection()) {

            String sql = "UPDATE conversations SET last_message_at = SYSDATE WHERE conversation_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, conversationId);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public Map<String, Object> getUserByEmail(String email) {
        try (Connection conn = util.DBConnection.getConnection()) {

            String sql = "SELECT user_id, full_name, email FROM users WHERE LOWER(email) = LOWER(?) AND role_id = 1";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email.trim());

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Map<String, Object> user = new HashMap<>();
                user.put("id", rs.getInt("user_id"));
                user.put("fullName", rs.getString("full_name"));
                user.put("email", rs.getString("email"));
                return user;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public int createOrGetConversation(int userId1, int userId2) {
        int u1 = Math.min(userId1, userId2);
        int u2 = Math.max(userId1, userId2);

        try (Connection conn = util.DBConnection.getConnection()) {

            String checkSql = "SELECT conversation_id FROM conversations WHERE user1_id = ? AND user2_id = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, u1);
            checkPs.setInt(2, u2);

            ResultSet rs = checkPs.executeQuery();
            if (rs.next()) {
                return rs.getInt("conversation_id");
            }

            String insertSql = "INSERT INTO conversations (conversation_id, user1_id, user2_id, last_message_at) " +
                    "VALUES (conversations_seq.NEXTVAL, ?, ?, NULL)";
            PreparedStatement insertPs = conn.prepareStatement(insertSql);
            insertPs.setInt(1, u1);
            insertPs.setInt(2, u2);
            insertPs.executeUpdate();

            // fetch again
            PreparedStatement getPs = conn.prepareStatement(checkSql);
            getPs.setInt(1, u1);
            getPs.setInt(2, u2);
            ResultSet getRs = getPs.executeQuery();

            if (getRs.next()) {
                return getRs.getInt("conversation_id");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return -1;
    }
}