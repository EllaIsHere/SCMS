package controller;

import util.MessageUtil;
import java.io.IOException;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.google.gson.Gson;

@WebServlet("/GetConversationsServlet")
public class GetConversationsServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {
    
    HttpSession session = request.getSession(false);
    
    // Check session exists and has user_id attribute
    if (session == null || session.getAttribute("user_id") == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"error\": \"Unauthorized\", \"message\": \"Session expired. Please login again.\"}");
        System.out.println("ERROR: Session is null or user_id not found");
        return;
    }
        
    try {
        Integer userId = (Integer) session.getAttribute("user_id");
        System.out.println("DEBUG: Getting conversations for user: " + userId);
        
        List<Map<String, Object>> conversations = MessageUtil.getConversations(userId);
        
        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(conversations));
        
        System.out.println("DEBUG: Conversations sent successfully. Count: " + conversations.size());
    } catch (Exception e) {
        System.err.println("ERROR in GetConversationsServlet: " + e.getMessage());
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        response.setContentType("application/json");
        response.getWriter().write("{\"error\": \"Internal server error\"}");
    }
    }
}