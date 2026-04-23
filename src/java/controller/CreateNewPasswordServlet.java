package controller;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/CreateNewPasswordServlet")
public class CreateNewPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("user_id");
        
        if(userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String newPassword = request.getParameter("new_password");
        String confirmPassword = request.getParameter("confirm_password");

        if(!newPassword.equals(confirmPassword)) {
            response.sendRedirect("create_new_password.jsp?error=mismatch");
            return;
        }

        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

        try(Connection conn = DBConnection.getConnection()){

            String sql = "UPDATE users SET password = ?, force_change = 'N' WHERE user_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, hashedPassword);
            ps.setInt(2, userId);
            ps.executeUpdate();

            response.sendRedirect("password_set_successfully.jsp");

        } catch(Exception e){
            e.printStackTrace();
            response.sendRedirect("create_new_password.jsp?error=system");
        }
    }
}