package controller;

import util.DBConnection;
import util.EmailUtil;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/ChangePasswordServlet")
public class ChangePasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String newPass = request.getParameter("new_password");

        try(Connection conn = DBConnection.getConnection()){

            String sql = "UPDATE users SET password=?, force_change='N' WHERE email=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            String hashed = BCrypt.hashpw(newPass, BCrypt.gensalt());
            ps.setString(1, hashed);
            ps.setString(2, email);

            ps.executeUpdate();

            // Send confirmation email
            String subject = "Password Changed Successfully - SCMS";
            String htmlBody = "<html><body style='font-family: Arial, sans-serif;'>" +
                    "<h2 style='color: #28a745;'>Password Changed Successfully</h2>" +
                    "<p>Your password has been updated successfully.</p>" +
                    "<p>If you didn't make this change, please contact support immediately.</p>" +
                    "<p>You can now login with your new password.</p>" +
                    "</body></html>";
            
            EmailUtil.sendHtmlEmail(email, subject, htmlBody);

            response.sendRedirect("login.jsp");

        } catch(Exception e){
            e.printStackTrace();
        }
    }
}