package controller;

import util.MessageUtil;
import java.io.IOException;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.google.gson.Gson;

@WebServlet("/GetChatHistoryServlet")
public class GetChatHistoryServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendError(401, "Not authenticated");
            return;
        }
        
        Integer userId = (Integer) session.getAttribute("user_id");
        String otherUserIdStr = request.getParameter("otherUserId");
        
        if (otherUserIdStr == null || otherUserIdStr.isEmpty()) {
            response.sendError(400, "otherUserId parameter required");
            return;
        }
        
        try {
            int otherUserId = Integer.parseInt(otherUserIdStr);
            List<Map<String, Object>> messages = MessageUtil.getMessageHistory(userId, otherUserId);
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(new Gson().toJson(messages));
        } catch (NumberFormatException e) {
            response.sendError(400, "Invalid otherUserId");
        }
    }
}