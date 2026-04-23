package controller;

import util.DBConnection;
import util.EmailUtil;
import java.io.IOException;
import java.sql.*;
import java.util.Random;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        System.out.println("=== LoginServlet Started ===");
        System.out.println("Email: " + email);

        try (Connection conn = DBConnection.getConnection()) {

            String sql = "SELECT * FROM users WHERE email = ? AND access_status = 'Active'";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                System.out.println("ERROR: User not found");
                response.sendRedirect("login.jsp?error=1");
                return;
            }

            String storedHashedPassword = rs.getString("password");
            String isVerified = rs.getString("is_verified");
            int userId = rs.getInt("user_id");
            int roleId = rs.getInt("role_id");
            String fullName = rs.getString("full_name");

            System.out.println("User found. Checking password...");

            if (!BCrypt.checkpw(password, storedHashedPassword)) {
                System.out.println("ERROR: Password mismatch");
                response.sendRedirect("login.jsp?error=1");
                return;
            }

            // Check if email is verified
            if(!"Y".equals(isVerified)) {
                System.out.println("ERROR: Email not verified");
                response.sendRedirect("login.jsp?error=not_verified");
                return;
            }

            System.out.println("Password correct. Generating login OTP...");

            // Generate OTP for login
            String otp = String.valueOf(100000 + new Random().nextInt(900000));
            System.out.println("Generated Login OTP: " + otp);

            HttpSession session = request.getSession();
            session.setAttribute("loginOtp", otp);
            session.setAttribute("loginOtpEmail", email);
            session.setAttribute("loginOtpUserId", userId);
            session.setAttribute("loginOtpRoleId", roleId);
            session.setAttribute("loginOtpFullName", fullName);
            session.setAttribute("loginOtpExpiry", System.currentTimeMillis() + (10 * 60 * 1000));

            // Send OTP to email
            System.out.println("Sending login OTP to: " + email);
            EmailUtil.sendOTPEmailHTML(email, otp);

            System.out.println("Redirecting to login_otp_verification.jsp");
            response.sendRedirect("login_otp_verification.jsp");

        } catch (Exception e) {
            System.out.println("Exception: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("=== LoginServlet Ended ===");
    }
}