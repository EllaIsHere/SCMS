package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginVerifyOTPServlet")
public class LoginVerifyOTPServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String enteredOtp = request.getParameter("otp");
        HttpSession session = request.getSession();

        String storedOtp = (String) session.getAttribute("loginOtp");
        long otpExpiry = (Long) session.getAttribute("loginOtpExpiry");
        int userId = (Integer) session.getAttribute("loginOtpUserId");
        int roleId = (Integer) session.getAttribute("loginOtpRoleId");
        String email = (String) session.getAttribute("loginOtpEmail");
        String fullName = (String) session.getAttribute("loginOtpFullName");

        System.out.println("=== LoginVerifyOTPServlet Started ===");
        System.out.println("Entered OTP: " + enteredOtp);

        // Check if OTP is expired
        if (System.currentTimeMillis() > otpExpiry) {
            System.out.println("ERROR: OTP expired");
            response.sendRedirect("login_otp_verification.jsp?error=otp_expired");
            return;
        }

        // Verify OTP
        if (!enteredOtp.equals(storedOtp)) {
            System.out.println("ERROR: OTP mismatch");
            response.sendRedirect("login_otp_verification.jsp?error=otp_mismatch");
            return;
        }

        System.out.println("SUCCESS: OTP verified");

        // Create new session for logged-in user
        session.invalidate();
        session = request.getSession();
        session.setAttribute("user_id", userId);
        session.setAttribute("role_id", roleId);
        session.setAttribute("email", email);
        session.setAttribute("fullName", fullName);

        System.out.println("Session attributes set - user_id: " + userId + ", email: " + email);

        // Redirect based on role
        if (roleId == 1) {
            System.out.println("Redirecting to student dashboard");
            response.sendRedirect("student_dashboard.jsp");
        } else if (roleId == 2) {
            System.out.println("Redirecting to staff dashboard");
            response.sendRedirect("staff_dashboard.jsp");
        } else if (roleId == 3) {
            System.out.println("Redirecting to admin dashboard");
            response.sendRedirect("admin_dashboard.jsp");
        }

        System.out.println("=== LoginVerifyOTPServlet Ended ===");
    }
}