package controller;

import util.DBConnection;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

/**
 * MessagesServlet — handles all AJAX calls from messages.jsp
 */
@WebServlet("/MessagesServlet")
public class MessagesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // DEBUG LOG
        System.out.println("========== MessagesServlet doGet() CALLED ==========");
        System.out.println("Request URI: " + request.getRequestURI());
        System.out.println("Request Method: " + request.getMethod());
        
        String action = request.getParameter("action");
        System.out.println("Action Parameter: [" + action + "]");
        System.out.println("All Parameters: " + request.getParameterMap().keySet());

        // Session guard
        HttpSession session = request.getSession(false);
        System.out.println("Session exists: " + (session != null));
        if (session != null) {
            System.out.println("Session user_id: " + session.getAttribute("user_id"));
        }

        if (session == null || session.getAttribute("user_id") == null) {
            System.out.println("ERROR: No session or user_id");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print(error("Not logged in"));
            return;
        }

        int userId = ((Number) session.getAttribute("user_id")).intValue();
        System.out.println("User ID: " + userId);

        if (action == null || action.trim().isEmpty()) {
            System.out.println("ERROR: Invalid action");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print(error("Invalid action"));
            return;
        }

        try {
            System.out.println("Processing action: " + action);
            switch (action.trim()) {
                case "getConversations":
                    System.out.println("Executing getConversations");
                    out.print(getConversations(userId));
                    break;
                case "getMessages":
                    System.out.println("Executing getMessages");
                    int convId = intParam(request, "conversationId");
                    out.print(getMessages(userId, convId));
                    break;
                default:
                    System.out.println("ERROR: Unknown action: " + action);
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print(error("Unknown action: " + action));
            }
        } catch (Exception e) {
            System.out.println("EXCEPTION in doGet: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(error("Server error: " + e.getMessage()));
        }
        System.out.println("========== MessagesServlet doGet() ENDED ==========");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // DEBUG LOG
        System.out.println("========== MessagesServlet doPost() CALLED ==========");
        System.out.println("Request URI: " + request.getRequestURI());
        System.out.println("Request Method: " + request.getMethod());
        
        String action = request.getParameter("action");
        System.out.println("Action Parameter: [" + action + "]");
        System.out.println("All Parameters: " + request.getParameterMap().keySet());

        // Session guard
        HttpSession session = request.getSession(false);
        System.out.println("Session exists: " + (session != null));
        if (session != null) {
            System.out.println("Session user_id: " + session.getAttribute("user_id"));
        }

        if (session == null || session.getAttribute("user_id") == null) {
            System.out.println("ERROR: No session or user_id");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print(error("Not logged in"));
            return;
        }

        int userId = ((Number) session.getAttribute("user_id")).intValue();
        System.out.println("User ID: " + userId);

        if (action == null || action.trim().isEmpty()) {
            System.out.println("ERROR: Invalid action");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print(error("Invalid action"));
            return;
        }

        try {
            System.out.println("Processing action: " + action);
            switch (action.trim()) {
                case "sendMessage":
                    System.out.println("Executing sendMessage");
                    int convId = intParam(request, "conversationId");
                    String text = request.getParameter("message");
                    System.out.println("ConvId: " + convId + ", Message: " + text);
                    out.print(sendMessage(userId, convId, text));
                    break;
                case "startChat":
                    System.out.println("Executing startChat");
                    String email = request.getParameter("email");
                    System.out.println("Email: " + email);
                    out.print(startChat(userId, email));
                    break;
                case "deleteConversation":
                    System.out.println("Executing deleteConversation");
                    int delConvId = intParam(request, "conversationId");
                    System.out.println("ConvId to delete: " + delConvId);
                    out.print(deleteConversation(userId, delConvId));
                    break;
                default:
                    System.out.println("ERROR: Unknown action: " + action);
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print(error("Unknown action: " + action));
            }
        } catch (Exception e) {
            System.out.println("EXCEPTION in doPost: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(error("Server error: " + e.getMessage()));
        }
        System.out.println("========== MessagesServlet doPost() ENDED ==========");
    }

    private String getConversations(int userId) throws SQLException {
        String sql =
            "SELECT c.CONVERSATION_ID, " +
            "       CASE WHEN c.USER1_ID = ? THEN c.USER2_ID ELSE c.USER1_ID END AS OTHER_USER_ID, " +
            "       u.FIRST_NAME, u.LAST_NAME, u.FULL_NAME, u.EMAIL, " +
            "       c.LAST_MESSAGE_AT, " +
            "       (SELECT m2.MESSAGE_TEXT FROM MESSAGES m2 " +
            "        WHERE m2.CONVERSATION_ID = c.CONVERSATION_ID " +
            "        ORDER BY m2.SENT_AT DESC FETCH FIRST 1 ROWS ONLY) AS LAST_MSG " +
            "  FROM CONVERSATIONS c " +
            "  JOIN USERS u ON u.USER_ID = " +
            "       (CASE WHEN c.USER1_ID = ? THEN c.USER2_ID ELSE c.USER1_ID END) " +
            " WHERE (c.USER1_ID = ? OR c.USER2_ID = ?) " +
            "   AND NOT EXISTS ( " +
            "       SELECT 1 FROM CONVERSATION_DELETIONS cd " +
            "        WHERE cd.USER_ID = ? AND cd.CONVERSATION_ID = c.CONVERSATION_ID " +
            "          AND NOT EXISTS ( " +
            "              SELECT 1 FROM MESSAGES m3 " +
            "               WHERE m3.CONVERSATION_ID = c.CONVERSATION_ID " +
            "                 AND m3.SENT_AT > cd.DELETED_AT " +
            "          ) " +
            "   ) " +
            " ORDER BY c.LAST_MESSAGE_AT DESC NULLS LAST";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            ps.setInt(4, userId);
            ps.setInt(5, userId);

            ResultSet rs = ps.executeQuery();
            JSONArray list = new JSONArray();
            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("conversationId", rs.getInt("CONVERSATION_ID"));
                obj.put("otherUserId", rs.getInt("OTHER_USER_ID"));
                obj.put("firstName", rs.getString("FIRST_NAME"));
                obj.put("lastName", rs.getString("LAST_NAME"));
                obj.put("fullName", rs.getString("FULL_NAME"));
                obj.put("email", rs.getString("EMAIL"));
                Timestamp ts = rs.getTimestamp("LAST_MESSAGE_AT");
                obj.put("lastMessageAt", ts != null ? ts.toString() : "");
                String lastMsg = rs.getString("LAST_MSG");
                obj.put("lastMessage", lastMsg != null ? lastMsg : "");
                list.put(obj);
            }
            
            JSONObject result = new JSONObject();
            result.put("status", "success");
            result.put("data", list);
            return result.toString();
        }
    }

    private String getMessages(int userId, int conversationId) throws SQLException {
        if (!userBelongsToConversation(userId, conversationId)) {
            return error("Access denied");
        }

        Timestamp deletedAt = getDeletionTimestamp(userId, conversationId);

        String sql =
            "SELECT m.MESSAGE_ID, m.SENDER_ID, m.MESSAGE_TEXT, m.SENT_AT, " +
            "       u.FIRST_NAME, u.LAST_NAME " +
            "  FROM MESSAGES m " +
            "  JOIN USERS u ON u.USER_ID = m.SENDER_ID " +
            " WHERE m.CONVERSATION_ID = ? " +
            (deletedAt != null ? "   AND m.SENT_AT > ? " : "") +
            " ORDER BY m.SENT_AT ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            if (deletedAt != null) {
                ps.setTimestamp(2, deletedAt);
            }
            
            ResultSet rs = ps.executeQuery();
            JSONArray msgs = new JSONArray();
            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("messageId", rs.getInt("MESSAGE_ID"));
                obj.put("senderId", rs.getInt("SENDER_ID"));
                obj.put("text", rs.getString("MESSAGE_TEXT"));
                obj.put("sentAt", rs.getTimestamp("SENT_AT").toString());
                obj.put("firstName", rs.getString("FIRST_NAME"));
                obj.put("lastName", rs.getString("LAST_NAME"));
                obj.put("isMine", rs.getInt("SENDER_ID") == userId);
                msgs.put(obj);
            }
            
            JSONObject result = new JSONObject();
            result.put("status", "success");
            result.put("messages", msgs);
            return result.toString();
        }
    }

    private String sendMessage(int senderId, int conversationId, String text)
            throws SQLException {
        if (text == null || text.trim().isEmpty()) {
            return error("Message cannot be empty");
        }
        if (!userBelongsToConversation(senderId, conversationId)) {
            return error("Access denied");
        }

        String insertMsg =
            "INSERT INTO MESSAGES (CONVERSATION_ID, SENDER_ID, MESSAGE_TEXT, SENT_AT) " +
            "VALUES (?, ?, ?, CURRENT_TIMESTAMP)";

        String updateConv =
            "UPDATE CONVERSATIONS SET LAST_MESSAGE_AT = CURRENT_TIMESTAMP " +
            " WHERE CONVERSATION_ID = ?";

        String clearDel =
            "DELETE FROM CONVERSATION_DELETIONS WHERE CONVERSATION_ID = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(insertMsg)) {
                    ps.setInt(1, conversationId);
                    ps.setInt(2, senderId);
                    ps.setString(3, text.trim());
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(updateConv)) {
                    ps.setInt(1, conversationId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(clearDel)) {
                    ps.setInt(1, conversationId);
                    ps.executeUpdate();
                }
                conn.commit();

                JSONObject result = new JSONObject();
                result.put("status", "success");
                result.put("message", "Message sent");
                return result.toString();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    private String startChat(int currentUserId, String email) throws SQLException {
        if (email == null || email.trim().isEmpty()) {
            return error("Email is required");
        }

        String findUser = "SELECT USER_ID, FIRST_NAME, LAST_NAME, FULL_NAME FROM USERS " +
                          " WHERE LOWER(EMAIL) = LOWER(?) AND USER_ID != ? AND ROLE_ID = 1";

        int targetUserId;
        String firstName, lastName, fullName;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(findUser)) {
            ps.setString(1, email.trim());
            ps.setInt(2, currentUserId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                return error("User not found");
            }
            targetUserId = rs.getInt("USER_ID");
            firstName = rs.getString("FIRST_NAME");
            lastName = rs.getString("LAST_NAME");
            fullName = rs.getString("FULL_NAME");
        }

        int user1 = Math.min(currentUserId, targetUserId);
        int user2 = Math.max(currentUserId, targetUserId);

        String findConv = "SELECT CONVERSATION_ID FROM CONVERSATIONS " +
                         " WHERE USER1_ID = ? AND USER2_ID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(findConv)) {
            ps.setInt(1, user1);
            ps.setInt(2, user2);
            ResultSet rs = ps.executeQuery();
            
            int convId;
            if (rs.next()) {
                convId = rs.getInt("CONVERSATION_ID");
                clearDeletion(conn, currentUserId, convId);
            } else {
                String insertConv = "INSERT INTO CONVERSATIONS (USER1_ID, USER2_ID) VALUES (?, ?)";
                try (PreparedStatement ps2 = conn.prepareStatement(insertConv)) {
                    ps2.setInt(1, user1);
                    ps2.setInt(2, user2);
                    ps2.executeUpdate();
                }
                
                try (PreparedStatement ps3 = conn.prepareStatement(findConv)) {
                    ps3.setInt(1, user1);
                    ps3.setInt(2, user2);
                    ResultSet rs2 = ps3.executeQuery();
                    rs2.next();
                    convId = rs2.getInt("CONVERSATION_ID");
                }
            }

            JSONObject result = new JSONObject();
            result.put("status", "success");
            result.put("conversationId", convId);
            result.put("otherUserId", targetUserId);
            result.put("firstName", firstName);
            result.put("lastName", lastName);
            result.put("fullName", fullName);
            return result.toString();
        }
    }

    private String deleteConversation(int userId, int conversationId) throws SQLException {
        if (!userBelongsToConversation(userId, conversationId)) {
            return error("Access denied");
        }

        String upsert =
            "MERGE INTO CONVERSATION_DELETIONS cd " +
            "USING (SELECT ? AS U, ? AS C FROM DUAL) src " +
            "ON (cd.USER_ID = src.U AND cd.CONVERSATION_ID = src.C) " +
            "WHEN NOT MATCHED THEN " +
            "  INSERT (USER_ID, CONVERSATION_ID) VALUES (src.U, src.C)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(upsert)) {
            ps.setInt(1, userId);
            ps.setInt(2, conversationId);
            ps.executeUpdate();
        }

        JSONObject result = new JSONObject();
        result.put("status", "success");
        result.put("message", "Conversation deleted");
        return result.toString();
    }

    private boolean userBelongsToConversation(int userId, int conversationId)
            throws SQLException {
        String sql = "SELECT 1 FROM CONVERSATIONS " +
                     " WHERE CONVERSATION_ID = ? AND (USER1_ID = ? OR USER2_ID = ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        }
    }

    private Timestamp getDeletionTimestamp(int userId, int conversationId)
            throws SQLException {
        String sql = "SELECT DELETED_AT FROM CONVERSATION_DELETIONS " +
                     " WHERE USER_ID = ? AND CONVERSATION_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, conversationId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getTimestamp("DELETED_AT");
            return null;
        }
    }

    private void clearDeletion(Connection conn, int userId, int conversationId)
            throws SQLException {
        String sql = "DELETE FROM CONVERSATION_DELETIONS " +
                     " WHERE USER_ID = ? AND CONVERSATION_ID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, conversationId);
            ps.executeUpdate();
        }
    }

    private int intParam(HttpServletRequest req, String name) {
        String val = req.getParameter(name);
        if (val == null || val.isEmpty()) return -1;
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    private String error(String msg) {
        JSONObject obj = new JSONObject();
        obj.put("status", "error");
        obj.put("message", msg);
        return obj.toString();
    }
}