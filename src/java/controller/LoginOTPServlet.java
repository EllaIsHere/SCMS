package controller;

import util.DBConnection;
import util.EmailUtil;
import java.io.IOException;
import java.sql.*;
import java.util.Random;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/LoginOTPServlet")
public class LoginOTPServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try (Connection conn = DBConnection.getConnection()) {

            String sql = "SELECT * FROM users WHERE email = ? AND access_status = 'Active'";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedHashedPassword = rs.getString("password");

                // Verify password
                if (!BCrypt.checkpw(password, storedHashedPassword)) {
                    response.sendRedirect("login.jsp?error=1");
                    return;
                }

                // Generate OTP for login
                String otp = String.valueOf(100000 + new Random().nextInt(900000));

                HttpSession session = request.getSession();
                session.setAttribute("loginOtp", otp);
                session.setAttribute("loginOtpEmail", email);
                session.setAttribute("loginOtpUserId", rs.getInt("user_id"));
                session.setAttribute("loginOtpRoleId", rs.getInt("role_id"));
                session.setAttribute("loginOtpExpiry", System.currentTimeMillis() + (10 * 60 * 1000));
                session.setAttribute("loginOtpVerified", false);

                // Send OTP to email
                EmailUtil.sendOTPEmailHTML(email, otp);

                response.sendRedirect("login_otp_verification.jsp");

            } else {
                response.sendRedirect("login.jsp?error=1");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}